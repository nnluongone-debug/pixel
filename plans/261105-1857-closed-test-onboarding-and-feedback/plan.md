---
status: in-progress
created: 2026-11-05
version-target: 1.0.1+2
blockedBy: []
blocks: []
---

# Closed-test update 1.0.1+2: Onboarding + In-app Feedback

Goal: ship a meaningful update during the Google Play closed test (12 testers /
14 days) so the "Apply for production" questionnaire can cite real
tester-driven improvements.

## Scope
1. First-run **onboarding** (4 pages) explaining habits, the pixel brick
   matrix, XP/badges/locker, and offering reminder permission.
2. **Feedback card** in Config: opens the mail app with a pre-filled
   subject/body (app version, build, OS, locale) to `nnluong.one@gmail.com`
   (support email already used in `store/google-play/listing.md`).
3. Version bump `1.0.0+1` → `1.0.1+2`, release notes EN/VI for testers.

Out of scope (YAGNI): analytics on onboarding, Google Form, screenshots in
feedback, device_info_plus (Platform.operatingSystemVersion is enough).

## Phases
| # | Phase | Status | File |
|---|---|---|---|
| 1 | Onboarding state + flow | done | [phase-01](phase-01-onboarding-state-and-flow.md) |
| 2 | Feedback card in Config | done | [phase-02](phase-02-feedback-card.md) |
| 3 | Localization EN + VI | done | [phase-03](phase-03-localization.md) |
| 4 | Version bump, tests, AAB, release notes | in-progress (needs release keystore) | [phase-04](phase-04-version-tests-and-release.md) |

Phases 1 and 2 are independent; phase 3 adds the strings both need (can be
done first or alongside); phase 4 runs last.

## Key dependencies
- New packages: `url_launcher`, `package_info_plus`.
- Reuse: `sharedPreferencesProvider` (`lib/providers/locale_providers.dart`),
  `ReminderService.requestPermission()` (`lib/services/reminder_service.dart:117`),
  `AppGlow.card()`, `AppColors`, `AppTextStyles`, `EditorChip`.
- Android `<queries>` entry for `mailto:` (package visibility, API 30+).

## Success criteria
- Fresh install shows onboarding once; skip/finish never shows it again.
- Existing users who already have habits do not see onboarding after update.
- Feedback button opens a mail app with version info; graceful snackbar
  when no mail app exists.
- `flutter analyze` clean, `flutter test` green, `flutter build appbundle`
  produces `1.0.1 (2)`.
