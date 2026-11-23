import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'growth_providers.dart';
import 'locale_providers.dart';

/// Prefs key set once the first-run intro was finished or skipped.
const onboardingDoneKey = 'onboarding_done';

final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

/// Whether the first-run intro has been seen; persisted in prefs.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(onboardingDoneKey) ?? false;

  Future<void> complete() async {
    await _set(true);
    // Logs once per install; replays of the intro are ignored.
    await ref.read(usageAnalyticsProvider).onboardingCompleted();
  }

  /// Shows the intro again (Config → Replay intro).
  Future<void> reset() => _set(false);

  Future<void> _set(bool done) async {
    state = done;
    await ref.read(sharedPreferencesProvider).setBool(onboardingDoneKey, done);
  }
}

/// Users updating from a build without onboarding already have habits:
/// mark them as onboarded so the intro only greets fresh installs.
Future<void> markExistingUsersOnboarded(
  SharedPreferences prefs,
  Database db,
) async {
  if (prefs.containsKey(onboardingDoneKey)) return;
  try {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM habits'),
    );
    if ((count ?? 0) > 0) await prefs.setBool(onboardingDoneKey, true);
  } catch (_) {
    // Unknown state: showing the intro once is harmless.
  }
}
