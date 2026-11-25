# Project Changelog

## 1.2.0 (build 4) — 2026-11-25
Retention features.

### Added
- Android home screen widget (Jetpack Glance, small + medium): shows the
  matrix and today's habits; tapping a habit opens the app and checks it in
  via `pixelquest://checkin?habit=<id>&day=<today>`. Timer habits open the
  app instead. Refreshes just after local midnight.
- Backfill: habit detail shows the last 7 days as chips to mark/unmark a
  forgotten day (never before the habit's creation day, today excluded).
  Backfilled blocks earn base XP only (25, no streak/row bonus); un-marking
  an on-time block with bonus XP asks for confirmation.
- Earned streak freezes: +1 per 7-day streak (hold max 2), auto-spent on a
  missed due day so the streak survives. Derived from check-ins (no new
  stored data or sync); counted from 2026-11-26. Snowflake chip in the HUD,
  ice tiles on frozen days, one-time toast when a freeze is used.

### Changed
- Best streak counts frozen days. Badges, per-habit streaks and the XP
  streak bonus still use real activity only.
- Widget check-in links carry the day and are ignored when stale or
  relaunched from Recents (prevents replayed check-ins).
- Android: Flutter deep linking disabled (home_widget owns the scheme),
  `HomeWidgetScheduledUpdateReceiver` registered, Compose + Glance added.
- `habit_completed` analytics only fires for today's check-ins.

## 1.1.0 (build 3) — 2026-11-23
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
