import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Shared constants between Flutter and the native widgets (WidgetKit / Glance).
abstract final class HomeWidgetConfig {
  static const appGroupId = 'group.com.nnluong.pixelquest';
  static const snapshotKey = 'pixelquest_snapshot';
  static const iosWidgetName = 'PixelQuestWidget';

  /// Fully qualified: the Kotlin package (`com.pixelquest.pixel_quest`) differs
  /// from the applicationId (`com.nnluong.pixelquest`).
  static const androidReceiver =
      'com.pixelquest.pixel_quest.widget.PixelQuestWidgetReceiver';
}

/// Pushes snapshots to the shared store (App Group on iOS, SharedPreferences on
/// Android) and asks the platform to redraw the widget.
/// Failures are logged only: a widget problem must never break the app.
class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  /// iOS and Android ship home screen widgets; elsewhere every call is a no-op.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// First instant after local midnight following [now], plus a few seconds of
  /// slack so the new day has begun when the widget redraws.
  @visibleForTesting
  static DateTime midnightRefreshAfter(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1, 0, 0, 5);

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize() async {
    if (!isSupported || _isAndroid) return; // App Groups are iOS only.
    try {
      await HomeWidget.setAppGroupId(HomeWidgetConfig.appGroupId);
    } catch (e, st) {
      debugPrint('HomeWidget init failed: $e\n$st');
    }
  }

  Future<bool> sync(Map<String, Object?> snapshot) async {
    if (!isSupported) return false;
    try {
      await HomeWidget.saveWidgetData<String>(
        HomeWidgetConfig.snapshotKey,
        jsonEncode(snapshot),
      );
      await HomeWidget.updateWidget(
        iOSName: HomeWidgetConfig.iosWidgetName,
        qualifiedAndroidName: HomeWidgetConfig.androidReceiver,
      );
      if (_isAndroid) await _scheduleMidnightRefresh();
      return true;
    } catch (e, st) {
      debugPrint('HomeWidget sync failed: $e\n$st');
      return false;
    }
  }

  /// Android has no timeline: ask for a redraw just after local midnight so a
  /// stale snapshot rolls over to the new day without opening the app.
  /// Failures are logged only; the display also self-corrects on any redraw.
  Future<void> _scheduleMidnightRefresh() async {
    try {
      await HomeWidget.scheduleWidgetUpdates([
        midnightRefreshAfter(DateTime.now()),
      ], qualifiedAndroidName: HomeWidgetConfig.androidReceiver);
    } catch (e, st) {
      debugPrint('HomeWidget midnight schedule failed: $e\n$st');
    }
  }
}
