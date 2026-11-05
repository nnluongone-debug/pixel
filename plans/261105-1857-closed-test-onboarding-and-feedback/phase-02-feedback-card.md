# Phase 02 — Feedback card in Config

## Context Links
- `lib/features/config/config_screen.dart`, `config_language_card.dart` (card style)
- `android/app/src/main/AndroidManifest.xml` (`<queries>` block, line ~53)
- `ios/Runner/Info.plist` (LSApplicationQueriesSchemes)
- Support email: `store/google-play/listing.md` → `nnluong.one@gmail.com`

## Overview
- Priority: High · Status: pending
- "Send feedback" card at the bottom of Config, plus app version display and
  "Replay intro" (from phase 01).

## Key Insights
- Testers' feedback is evidence for the production-access questionnaire.
- `mailto:` on Android 11+ needs a `<queries>` intent for `SENDTO mailto`,
  otherwise `canLaunchUrl` returns false.
- Version/build from `package_info_plus`; OS via `dart:io Platform`.

## Requirements
Functional
- Card: title "Feedback & support", short line "Found a bug or have an idea?",
  buttons: "Send feedback" (primary), "Replay intro" (secondary).
- Footer text: `PixelHabit v1.0.1 (2)`.
- Email: to support address; subject `[PixelHabit 1.0.1+2] Feedback`;
  body: blank lines for user text, then a separator and
  `App: 1.0.1 (2) · OS: android 14 · Locale: vi`.
- If no mail app: snackbar with the address + copy-to-clipboard action.

Non-functional
- No personal data beyond version/OS/locale; user sees the body before sending.

## Architecture
```
FeedbackService (lib/services/feedback_service.dart)
  static const supportEmail
  Future<Uri> buildMailUri(locale)   // pure-ish, testable via injected info
  Future<bool> open(locale)          // launchUrl, false on failure
appVersionProvider (FutureProvider<PackageInfo>) in
  lib/providers/app_info_providers.dart
ConfigFeedbackCard (lib/features/config/config_feedback_card.dart)
```

## Related Code Files
Create
- `lib/services/feedback_service.dart`
- `lib/providers/app_info_providers.dart`
- `lib/features/config/config_feedback_card.dart`
- `test/services/feedback_service_test.dart`
- `test/features/config/config_feedback_card_test.dart`

Modify
- `pubspec.yaml` — add `url_launcher`, `package_info_plus`
- `lib/features/config/config_screen.dart` — append card
- `android/app/src/main/AndroidManifest.xml` — add to `<queries>`:
  ```xml
  <intent>
      <action android:name="android.intent.action.SENDTO"/>
      <data android:scheme="mailto"/>
  </intent>
  ```
- `ios/Runner/Info.plist` — `LSApplicationQueriesSchemes` → `mailto`

## Implementation Steps
1. `flutter pub add url_launcher package_info_plus`.
2. Manifest + Info.plist query entries.
3. `FeedbackService.buildMailUri({required PackageInfo info, required
   String locale})` — build with `Uri(scheme: 'mailto', path: email,
   query: _encode({...}))` (encode with `Uri.encodeComponent`, NOT
   `queryParameters`, which turns spaces into `+` in many mail apps).
4. `open()` → `launchUrl(uri)` in try/catch; return bool.
5. `ConfigFeedbackCard` (ConsumerWidget) styled like other cards
   (`AppGlow.card()`, icon `Icons.mail_outline`, `AppColors.amber`).
   On failure → SnackBar with address + "Copy" (Clipboard.setData).
6. Replay intro button → `ref.read(onboardingDoneProvider.notifier).reset()`.
7. Tests: URI contains encoded subject/body/version; card renders version;
   failure path shows snackbar (inject service via provider override).

## Todo List
- [ ] deps
- [ ] manifest + plist queries
- [ ] feedback_service.dart
- [ ] app_info_providers.dart
- [ ] config_feedback_card.dart + wire into config_screen
- [ ] tests

## Success Criteria
- On a real Android device, tapping opens Gmail with pre-filled fields.
- Emulator without mail app → snackbar, no crash.

## Risk Assessment
- `package_info_plus` in widget tests: use `PackageInfo.setMockInitialValues`.
- Some mail clients ignore body line breaks → use `%0D%0A` via encodeComponent of `\r\n`.

## Security Considerations
- No secrets; email is public (already in store listing).
- Body contains no user id/email.

## Next Steps
- Phase 03 strings, phase 04 release.
