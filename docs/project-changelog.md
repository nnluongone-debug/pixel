# Project Changelog

## Unreleased — growth
Post-launch growth features.

### Added
- Share matrix image: share button on the matrix card header renders the
  grid as a branded PNG poster (title, cleared %, date, app name) and opens
  the system share sheet with a Play Store link tagged
  `utm_source=share&utm_medium=matrix_image`.
- In-app review prompt (`in_app_review`) after a locally earned badge or
  theme: not in the first 3 days, 60-day cooldown, max 3 asks lifetime.
- Anonymous usage analytics (`firebase_analytics`): onboarding_complete,
  habit_created, habit_completed, level_up, badge_unlocked, theme_unlocked,
  share, review_requested. No habit names or user text. Opt-out switch in
  Config → Feedback & support.

### Changed
- Android: advertising ID permission removed, ad-ID collection and ad
  personalization disabled. iOS: `NSPhotoLibraryAddUsageDescription` for
  "Save image" in the share sheet.
- Privacy policy: new section 3a on anonymous usage statistics.
- New dependencies: `firebase_analytics`, `in_app_review`, `share_plus`.

## 1.0.1 (build 2) — 2026-11-05
Closed-testing update.

### Added
- First-run onboarding (4 pages: habits, brick matrix, rewards, reminders) with
  optional notification permission; shown once, skipped for users updating
  with existing habits; replayable from Config.
- Config "Feedback & support" card: opens a pre-filled email (app version,
  OS, locale) to the support address; falls back to a copyable address.
- App version shown in Config.

### Changed
- Android/iOS: declare `mailto` link queries for package visibility.
- New dependencies: `url_launcher`, `package_info_plus`.
