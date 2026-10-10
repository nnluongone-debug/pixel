# Neo-Matrix UI implementation (Stitch design)

Design source: `~/Downloads/stitch_pixelhabit_retro_tracker/` (4 screens: `screen.png` + `code.html`, `DESIGN.md`).

Decisions (user, 2026-10-10): main grid = Stitch 10 day columns x 18 rows; Stitch palette
(mint #2DE38E, cyan #00D2FF, amber #F9CA24, lavender #A29BFE, rose #FF7675); build iOS widgets now.

## Phase 0 — Foundation (lead) — DONE
- Palette tokens in `lib/core/theme/app_theme.dart` (+ emoji font fallback)
- Schema v3: `habits.schedule_days` (bitmask Mon=bit0), `habits.reminder_minutes`; `HabitSchedule`
- Schedule-aware habit streaks; line-clear row bonus XP (`XpRules.rowBonus`)
- App shell: `lib/app/app_shell.dart`, `neo_top_bar.dart`, `neo_bottom_nav.dart`; Tasks tab
- Deps: flutter_local_notifications, timezone, flutter_timezone, home_widget

## Phase 1 — Parallel (one agent each, strict file ownership)
| Agent | Scope | Owns |
|---|---|---|
| grid | Grid View screen, 10x18 matrix, HUD, habit cards restyle | `lib/features/home/**` (except quick_add_habit_sheet.dart), `lib/features/matrix/**`, `lib/features/habits/**`, `lib/providers/matrix_providers.dart`, `test/features/matrix/**`, `test/features/habits/**` |
| stats | Analytics screen, badges | `lib/features/stats/**`, `lib/domain/analytics/**`, `lib/data/repositories/analytics_repository.dart`, `lib/providers/analytics_providers.dart`, `test/features/stats/**`, `test/data/analytics_repository_test.dart`, `test/domain/analytics/**` |
| editor | New/Edit Habit modal, reminders, Config tab | `lib/features/habit_editor/**`, `lib/features/config/**`, `lib/services/reminder_*.dart`, `lib/providers/reminder_providers.dart`, delete `lib/features/home/widgets/quick_add_habit_sheet.dart`, `ios/Runner/AppDelegate.swift`, `android/app/**`, `test/features/habit_editor/**`, `test/services/reminder_*` |
| widgets | iOS WidgetKit (2x2, 2x4, 4x4) + Flutter sync + deep links | `ios/**` (except AppDelegate.swift), `lib/services/home_widget_*.dart`, `lib/providers/home_widget_providers.dart`, `test/services/home_widget_*` |

Shared files owned by lead (agents must NOT edit): `lib/main.dart`, `lib/app/**`, `lib/core/**`,
`lib/data/**` (except analytics_repository), `lib/domain/progression/**`, `lib/providers/habit_providers.dart`,
`lib/providers/repository_providers.dart`, `pubspec.yaml`.

## Phase 2 — Integration (lead)
Wire reminder + widget init/sync into `main.dart`/`AppShell`, run all tests, code review, simulator check.
