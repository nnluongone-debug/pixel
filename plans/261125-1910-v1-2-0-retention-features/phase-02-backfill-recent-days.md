# Phase 02: Backfill progress for the last 7 days

## Context Links
- `lib/data/repositories/check_in_repository.dart`: `insertForDay(executor, habitId,
  dateKey)` already takes any date. It sets gridX to the epoch day and gridY to the
  column's current height (stacks on top), computes the streak bonus via
  `scheduledStreakBefore(day)` and the row bonus via `_completedRows(day)`, and enqueues
  sync. `removeForDay` deletes, enqueues the delete and runs `compactColumn`.
- `lib/data/repositories/habit_repository.dart` (352 lines, do not grow it): today-only
  progress (`currentProgress`/`progressDate`) and `_applyProgress`.
- `lib/data/repositories/user_stats_repository.dart`: `recalculate(txn)` rebuilds XP, level
  and streak from `check_ins`.
- `lib/domain/progression/xp_rules.dart`.
- `lib/providers/habit_providers.dart` (`HabitsController._mutate`, `_refreshAll`,
  `_logProgress`), `lib/providers/repository_providers.dart`.
- Badges and analytics: `lib/domain/analytics/*` via `analyticsDataProvider`. These are
  rebuilt from all check-ins after every mutation, so no change is needed.
- Sync: `lib/services/sync/sync_pull_applier.dart` handles any date and the
  `(habit_id, date)` clash. `firestore.rules` checks `xpEarned <= 1000` and the date format
  only, so no rules change is needed.
- UI: `lib/features/habit_detail/habit_detail_screen.dart` (138 lines).

## Overview
- Priority: P1 · Status: done · Effort: 5h
- On the habit detail screen, a "Last 7 days" strip of 7 day chips (yesterday back to today
  minus 7). Tap to mark done, tap again to unmark. The habit's main action button still
  handles today.

## Key Insights
- **N = 7.** This covers "I forgot to log over the weekend" and fits within the 10-column
  matrix, so the user sees the brick land. A longer window invites bulk-faking.
- **Binary for every type.** A past day is either "done" (one block) or not. Past
  counter/timer progress is not stored (only today has `currentProgress`), so backfilling a
  counter or timer marks it done at target. No partial past progress (YAGNI).
- **gridY:** append on top of that day's column (existing `insertForDay` behavior). Undo
  calls `compactColumn`. Stacking order inside a past column stops being chronological,
  which is acceptable.
- **XP: base only (25), no streak bonus and no row bonus.** This is simple and cannot be
  exploited: a backfilled block is never worth more than a live one, so there is no reason
  to log late. Undo removes exactly the stored `xp_earned`. Later blocks keep their stored
  bonuses, because XP is stored per block at insert time and never recomputed (existing
  rule). A streak repaired by a backfill does not retroactively raise later bonuses.
- **No backfill before the habit's creation day.** This blocks the "create a habit, then
  fill 7 days" XP farm (175 XP per new habit) and matches `_anyHabitDue`, which ignores
  days before `created_at`.
- **Streak, level, badges and themes recompute for free.** `stats.recalculate(txn)` runs
  in the same transaction, and badge, analytics and best-streak providers refresh because
  `_refreshAll` invalidates habits and stats. A badge earned by backfill counts as "local
  progress" (the event is emitted), so the unlock popup shows, which is correct.
- **Today is excluded.** Today goes through `setCompleted`/`setProgress` so
  `currentProgress` stays consistent. The repo rejects `dateKey == today`.

## Requirements
Functional
- Strip: 7 chips (oldest on the left, yesterday on the right). Each chip shows the weekday
  letter and day number. Filled with the habit color when done, outline when not done,
  dimmed with a dot when the habit was not due that day (still tappable, same as completing
  on an off day live). Chips for days before the habit was created are disabled.
- Tap shows the toggle with light haptics, and snackbar feedback on failure.
- Matrix, HUD streak/level and stats update immediately. Changes sync to Firestore when
  signed in.
- Analytics: do not log `habit_completed` for backfills (it is keyed to today's
  `dayKey`). Still log `level_up`.

Non-functional
- Single transaction per toggle with one clock reading (same pattern as
  `HabitRepository._transaction`).
- Idempotent: marking a day that is already done is a no-op, and so is unmarking a day that
  is not done.

## Architecture
```
HabitRecentDaysStrip (UI)
  watches habitRecentDaysProvider(habitId) -> Set<String> doneKeys (window only)
  onTap(dateKey, done) -> HabitsController.setPastDay(id, dateKey, done:)
     -> HabitBackfillRepository.setDone(id, dateKey, done:)
        txn: validate window and createdDay
             existing = checkIns.findForDay(txn, id, key)
             done && existing==null -> checkIns.insertForDay(txn, id, key, backfill: true)
             !done && existing!=null -> checkIns.removeForDay(txn, id, key)
             stats.recalculate(txn, now)
        returns ProgressUpdate(habit, stats, previousLevel, placed/removed)
     -> _mutate: _refreshAll + progressEvents (level-up/badge popups)
```
`insertForDay(..., {bool backfill = false})`: when backfill is true,
`xpEarned = XpRules.baseXpPerCheckIn` and the streak/row queries are skipped.

## Related Code Files
Create
- `lib/data/repositories/habit_backfill_repository.dart` (~90 lines): `maxDaysBack = 7`,
  `isEditable(habit, dateKey, today)`, `setDone(...)`, `doneDays(habitId, fromKey, toKey)`.
