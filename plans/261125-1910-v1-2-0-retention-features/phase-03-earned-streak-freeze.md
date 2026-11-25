# Phase 03: Earned streak freeze

## Context Links
- `lib/domain/progression/streak_calculator.dart`: `scheduledStreak` (walk back, today
  grace, off days skip) and `longestScheduledStreak`.
- `lib/data/repositories/user_stats_repository.dart`: `recalculate` (global streak from
  `DISTINCT grid_x` + `_anyHabitDue`), `getBestStreak` (used by `bestStreakProvider`, which
  gates streak-unlocked themes in `lib/domain/cosmetics/theme_catalog.dart`).
- `lib/domain/progression/xp_rules.dart`: level comes from lifetime XP, so spending XP is
  not possible.
- UI: `lib/features/home/widgets/status_hud_card.dart` (`gridHudStreak` pill),
  `lib/features/matrix/widgets/pixel_matrix_grid.dart` (270 lines, add a param only),
  `matrix_overlay_painter.dart`, `lib/features/home/widgets/matrix_canvas_card.dart`.
- Listener pattern: `lib/features/stats/badge_unlock_listener.dart`, wired in
  `lib/app/app_shell.dart`.
- `sharedPreferencesProvider` in `lib/providers/locale_providers.dart`.

## Overview
- Priority: P2 · Status: implemented · Effort: 4h
- The global streak survives a missed due day when a freeze is held. Freezes are earned by
  keeping the streak going, and nothing is bought.

## Design choice
| Option | Verdict |
|---|---|
| A. Spend XP to buy a freeze | **Rejected.** Level = f(lifetime XP), so spending drops levels and re-locks themes |
| B. Separate coin currency | Rejected. A new economy, earning rules, UI and sync (YAGNI) |
| C. Earned inventory **stored** in DB + Firestore | Rejected. Needs a migration, a new outbox entity (the `sync_outbox.entity` CHECK constraint needs a table rebuild), rules, a multi-device double-consume merge, and drift on backfill/undo |
| **D. Earned and auto-used, derived from history** | **Chosen** |

Why D: the codebase already treats `user_stats` as a projection rebuilt from `check_ins`.
Freezes become another projection, a pure function of (active days, due-day predicate,
today). That gives:
- No schema change, no sync and no rules change. Every device computes the same result.
- Correct by construction after backfill, undo, habit deletion or sync pull.
- Fully unit-testable domain logic.
The trade-off: editing a habit's schedule can retroactively change which days were frozen.
The streak already behaves this way today.

## Rules (`StreakFreezeRules`)
- `earnEvery = 7`: +1 freeze each time the running streak count reaches a multiple of 7.
- `maxHeld = 2`.
- A **missed due day** (a due day that is not active and not today) uses 1 freeze if the
  streak is above 0 and a freeze is held. The day is **frozen**: the streak stays alive and
  its count does not grow. If no freeze is held, the streak resets to 0. The inventory
  carries over after a reset.
- Two freezes can cover 2 consecutive missed due days. A longer gap breaks the streak, and
  freezes already used on that gap are lost (same as Duolingo, and simple).
- Off days (nothing due) and today (grace) never use a freeze.
- `startDay`: an epoch-day constant equal to the release date. Before it, freezes are
  neither earned nor used, so existing users' past streaks do not jump on update. This is
  an open question (see the end of this file).

## Architecture
```
domain/progression/streak_freeze.dart  (pure, ~90 lines)
  class StreakFreezeState { int streak; int best; int held; Set<int> frozenDays; }
  StreakFreeze.simulate(activeDays, today, isDue, {startDay}) -> StreakFreezeState
    walks forward from min(activeDays) to today, applying the rules above,
    tracking best = max running streak (frozen days do not add to it).
  With no freezes (startDay > today) the result equals scheduledStreak /
  longestScheduledStreak. A unit test asserts this.

UserStatsRepository
  _streakState(executor, now) -> simulate(DISTINCT grid_x, today, _anyHabitDue)
  recalculate(): streakDays = state.streak           (cached user_stats unchanged)
  getBestStreak(): state.best                        (keeps best >= current)
  getStreakState(): StreakFreezeState                (new, for the UI)

providers/habit_providers.dart
  streakFreezeProvider = FutureProvider<StreakFreezeState>, invalidated in _refreshAll

UI
  StatusHudCard: streak pill + "snowflake xN" chip when held > 0 (Icons.ac_unit)
  MatrixCanvasCard -> PixelMatrixGrid(frozenDays: Set<int>) -> ice tile at row 0 of
    frozen, empty columns (frozen_day_painter.dart, translucent cyan + snowflake glyph)
  StreakFreezeListener (wraps child in AppShell): when the newest frozen day is at least
    today-2 and greater than prefs 'streak_freeze_seen_day', show a SnackBar
    "Streak freeze used on {weekday}. Streak saved!" and store the seen day.
```
Badges (`BadgeEvaluator`) still use raw `longestStreak(activeDays)`, so badges reflect
real activity only. The per-habit streak (`getHabitStreak`) and the XP streak bonus
(`scheduledStreakBefore`) are unchanged. Freezes are global-only.

