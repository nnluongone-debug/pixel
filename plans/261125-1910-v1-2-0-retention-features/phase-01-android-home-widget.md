# Phase 01: Android home screen widget

## Context Links
- Dart side: `lib/services/home_widget_snapshot.dart` (JSON payload v1),
  `lib/services/home_widget_sync_service.dart` (iOS-only gate, `updateWidget(iOSName:)`),
  `lib/providers/home_widget_providers.dart` (400ms debounced push and the
  `pixelquest://checkin?habit=<id>` handler).
- iOS reference: `ios/PixelQuestWidget/WidgetSnapshot.swift` (decode + `rolled(to:)` day
  rollover), `SmallWidgetView.swift`, `MediumWidgetView.swift`, `WidgetStrings.swift`
  (en/vi by `snapshot.lang`), `WidgetSkin.swift` (6 skins).
- Plugin: `~/.pub-cache/hosted/pub.dev/home_widget-0.10.0/android/` provides
  `HomeWidgetGlanceWidgetReceiver`, `HomeWidgetGlanceStateDefinition`,
  `HomeWidgetLaunchIntent`/`actionStartActivity`, `HomeWidgetPlugin.getData()` (prefs file
  `HomeWidgetPreferences`) and `scheduleWidgetUpdates`. It already exposes
  `androidx.glance:glance-appwidget:1.2.0` as an `api` dependency.
- Android: `android/app/build.gradle.kts` (AGP 9.0.1, built-in Kotlin 2.3.20, JVM 17),
  `android/settings.gradle.kts`, `AndroidManifest.xml`, `MainActivity.kt`.

## Overview
- Priority: P1 · Status: implemented, pending manual QA · Effort: 7h
- Ship a native Android widget with the same data as iOS, in two sizes:
  - Small (2x2): header, 5x5 micro matrix, done/total, streak.
  - Medium (4x2): 7-day skyline and flow % on the left; up to 3 due habits on the right.
    Tapping a habit checks it in.

## Key Insights
- **Glance or RemoteViews: use Glance.** home_widget 0.10 supports Glance as a first-class
  option (receiver base class, state definition backed by the same SharedPreferences, and
  an `actionStartActivity` helper). Glance is already on the classpath. One Kotlin
  composable per size replaces 2-3 XML layouts plus id binding, and `SizeMode.Responsive`
  handles sizes. The cost is applying the Kotlin Compose compiler plugin.
- **Glance caps Row/Column/Box at 10 children.** Render block grids (skyline/tower) to a
  `Bitmap` with `Canvas` and show it with `Image(ImageProvider(bitmap))`. This avoids the
  cap and keeps the composables small.
- **Package mismatch.** Kotlin namespace is `com.pixelquest.pixel_quest`, but applicationId
  is `com.nnluong.pixelquest`. The plugin resolves `androidName` against applicationId, so
  Dart must pass
  `qualifiedAndroidName: 'com.pixelquest.pixel_quest.widget.PixelQuestWidgetReceiver'`.
- **Interaction parity.** iOS uses `Link(checkInURL)`, which opens the app and lets
  `_handleUri` do the check-in. On Android, `actionStartActivity<MainActivity>(ctx,
  Uri.parse("pixelquest://checkin?habit=$id"))` sets action
  `es.antonborri.home_widget.action.LAUNCH`, and the plugin emits it on
  `HomeWidget.widgetClicked` / `initiallyLaunchedFromHomeWidget`. The existing Dart handler
  needs no change. No intent-filter is needed because the intent is explicit.
- **Day rollover.** iOS rebuilds at midnight from its timeline. Android needs
  `HomeWidget.scheduleWidgetUpdates([nextMidnight + 5s])` from Dart on every sync, plus a
  Kotlin port of `rolled(to:)`, so a stale snapshot shows a fresh day.
- **Strings follow `snapshot.lang`** (the app language), not the device locale. Port
  `WidgetStrings` as a Kotlin `t(en, vi)` helper. Only the gallery label and description
  use `res/values*/strings.xml`.

## Requirements
Functional
- The widget appears in the launcher picker with a localized name/description and a
  preview (`previewLayout` or a static `previewImage` drawable).
- Before any sync it shows an empty state ("OPEN PIXEL QUEST"). With no habits it shows
  "NO HABITS YET".
- Small: tapping anywhere opens the app (`pixelquest://open?homeWidget`).
- Medium: tapping a habit row sends `pixelquest://checkin?habit=<id>`. Counters +1,
  checklists complete, timers only open the app (same as iOS `_handleUri`).
- Updates within ~1s of in-app changes (existing debounce) and right after local midnight.
- Uses the skin colors of the 6 skins (background/text/muted/empty cell/accent). Blocks are
  flat rounded squares. Per-skin block effects are YAGNI.

