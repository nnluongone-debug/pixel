# Phase 04 — Version bump, tests, AAB, release notes

## Context Links
- `pubspec.yaml` (`version: 1.0.0+1`)
- `android/app/build.gradle.kts` (signing config)
- `integration_test/`, `test/support/localized_test_app.dart`

## Overview
- Priority: High · Status: pending
- Ship `1.0.1+2` to the closed-testing track.

## Requirements
- `versionCode` must be higher than the uploaded build (currently 1).
- All tests green; no analyzer errors.

## Implementation Steps
1. `pubspec.yaml`: `version: 1.0.1+2`.
2. Update test harness: any test that pumps the full app
   (`PixelQuestApp`/integration tests) seeds `onboarding_done: true` via
   `SharedPreferences.setMockInitialValues`, except onboarding tests.
3. `flutter analyze` → fix issues.
4. `flutter test` → all green (delegate to tester agent).
5. Manual check on an Android device/emulator:
   - fresh install → onboarding → Start → shell
   - install 1.0.0 with habits, upgrade → no onboarding
   - Config → Send feedback → mail app opens with version info
   - Language VI → texts translated
6. `flutter build appbundle --release` → verify output
   `build/app/outputs/bundle/release/app-release.aab`.
7. Play Console → Closed testing → Create release → upload AAB, paste notes:

   ```
   <en-US>
   - New: quick intro on first launch explaining bricks, XP and rewards
   - New: Send feedback from Config (includes app version)
   - Replay the intro anytime from Config
   </en-US>
   <vi-VN>
   - Mới: màn giới thiệu khi mở app lần đầu (gạch, XP, phần thưởng)
   - Mới: Gửi góp ý ngay trong Config (kèm phiên bản app)
   - Xem lại hướng dẫn bất cứ lúc nào trong Config
   </vi-VN>
   ```
8. Update `docs/project-changelog.md` (create if missing) with 1.0.1 entry;
   commit `feat: add onboarding flow and in-app feedback`.
9. Message testers: ask them to update and send at least one feedback email
   (keep these emails — evidence for the production questionnaire).

## Todo List
- [ ] version bump
- [ ] test harness prefs seeding
- [ ] analyze + test
- [ ] manual device check
- [ ] build AAB
- [ ] upload to closed track + notes
- [ ] changelog + commit
- [ ] notify testers

## Success Criteria
- Play Console accepts the bundle as version code 2.
- Testers receive the update within the closed track.

## Risk Assessment
- Upload signing key mismatch → use the same keystore as 1.0.0.
- Uploading to a different track than the testers' track resets nothing,
  but they won't receive it → upload to the SAME closed track.

## Security Considerations
- Do not commit keystore / `key.properties`.

## Next Steps
- Collect feedback ~day 7; plan 1.0.2 (archive habits + streak freeze).