Data flow on a miss: the user misses Tuesday. On Wednesday the app opens and
`getStats()` runs recalculate, then simulate. Tuesday is frozen and the streak is kept.
The HUD shows the streak and one fewer freeze, the matrix shows an ice tile in Tuesday's
column, and the listener shows the toast once.

## Related Code Files
Create
- `lib/domain/progression/streak_freeze.dart`: rules + state + `simulate`.
- `lib/features/matrix/widgets/frozen_day_painter.dart`.
- `lib/features/home/widgets/streak_freeze_listener.dart`.
- `test/domain/progression/streak_freeze_test.dart`.

Modify
- `lib/data/repositories/user_stats_repository.dart`: use simulate in `recalculate`,
  `getBestStreak`, and the new `getStreakState`.
- `lib/providers/habit_providers.dart`: add `streakFreezeProvider` and invalidate it.
- `lib/features/home/widgets/status_hud_card.dart`: freeze chip.
- `lib/features/home/widgets/matrix_canvas_card.dart`: pass frozen days.
- `lib/features/matrix/widgets/pixel_matrix_grid.dart`: `frozenDays` param, paint layer.
- `lib/app/app_shell.dart`: wrap with `StreakFreezeListener`.
- `lib/l10n/app_en.arb`, `app_vi.arb`: `gridHudFreezes` ("{n} FREEZE"/"{n} BĂNG"),
  `streakFreezeUsed` ("Streak freeze used on {day}. Streak saved!" / "Đã dùng 1 khiên
  băng cho {day}. Chuỗi được giữ!"), `streakFreezeTooltip` ("Earn 1 per 7-day streak,
  hold up to 2" / "Nhận 1 mỗi chuỗi 7 ngày, giữ tối đa 2").
- `test/data/habit_repository_test.dart`: the 'global streak survives days with nothing
  due' case still passes. Add one case where a 7-day streak and 1 miss gives streak 7 kept.
- `test/domain/progression_rules_test.dart`: unchanged (StreakCalculator untouched).

## Implementation Steps
1. Write the `StreakFreeze.simulate` tests first:
   - 7 active days, then a missed due day, then an active day gives streak 8, held 0,
     frozen = {miss}.
   - 6 active days and a miss gives streak 0 (no freeze earned yet).
   - 14 active days gives held 2. A 3-day miss gives streak 0, held 0, and 2 days frozen.
   - Off days are never frozen. Today is never frozen.
   - Held caps at 2 after 21 or more days.
   - Before `startDay`, misses reset with no freeze.
   - Equivalence: `startDay = today+1` matches `scheduledStreak` and
     `longestScheduledStreak` on randomized sets (seeded `Random`, 200 cases).
   - The best streak never drops below the current streak.
2. Implement `streak_freeze.dart` (forward loop, O(days since first check-in)).
3. Wire into `UserStatsRepository`, with one private `_streakState`.
4. Provider + HUD chip + tooltip.
5. Matrix: map frozen epoch days into the visible `MatrixCalendar` window and paint ice at
   the base of empty columns only.
6. Listener + SharedPreferences key + l10n. Run gen-l10n.
7. Run `flutter analyze && flutter test`. Manual check: set the device clock forward by 2
   days after a 7-day demo streak.

## Todo List
- [x] streak_freeze_test.dart (written first)
- [x] streak_freeze.dart
- [x] UserStatsRepository wiring (recalculate, best, state)
- [x] streakFreezeProvider + invalidation
- [x] HUD freeze chip
- [x] Matrix ice tile
- [x] Toast listener + prefs
- [x] l10n en/vi
- [x] Repository regression case

## Success Criteria
- All simulate tests pass, including randomized equivalence with the old calculator when
  freezes are off.
- With freezes off, existing tests pass unchanged, which shows no regression for users
  before `startDay`.
- Manual: after a 7-day streak, skipping one due day shows the same streak number next day,
  1 ice tile and the toast once. A second app launch shows no toast.
- Backfilling a frozen day (phase 02) turns it into an active day, the ice tile disappears
  and the freeze returns.

## Risk Assessment
| Risk | L x I | Mitigation |
|---|---|---|
| Behavior divergence from current streak math | M x H | Randomized equivalence test with freezes off |
| Streak jumps for existing users | M x M | `startDay` = release date (open question) |
| Performance: forward walk each stats read | L x L | At most ~3650 iterations per year of history, on an in-memory set |
| Schedule edits retroactively change frozen days | L x L | Same as today's streak semantics. Documented |
| Toast for an old freeze after a long absence | L x L | Only frozen days at least today-2, plus the seen-day pref |
| Theme unlock by best streak becomes easier | L x L | Intended. Freezes are capped and earned |

## Rollback
Point `recalculate` and `getBestStreak` back to `StreakCalculator` and remove the UI.
Nothing is persisted, so no data cleanup is needed.

## Security Considerations
- No new data and nothing synced, so there is no trust surface. Results come from the
  same check-ins as today.

## Next Steps
- Phase 04 handles l10n review, the full test run, the changelog and the version bump.
- Later (optional): freeze count in the widget snapshot (bump the payload version and keep
  iOS decoding optional).

## Open question
- Should freezes apply retroactively (simpler: no `startDay`, existing users may see the
  streak grow on update), or only from the release date (the default in this plan)?