Non-functional
- Every Kotlin file stays under 200 lines. No new runtime deps beyond Glance (transitive).
- Widget failures never crash the app. Dart already logs and swallows errors.
- minSdk unchanged (flutter default; Glance needs 23+).

## Architecture
```
Flutter (unchanged producer)
  homeWidgetSyncProvider --debounce--> HomeWidgetSnapshot.build() -> JSON
  HomeWidgetSyncService.sync(json):
    saveWidgetData('pixelquest_snapshot', json)   -> SharedPreferences "HomeWidgetPreferences"
    updateWidget(iOSName, qualifiedAndroidName)    -> broadcast APPWIDGET_UPDATE
    [android] scheduleWidgetUpdates([next 00:00:05])
Android
  PixelQuestWidgetReceiver : HomeWidgetGlanceWidgetReceiver<PixelQuestGlanceWidget>
  PixelQuestGlanceWidget.provideGlance():
    prefs = currentState<HomeWidgetGlanceState>().preferences
    snapshot = WidgetSnapshot.parse(prefs.getString(key)).rolledTo(todayKey)
    SizeMode.Responsive{small, medium} -> SmallContent | MediumContent | EmptyContent
  Tap -> actionStartActivity<MainActivity>(uri) -> HomeWidget.widgetClicked -> _handleUri
       -> HabitsController.increment/setCompleted -> providers invalidate -> new snapshot
```

## Related Code Files
Create (Kotlin dir `android/app/src/main/kotlin/com/pixelquest/pixel_quest/widget/`)
- `PixelQuestWidgetReceiver.kt`: receiver, `glanceAppWidget = PixelQuestGlanceWidget()`.
- `PixelQuestGlanceWidget.kt`: state definition, `SizeMode.Responsive`, size routing.
- `WidgetSnapshot.kt`: data classes, `parse(json)` with `org.json`, `rolledTo(todayKey)`,
  `flowPercent`, `dueHabits`. Port of the Swift version.
- `WidgetStrings.kt`: en/vi labels used by small and medium.
- `WidgetSkin.kt`: skin id -> palette (from `WidgetSkin.swift`).
- `BlockGridBitmap.kt`: draws column stacks to a `Bitmap` (cells, spacing, radius, empty
  cells optional).
- `SmallWidgetContent.kt`, `MediumWidgetContent.kt`, `EmptyWidgetContent.kt`.
- `android/app/src/main/res/xml/pixel_quest_widget_info.xml`: `minWidth/minHeight`,
  `targetCellWidth/Height` (2x2), `resizeMode="horizontal|vertical"`,
  `updatePeriodMillis="0"`, `widgetCategory="home_screen"`, description, preview.
- `android/app/src/main/res/layout/glance_default_loading_layout.xml` (optional
  loading view).
- `android/app/src/main/res/values/strings.xml` and `values-vi/strings.xml`:
  `widget_name`, `widget_description` (create if missing, or append).
- `android/app/src/test/kotlin/com/pixelquest/pixel_quest/widget/WidgetSnapshotTest.kt`.

Modify
- `android/settings.gradle.kts`: add
  `id("org.jetbrains.kotlin.plugin.compose") version "2.3.20" apply false`.
- `android/app/build.gradle.kts`: apply `org.jetbrains.kotlin.plugin.compose`;
  `buildFeatures { compose = true }`;
  `implementation("androidx.glance:glance-appwidget:1.2.0")` (explicit);
  `testImplementation("junit:junit:4.13.2")` and
  `testImplementation("org.json:json:20240303")` (the Android `org.json` is stubbed in JVM
  tests).
- `android/app/src/main/AndroidManifest.xml`: add
  `<receiver android:name=".widget.PixelQuestWidgetReceiver" android:exported="true">` with
  the `android.appwidget.action.APPWIDGET_UPDATE` intent-filter and
  `<meta-data android:name="android.appwidget.provider" android:resource="@xml/pixel_quest_widget_info"/>`.
- `lib/services/home_widget_sync_service.dart`:
  - `isSupported`: iOS or Android.
  - `initialize()`: call `setAppGroupId` only on iOS.
  - Add `HomeWidgetConfig.androidReceiver = 'com.pixelquest.pixel_quest.widget.PixelQuestWidgetReceiver'`.
  - `sync()`: `updateWidget(iOSName: ..., qualifiedAndroidName: ...)`. On Android also call
    `scheduleWidgetUpdates([nextMidnight(now) + 5s], qualifiedAndroidName: ...)`, in its own
    try/catch.
  - Fix the "Only iOS ships" doc comments.
- `lib/providers/home_widget_providers.dart`: update the comment "iOS widget" to "home
  widget". Logic is unchanged.
- `lib/services/home_widget_snapshot.dart`: update the doc comment only. Payload stays v1,
  so the iOS decoder is unaffected.

Delete: none.

