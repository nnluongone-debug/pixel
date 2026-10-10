import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Shared constants between Flutter and the WidgetKit extension.
abstract final class HomeWidgetConfig {
  static const appGroupId = 'group.com.nnluong.pixelquest';
  static const snapshotKey = 'pixelquest_snapshot';
  static const iosWidgetName = 'PixelQuestWidget';
}

/// Pushes snapshots to the App Group and asks WidgetKit to reload.
/// Failures are logged only: a widget problem must never break the app.
class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  /// Only iOS ships home screen widgets; elsewhere every call is a no-op.
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize() async {
    if (!isSupported) return;
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
      await HomeWidget.updateWidget(iOSName: HomeWidgetConfig.iosWidgetName);
      return true;
    } catch (e, st) {
      debugPrint('HomeWidget sync failed: $e\n$st');
      return false;
    }
  }
}