- `lib/features/habit_detail/habit_recent_days_strip.dart` (~120 lines).
- `test/data/habit_backfill_repository_test.dart`.
- `test/features/habit_detail/habit_recent_days_strip_test.dart`.

Modify
- `lib/data/repositories/check_in_repository.dart`: add the `backfill` flag to
  `insertForDay`.
- `lib/domain/progression/xp_rules.dart`: doc line stating that backfilled blocks earn
  `baseXpPerCheckIn` only. No new constant.
- `lib/providers/repository_providers.dart`: `habitBackfillRepositoryProvider`.
- `lib/providers/habit_providers.dart`: `habitRecentDaysProvider` (family),
  `HabitsController.setPastDay`, and invalidate `habitRecentDaysProvider` in
  `_refreshAll`. In `_logProgress`, skip `habitCompleted` when `placedCheckIn.date !=` today.
  `_mutate` is typed on `HabitRepository`, so add a small `_mutateWith` or call the backfill
  repo directly and then reuse the refresh/emit tail. Keep it DRY by extracting
  `_afterMutation(result)`.
- `lib/features/habit_detail/habit_detail_screen.dart`: insert the strip between the
  progress bar and the action button.
- `lib/l10n/app_en.arb`, `app_vi.arb`: `detailRecentDaysTitle` ("LAST 7 DAYS" / "7 NGÀY
  QUA"), `detailRecentDaysHint` ("Tap a day you forgot to log" / "Chạm vào ngày bạn quên
  ghi"), `detailBackfillFailed`. Run `flutter gen-l10n`.
- `test/data/habit_repository_test.dart`: no behavior change expected. Run it as a
  regression check.

## Implementation Steps
1. `insertForDay` gets the `backfill` flag (default false keeps all current callers
   unchanged).
2. `HabitBackfillRepository`:
   - `_window(today)` gives `[today-7, today-1]`.
   - `setDone` throws `ArgumentError` outside the window, before `createdDay` (local date of
     `created_at`), or for an unknown habit.
   - Transaction: read `previousLevel` from `stats.getCachedStats(txn)`, insert or remove,
     `stats.recalculate(txn, now: now)`, then build the `ProgressUpdate` (habit unchanged).
3. Providers and controller method. Extract `_afterMutation`.
4. `HabitRecentDaysStrip` widget. Use `habit.isDueOn(date)` for the off-day dim and
   `habit.createdAt` for disabled chips. Read keys from `habitRecentDaysProvider`.
5. Add the strip to the detail screen. Check layout on small phones (`Spacer`s collapse).
   Chips are 36dp wide and the row uses `MainAxisAlignment.spaceBetween`.
6. Add l10n keys en/vi and run gen-l10n.
7. Write the tests (see below) and run `flutter analyze && flutter test`.

## Tests
`test/data/habit_backfill_repository_test.dart` (ffi in-memory DB, injected clock like
`habit_repository_test.dart`):
- Marking yesterday creates a block with gridX = yesterday's epoch day, gridY on top of the
  column, xp = 25, and an outbox upsert row.
- Unmarking removes it, compacts the column, queues the outbox delete, and total XP returns
  to its previous value.
- Rejects today, today-8, future days and days before the creation day.
- Filling a one-day gap revives the global streak (`stats.streakDays`), and best streak
  updates.
- Idempotent double mark and double unmark.
- A counter habit's `currentProgress` and `progressDate` stay untouched.
Widget test `habit_recent_days_strip_test.dart`: renders 7 chips, disabled before
creation, tapping toggles via a provider override.

## Todo List
- [x] `insertForDay` backfill flag
- [x] `habit_backfill_repository.dart` + provider
- [x] Controller `setPastDay`, `_afterMutation`, analytics guard
- [x] `habitRecentDaysProvider` + invalidation
- [x] `habit_recent_days_strip.dart` + detail screen wiring
- [x] l10n en/vi
- [x] Repository and widget tests

## Success Criteria
- All of the test bullets above pass. Existing `habit_repository_test.dart` and
  `sync_*` tests stay green.
- Manual: backfill yesterday, and the matrix column for yesterday gains a brick, HUD XP
  goes up by 25, and the streak changes accordingly. Sign in on a second device, pull, and
  the same block appears.

## Risk Assessment
| Risk | L x I | Mitigation |
|---|---|---|
| Cheating streaks/themes via backfill | M x L | 7-day window, creation-day floor, base XP only. Honor system app |
| Backfill raises a past column height, so later row-bonus is larger | L x L | Capped at 50 and requires real completions per habit and day. Accepted |
| Pull clash: same habit/day backfilled on two devices offline | L x M | Existing clash rule (newer stamp wins, else smaller id) |
| Analytics noise | L x L | Skip `habit_completed` for non-today blocks |
| Habit detail overflow on small screens | M x L | Widget test at 320x568 and Flexible chips |

## Rollback
Remove the strip from the detail screen. Data written by backfill is ordinary check-ins,
so there is nothing to migrate back.

## Security Considerations
- No new data fields, so Firestore rules already validate the docs.
- Validation happens in the repository (not only in the UI), so deep links or future
  callers cannot write outside the window.

## Next Steps
- Phase 03 builds freeze math on top of the check-in set, including backfilled days.
