# Phase 01 — Onboarding state + flow

## Context Links
- `lib/main.dart` (MaterialApp `home:`), `lib/app/app_shell.dart`
- `lib/providers/locale_providers.dart` (prefs-backed Notifier pattern)
- `lib/services/reminder_service.dart:117` `requestPermission()`
- `lib/core/theme/app_theme.dart` (AppColors, AppGlow, AppTextStyles)

## Overview
- Priority: High · Status: pending
- First-launch 4-page intro, skippable, shown once.

## Key Insights
- Prefs pattern already exists (`AppLanguageController`) → mirror it.
- Existing testers updating from 1.0.0 must NOT see onboarding: treat
  "has any habit in DB" as already onboarded (one-time migration check).
- Notification permission is currently requested lazily in the habit editor;
  onboarding page 4 offers it as an optional button (never forced).

## Requirements
Functional
- Pages: (1) Welcome / build habits, (2) Every check-in drops a pixel brick;
  fill rows to clear them for bonus XP, (3) Level up → badges + unlock skins &
  sound packs in the Locker, (4) Reminders: "Enable reminders" button + "Start".
- Skip button on pages 1–3, page dots, Next/Start button.
- Finishing or skipping sets `onboarding_done = true`.
- Optional: "Replay intro" row in Config (cheap, helps testers) — include.

Non-functional
- Each file < 200 lines; EN/VI strings only via l10n; neo-pixel styling.

## Architecture
```
main.dart home: OnboardingGate
  OnboardingGate (ConsumerWidget)
    watch onboardingDoneProvider
      true  -> DayRolloverRefresher(AppShell)
      false -> OnboardingScreen(onDone: controller.complete)
```
`OnboardingController extends Notifier<bool>`:
- `build()`: prefs `onboarding_done` ?? false.
- `complete()`: set state true + persist.
- `reset()`: set false + persist (Replay intro).
- Legacy check: in `main()` after DB open, if flag missing and habits table
  non-empty → write `onboarding_done=true` (keeps provider synchronous).

## Related Code Files
Create
- `lib/providers/onboarding_providers.dart` — controller + provider
- `lib/features/onboarding/onboarding_gate.dart`
- `lib/features/onboarding/onboarding_screen.dart` — PageView, dots, buttons
- `lib/features/onboarding/onboarding_page.dart` — one page (icon/art, title, body)
- `lib/features/onboarding/onboarding_brick_art.dart` — small animated pixel
  bricks illustration (pure widgets, reuse AppColors palette)
- `test/features/onboarding/onboarding_screen_test.dart`
- `test/providers/onboarding_providers_test.dart`

Modify
- `lib/main.dart` — legacy-user flag migration, `home: OnboardingGate()`
- `lib/features/config/config_screen.dart` — "Replay intro" entry (can live in
  the feedback/about card from phase 02 to avoid a new card)

## Implementation Steps
1. Add `onboarding_providers.dart` mirroring `AppLanguageController`.
2. In `main.dart`, after `AppDatabase.open()` + prefs: if
   `!prefs.containsKey('onboarding_done')` and habit count > 0 →
   `prefs.setBool('onboarding_done', true)`. Use the existing habit repository
   / a `SELECT COUNT(*) FROM habits` via `db`; wrap in try/catch (default:
   show onboarding).
3. Build `OnboardingPage` (title `AppTextStyles.headlineLg`, body, art slot).
4. Build `OnboardingScreen`: `PageController`, 4 pages, dots, Skip/Next/Start.
   Page 4: "Enable reminders" calls `ref.read(reminderServiceProvider)
   .requestPermission()`; show granted/denied state text; never blocks Start.
5. `OnboardingGate` switches between screen and shell.
6. Widget tests: shows on fresh prefs, Skip → shell, Next×3 → Start → shell,
   not shown when flag true. Provider test: complete()/reset() persist.

## Todo List
- [ ] onboarding_providers.dart
- [ ] legacy-user migration in main.dart
- [ ] onboarding_page.dart + brick art
- [ ] onboarding_screen.dart
- [ ] onboarding_gate.dart + wire into main.dart
- [ ] Replay intro entry in Config
- [ ] tests

## Success Criteria
- Fresh install → onboarding; after Start/Skip, relaunch → shell directly.
- Upgrade with existing habits → shell directly.
- Replay intro shows it again.

## Risk Assessment
- Gate rebuild flicker: provider is synchronous (prefs preloaded) → none.
- Permission dialog on Android 13+ only; on older versions request returns
  true immediately — fine.
- Integration tests in `integration_test/` may start at AppShell → set
  `onboarding_done=true` in their prefs setup (`SharedPreferences.setMockInitialValues`).

## Security Considerations
- Only a local boolean; no PII.

## Next Steps
- Phase 03 strings; phase 04 tests/build.
