import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/features/onboarding/onboarding_gate.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/onboarding_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/localized_test_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<SharedPreferences> pumpGate(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final instance = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
        child: localizedTestApp(
          locale: locale,
          home: const OnboardingGate(child: Text('SHELL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return instance;
  }

  testWidgets('fresh install shows the intro, Skip finishes it', (
    tester,
  ) async {
    final prefs = await pumpGate(tester);
    expect(find.text('Build habits, pixel by pixel'), findsOneWidget);
    expect(find.text('SHELL'), findsNothing);

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    expect(find.text('SHELL'), findsOneWidget);
    expect(prefs.getBool(onboardingDoneKey), isTrue);
  });

  testWidgets('Next walks all pages, Start finishes', (tester) async {
    final prefs = await pumpGate(tester);
    for (final title in [
      'Every check-in drops a brick',
      'Level up, unlock rewards',
      'Never miss a day',
    ]) {
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('ENABLE REMINDERS'), findsOneWidget);

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();
    expect(find.text('SHELL'), findsOneWidget);
    expect(prefs.getBool(onboardingDoneKey), isTrue);
  });

  testWidgets('finished intro goes straight to the app', (tester) async {
    await pumpGate(tester, prefs: {onboardingDoneKey: true});
    expect(find.text('SHELL'), findsOneWidget);
  });

  testWidgets('intro is translated to Vietnamese', (tester) async {
    await pumpGate(tester, locale: const Locale('vi'));
    expect(find.text('Xây thói quen, từng pixel một'), findsOneWidget);
    expect(find.text('BỎ QUA'), findsOneWidget);
  });
}
