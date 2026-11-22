import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anonymous product events (Firebase Analytics) used to see where new
/// players drop off. Never logs habit names or any text the user typed.
///
/// Built without a [FirebaseAnalytics] instance (Firebase unavailable, tests)
/// every call is a no-op. Logging never throws. Milestone events are
/// de-duplicated through [SharedPreferences] so toggling a habit or
/// replaying the intro doesn't inflate funnels.
class UsageAnalytics {
  const UsageAnalytics([this._analytics, this._prefs]);

  static const onboardingLoggedKey = 'analytics_onboarding_logged';
  static const maxLevelKey = 'analytics_max_level';
  static const completedTodayKey = 'analytics_completed_today';

  final FirebaseAnalytics? _analytics;
  final SharedPreferences? _prefs;

  bool get isActive => _analytics != null;

  /// Turns collection on or off natively; the choice persists across
  /// launches on Android and iOS.
  Future<void> setEnabled(bool enabled) async {
    try {
      await _analytics?.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics toggle failed: $e');
    }
  }

  /// Logged once per install, not on "Replay intro".
  Future<void> onboardingCompleted() async {
    final prefs = _prefs;
    if (!isActive || prefs == null) return;
    if (prefs.getBool(onboardingLoggedKey) ?? false) return;
    await prefs.setBool(onboardingLoggedKey, true);
    await _log('onboarding_complete');
  }

  Future<void> habitCreated({
    required String type,
    required String schedule,
    required bool hasReminder,
  }) => _log('habit_created', {
    'habit_type': type,
    'schedule': schedule,
    'has_reminder': hasReminder ? 1 : 0,
  });

  /// A habit reached its daily target (a brick was placed). Once per habit
  /// per [dayKey] (`YYYY-MM-DD`), so uncheck/re-check counts once.
  Future<void> habitCompleted({
    required String habitId,
    required String type,
    required String dayKey,
  }) async {
    final prefs = _prefs;
    if (!isActive || prefs == null) return;
    // Stored as [dayKey, id, id, ...]; a new day starts a fresh list.
    final stored = prefs.getStringList(completedTodayKey) ?? const [];
    final today = stored.isNotEmpty && stored.first == dayKey
        ? stored
        : [dayKey];
    if (today.skip(1).contains(habitId)) return;
    await prefs.setStringList(completedTodayKey, [...today, habitId]);
    await _log('habit_completed', {'habit_type': type});
  }

  /// Firebase's recommended `level_up` event; only for a new highest level.
  Future<void> levelUp(int level) async {
    final prefs = _prefs;
    if (!isActive || prefs == null) return;
    if (level <= (prefs.getInt(maxLevelKey) ?? 0)) return;
    await prefs.setInt(maxLevelKey, level);
    await _log('level_up', {'level': level});
  }

  Future<void> badgeUnlocked(String badgeId) =>
      _log('badge_unlocked', {'badge_id': badgeId});

  Future<void> themeUnlocked(String themeId) =>
      _log('theme_unlocked', {'theme_id': themeId});

  /// Firebase's recommended `share` event.
  Future<void> matrixShared() =>
      _log('share', {'content_type': 'matrix_image', 'item_id': 'matrix'});

  Future<void> reviewRequested(String trigger) =>
      _log('review_requested', {'trigger': trigger});

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics event "$name" failed: $e');
    }
  }
}
