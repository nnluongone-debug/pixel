# Project Changelog

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
