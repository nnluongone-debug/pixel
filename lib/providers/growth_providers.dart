import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/review/review_prompter.dart';
import '../services/usage/usage_analytics.dart';
import 'account_providers.dart';
import 'locale_providers.dart';

/// Anonymous usage events; a no-op when Firebase is unavailable. Analytics
/// must never break a habit action, so a failing instance also degrades to
/// the no-op.
final usageAnalyticsProvider = Provider<UsageAnalytics>((ref) {
  if (!ref.watch(firebaseAvailableProvider)) return const UsageAnalytics();
  try {
    return UsageAnalytics(
      FirebaseAnalytics.instance,
      ref.watch(sharedPreferencesProvider),
    );
  } catch (e) {
    debugPrint('Analytics unavailable: $e');
    return const UsageAnalytics();
  }
});

/// Prefs key for the Config "Share anonymous usage stats" switch.
const usageAnalyticsEnabledKey = 'usage_analytics_enabled';

final usageAnalyticsEnabledProvider =
    NotifierProvider<UsageAnalyticsEnabledController, bool>(
      UsageAnalyticsEnabledController.new,
    );

/// Opt-out switch for usage analytics; on by default (disclosed in the
/// privacy policy). Firebase keeps the native flag across launches.
class UsageAnalyticsEnabledController extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(usageAnalyticsEnabledKey) ??
      true;

  Future<void> set(bool enabled) async {
    state = enabled;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(usageAnalyticsEnabledKey, enabled);
    await ref.read(usageAnalyticsProvider).setEnabled(enabled);
  }
}

final reviewPrompterProvider = Provider<ReviewPrompter>(
  (ref) => ReviewPrompter(
    prefs: ref.watch(sharedPreferencesProvider),
    analytics: ref.watch(usageAnalyticsProvider),
  ),
);
