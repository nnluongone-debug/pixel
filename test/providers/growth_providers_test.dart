import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/providers/growth_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer container() => ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  test('analytics is a no-op without Firebase', () async {
    final c = container();
    addTearDown(c.dispose);
    final analytics = c.read(usageAnalyticsProvider);
    expect(analytics.isActive, isFalse);
    await analytics.levelUp(3); // must not throw
  });

  test('usage stats are on by default and the opt-out persists', () async {
    final c = container();
    addTearDown(c.dispose);
    expect(c.read(usageAnalyticsEnabledProvider), isTrue);

    await c.read(usageAnalyticsEnabledProvider.notifier).set(false);
    expect(prefs.getBool(usageAnalyticsEnabledKey), isFalse);

    final fresh = container();
    addTearDown(fresh.dispose);
    expect(fresh.read(usageAnalyticsEnabledProvider), isFalse);
  });
}
