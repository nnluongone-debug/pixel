# Phase 04: Tests, l10n review, changelog, version

## Context Links
- `pubspec.yaml` (`version: 1.1.0+3`)
- `docs/project-changelog.md` (format: `## 1.1.0 (build 3) — date`, then Added/Changed)
- `lib/l10n/app_en.arb`, `app_vi.arb`, `l10n.yaml`
- `store/google-play/listing.md` (what's new / feature bullets)
- The previous release plan, `plans/261105-1857-closed-test-onboarding-and-feedback/phase-04-*`

## Overview
- Priority: P1 · Status: pending · Effort: 2h
- Final check that phases 1-3 hold together, then prepare release `1.2.0+4`.

## Key Insights
- Phases 2 and 3 add their own en/vi keys so they compile on their own. This phase reviews
  them together for tone and consistency. Vietnamese HUD labels are upper-case and short,
  like the existing `gridHud*` keys.
- No DB migration ships in this release (`schemaVersion` stays 7). The migration tests
  must still pass, which shows the v1.1.0 schema is untouched.
- There is no Makefile or scripts dir. The commands are below.

## Requirements
- Every new user-facing string exists in both `.arb` files. `flutter gen-l10n` produces no
  untranslated-messages warnings.
- `flutter analyze` is clean and `flutter test` is green.
- `./gradlew :app:testDebugUnitTest` (Kotlin widget tests) is green.
- `flutter build appbundle` reports `1.2.0 (4)`.

## Test matrix
| Area | Unit | Integration (ffi DB) | Widget/UI | Manual/E2E |
|---|---|---|---|---|
| Android widget | `WidgetSnapshotTest.kt` (parse, rollover) | n/a | n/a | Add widget, tap check-in cold/warm, midnight, skin, language |
| Snapshot (shared) | `test/services/home_widget_snapshot_test.dart` (unchanged) | n/a | n/a | iOS widget still renders |
| Backfill | n/a | `test/data/habit_backfill_repository_test.dart` | `test/features/habit_detail/habit_recent_days_strip_test.dart`, `habit_detail_screen_test.dart` (regression) | Two-device sync of a backfilled block |
| Freeze | `test/domain/progression/streak_freeze_test.dart` | `test/data/habit_repository_test.dart` (+1 case) | HUD chip in `test/features/matrix/status_hud_date_test.dart` or a new HUD test | Clock-forward miss scenario, toast once |
| Regression | `test/domain/progression_rules_test.dart`, `heatmap_and_badges_test.dart`, `history_and_summary_test.dart` | `app_database_migration_test.dart`, `sync_outbox_test.dart`, `test/services/sync/*` | `stats_screen_test.dart`, `badge_unlock_test.dart`, `locker_test.dart` (theme unlock by best streak) | n/a |

## Related Code Files
Modify
- `pubspec.yaml`: `version: 1.2.0+4`.
- `docs/project-changelog.md`: new top entry `## 1.2.0 (build 4) — <date>`.
  - Added: Android home widget, 7-day backfill, earned streak freezes.
  - Changed: best streak counts frozen days, backfilled blocks earn base XP.
- `lib/l10n/app_en.arb`, `app_vi.arb`: review only.
- `store/google-play/listing.md`: add the widget and streak freeze to the feature bullets
  (en + vi), if the listing has them.
- `README.md` or the docs feature list: mention the Android widget, if one exists.

## Implementation Steps
1. `flutter gen-l10n` and check the untranslated output.
2. Read every new vi string in context (screenshots via flutter-skill on the emulator).
3. Run `flutter analyze`, then `flutter test`, then `cd android && ./gradlew
   :app:testDebugUnitTest`.
4. Run the manual QA from phases 1-3 on one Android device and one iOS device (regression).
5. Bump the version, write the changelog entry and update the store bullets.
6. Run `flutter build appbundle --release` and confirm `1.2.0 (4)`.
7. Commit with conventional commits per phase (`feat(widget): ...`, `feat(backfill): ...`,
   `feat(streak): ...`, `chore: release v1.2.0 (build 4)`). Push only when the user asks.

## Todo List
- [x] gen-l10n clean, vi review
- [x] analyze + flutter test + gradle unit tests green
- [ ] Manual QA Android + iOS regression
- [x] Version bump 1.2.0+4
- [x] Changelog + store bullets
- [ ] AAB built

## Success Criteria
- All automated checks are green, and the AAB is versioned `1.2.0 (4)`.
- The changelog entry lists all three features with user-facing wording.

## Risk Assessment
| Risk | L x I | Mitigation |
|---|---|---|
| vi strings too long for HUD chips | M x L | Short forms ("BĂNG"), check on a 320dp-wide device |
| Release signing missing locally | M x M | Same as the 1.0.1 plan: needs `android/key.properties` |
| Hidden regression in theme unlocks (best streak) | L x M | Run `locker_test.dart` and `theme_catalog_test.dart` |

## Rollback
Each feature has its own commit. Revert a feature commit and rebuild. No migrations ship,
so an older build can open the DB.

## Security Considerations
- No new permissions besides the widget receiver. Privacy policy is unchanged (no new
  data collected or synced).

## Next Steps
- Upload to the Play internal track, then production. Watch `habit_completed` and retention
  in analytics.
