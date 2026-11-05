# Phase 03 — Localization EN + VI

## Context Links
- `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`, `l10n.yaml`
- `lib/core/l10n/l10n.dart` (`context.l10n`)

## Overview
- Priority: High · Status: pending
- Add every user-facing string from phases 01–02 to both ARB files, then
  regenerate (`flutter gen-l10n`, or automatic on `flutter pub get`/build).

## Keys (EN / VI)
| Key | EN | VI |
|---|---|---|
| onboardingSkip | Skip | Bỏ qua |
| onboardingNext | Next | Tiếp |
| onboardingStart | Start | Bắt đầu |
| onboardingWelcomeTitle | Build habits, pixel by pixel | Xây thói quen, từng pixel một |
| onboardingWelcomeBody | Add the habits you want to keep and check them in every day. | Thêm thói quen bạn muốn duy trì và check-in mỗi ngày. |
| onboardingMatrixTitle | Every check-in drops a brick | Mỗi lần check-in thả một viên gạch |
| onboardingMatrixBody | Fill a full row to clear it and earn bonus XP. | Lấp đầy một hàng để xoá hàng và nhận thêm XP. |
| onboardingRewardsTitle | Level up, unlock rewards | Lên cấp, mở khoá phần thưởng |
| onboardingRewardsBody | Earn badges and unlock brick skins and sound packs in the Locker. | Nhận huy hiệu, mở khoá skin gạch và gói âm thanh trong Locker. |
| onboardingRemindersTitle | Never miss a day | Không bỏ lỡ ngày nào |
| onboardingRemindersBody | Turn on reminders so PixelHabit can nudge you at the right time. | Bật nhắc nhở để PixelHabit nhắc bạn đúng giờ. |
| onboardingEnableReminders | Enable reminders | Bật nhắc nhở |
| onboardingRemindersOn | Reminders enabled | Đã bật nhắc nhở |
| onboardingRemindersDenied | You can turn them on later in Settings | Bạn có thể bật sau trong Cài đặt |
| configFeedbackTitle | Feedback & support | Góp ý & hỗ trợ |
| configFeedbackBody | Found a bug or have an idea? Tell us! | Gặp lỗi hoặc có ý tưởng? Hãy cho chúng tôi biết! |
| configFeedbackSend | Send feedback | Gửi góp ý |
| configReplayIntro | Replay intro | Xem lại hướng dẫn |
| configAppVersion | Version {version} ({build}) | Phiên bản {version} ({build}) |
| feedbackNoMailApp | No email app found. Write to {email} | Không tìm thấy ứng dụng email. Hãy gửi tới {email} |
| feedbackCopy | Copy | Sao chép |
| feedbackEmailSubject | Feedback | Góp ý |

Placeholders (`version`, `build`, `email`) need `@key` metadata in `app_en.arb`.

## Implementation Steps
1. Add keys + metadata to `app_en.arb`, translations to `app_vi.arb`.
2. Run `flutter gen-l10n`; commit regenerated `app_localizations*.dart`
   (repo already tracks them).
3. Replace any hard-coded strings left in phases 01–02.

## Todo List
- [ ] app_en.arb
- [ ] app_vi.arb
- [ ] gen-l10n

## Success Criteria
- Switching language in Config updates onboarding/feedback text.
- `flutter analyze` reports no missing getters.

## Risk Assessment
- Long VI strings overflow on small screens → use `Expanded`/`softWrap`,
  test at 360dp width.

## Security Considerations
- None.

## Next Steps
- Phase 04.