## Implementation Steps
1. **Build spike (30 min, gate).** Add the compose plugin and `buildFeatures.compose`, plus
   an empty `GlanceAppWidget` that shows `Text("hi")`. Run `flutter build apk --debug`. If
   AGP 9 built-in Kotlin rejects the compose plugin, fall back to classic `HomeWidgetProvider`
   + RemoteViews XML. Keep the same snapshot/strings/skin/bitmap files and replace only the
   content files with `widget_small.xml` and `widget_medium.xml` (3 fixed habit rows).
2. Port `WidgetSnapshot.swift` to `WidgetSnapshot.kt`, including `rolledTo` (progress reset,
   `dueToday` from the `scheduleDays` bitmask, skyline/tower sliding, week reset), with
   `java.time.LocalDate`. Return null on any JSON error.
3. Write `WidgetSnapshotTest.kt`: parse a fixture JSON produced by
   `HomeWidgetSnapshot.build` (copy one from the Dart test), rollover to the next day,
   rollover into the next week, and handle garbage JSON returning null.
4. Port `WidgetStrings` (only the keys small and medium use) and `WidgetSkin` palettes.
5. `BlockGridBitmap.render(columns: List<List<Int>>, rows, cellPx, spacingPx, radiusPx,
   emptyColor?)`: bottom-up stacks, size from `LocalSize` x density, max ~600x600px to stay
   under the RemoteViews bitmap memory limit.
6. Write `SmallWidgetContent`, `MediumWidgetContent` and `EmptyWidgetContent` (Glance `Column`,
   `Row`, `Text`, `Image`), and `clickable(actionStartActivity<MainActivity>(ctx, uri))` on
   the root (small) and on each habit row (medium). Medium shows at most 3 rows, sorted with
   not-done first (same as iOS).
7. Add the receiver, the manifest entry, widget info XML and strings.
8. Dart: platform gate, `qualifiedAndroidName`, midnight schedule. Run `flutter analyze`.
9. Manual QA on an emulator (API 34) and a real device. Add both sizes, check in from the
   widget with the app cold and warm, change skin/language/day (set clock to 23:59), and
   delete a habit.

## Todo List
- [x] Build spike: compose plugin + empty Glance widget builds
- [x] WidgetSnapshot.kt + rollover + JVM unit test
- [x] WidgetStrings.kt, WidgetSkin.kt, BlockGridBitmap.kt
- [x] Small / Medium / Empty contents
- [x] Receiver, manifest, widget info XML, strings (en/vi)
- [x] Dart: isSupported, qualifiedAndroidName, scheduleWidgetUpdates
- [ ] Manual QA matrix (cold/warm tap, midnight, skin, language) - NOT DONE: no device/emulator available

## Success Criteria
- `flutter build apk --debug` and `./gradlew :app:testDebugUnitTest` pass.
- On device, the widget shows the same today done/total and streak as the app's HUD.
- Tapping a medium habit row with the app killed launches the app and increments or
  completes the habit once. The widget refreshes within ~2s.
- After local midnight, the widget shows 0/N with no stale "done" and no app launch needed.
- iOS behavior is unchanged: `test/services/home_widget_snapshot_test.dart` stays green and
  the payload version stays 1.

## Risk Assessment
| Risk | L x I | Mitigation |
|---|---|---|
| Compose plugin incompatible with AGP 9 built-in Kotlin | M x H | Step-1 spike gate, with RemoteViews fallback that keeps all non-UI files |
| Glance 10-child cap truncates grids | H x M | Bitmap rendering for grids; habit rows capped at 3 |
| Wrong class name, so updateWidget fails silently | M x H | `qualifiedAndroidName` const plus a manual check of logcat `HomeWidget sync failed` |
| Deep link handled twice (launch URI and click stream) | L x M | `_handleUri` is idempotent for checklist (`setCompleted`) and counter (guarded by doneToday). Verify cold start |
| Exact alarm permission for midnight update | M x L | `scheduleWidgetUpdates` falls back to inexact alarms. A few minutes late is acceptable, and `rolledTo` fixes the display on any redraw |
| Bitmap too large (TransactionTooLarge) | L x M | Cap the size and use ARGB_8888 at the widget's dp size x density |

## Rollback
The receiver is self-contained. Remove the manifest `<receiver>` and revert
`isSupported` to iOS-only to disable it. No data impact.

## Security Considerations
- The receiver is `exported="true"`, which AppWidget requires. It only renders local prefs.
- Launch intents are explicit to `MainActivity`. `_handleUri` already validates scheme,
  host and that the habit id exists.
- The widget shows habit names on the home screen. This matches iOS and is user-initiated.

## Next Steps
- Optional later: large widget, background check-in via `registerInteractivityCallback`
  (needs DB access from a background isolate), freeze ice tile in the skyline.
