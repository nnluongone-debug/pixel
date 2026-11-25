---
title: "v1.2.0 retention features"
description: "Android home widget, 7-day backfill, earned streak freezes"
status: pending
priority: P1
effort: 18h
branch: main
tags: [retention, widget, android, streak, backfill]
created: 2026-11-25
version-target: 1.2.0+4
blockedBy: []
blocks: []
---

# v1.2.0 (build 4): Retention features

Goal: give users more reasons to come back every day and fewer reasons to quit after one
missed day.

## Scope
1. **Android home screen widget** (Glance via `home_widget` 0.10.0), uses the same JSON
   snapshot as the iOS widget. Small (2x2) and medium (4x2, tap a habit to check it in).
2. **Backfill**: mark or unmark a habit for any of the **last 7 days** (not today, not
   before the habit existed) from the habit detail screen. A backfilled block earns base XP
   only (25).
3. **Streak freeze**: freezes are **earned** (+1 for every 7 active days in the global
   streak, hold max 2) and **used automatically** on a missed due day. They are **derived**
   from check-ins (no new table, migration or sync). Frozen days keep the streak alive but
   do not add to its count. The matrix shows an ice tile on frozen days, and a toast appears
   when a freeze was used.

Out of scope (YAGNI): Android large widget, background (no-app-launch) widget check-in,
backfill from the matrix, partial progress for past days, buying freezes, per-habit
freezes, freeze info in the widget.

## Phases
| # | Phase | Status | File | Effort |
|---|---|---|---|---|
| 1 | Android home widget | pending | [phase-01](phase-01-android-home-widget.md) | 7h |
| 2 | Backfill last 7 days | pending | [phase-02](phase-02-backfill-recent-days.md) | 5h |
| 3 | Earned streak freeze | pending | [phase-03](phase-03-earned-streak-freeze.md) | 4h |
| 4 | Tests, l10n review, changelog, version | pending | [phase-04](phase-04-tests-l10n-changelog-release.md) | 2h |

Dependencies: phases 1 and 2 can run in parallel because they touch no files in common.
Phase 3 runs after phase 2, because both edit `habit_providers.dart` and freeze math must
handle backfilled days. Phase 4 runs last.

## Key decisions
- No DB schema change in this release. `schemaVersion` stays 7. Backfill reuses
  `CheckInRepository.insertForDay/removeForDay`, which already accept any date. Freezes are
  a pure function of `check_ins` and `habits`, like `user_stats`. Synced data, Firestore
  rules and `sync_outbox` do not change.
- Android widget class lives in `com.pixelquest.pixel_quest`, but the applicationId is
  `com.nnluong.pixelquest`, so Dart must call `updateWidget(qualifiedAndroidName: ...)`.
  `androidName` would fail to resolve the class.
- Widget check-in reuses the existing deep link `pixelquest://checkin?habit=<id>`
  (`HomeWidgetLaunchIntent` -> `HomeWidget.widgetClicked`), the same as iOS. No background
  isolate.

## Test command
`flutter analyze && flutter test` (no Makefile/scripts). Android: `flutter build apk
--debug` and `cd android && ./gradlew :app:testDebugUnitTest`.

## Success criteria
- An Android widget can be added from the launcher. It shows today's habits and blocks,
  tapping a habit checks it in, and it updates within 1s of in-app changes and at midnight.
- A habit can be toggled for any of the last 7 days. XP, level, streak, badges, matrix and
  sync all reflect the change, and undo restores the exact previous XP.
- A one-day miss after a 7+ day streak keeps the streak, shows an ice tile, and shows the
  toast once.
- Existing v1.1.0 DBs open unchanged, and `flutter test` is green.
