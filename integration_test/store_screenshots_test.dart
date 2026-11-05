import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/features/locker/locker_entry_card.dart';
import 'package:pixel_quest/firebase_options.dart';
import 'package:pixel_quest/main.dart';
import 'package:pixel_quest/providers/account_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/onboarding_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'store_demo_seeder.dart';

/// Captures Google Play / App Store screenshots with realistic demo data.
/// Run (wipes the simulator's app data):
///   SCREENSHOT_DIR=build/screenshots/vi flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/store_screenshots_test.dart \
///     --dart-define=LANG=vi -d SIMULATOR_ID
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const lang = String.fromEnvironment('LANG', defaultValue: 'vi');

  testWidgets('store screenshots', (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final db = await AppDatabase.open();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString(
      'app_language',
      lang == 'vi' ? AppLanguage.vietnamese.name : AppLanguage.english.name,
    );
    await prefs.setBool(onboardingDoneKey, true);
    await StoreDemoSeeder.seed(db, lang: lang);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseAvailableProvider.overrideWithValue(true),
        ],
        child: const PixelQuestApp(),
      ),
    );

    Future<void> settle([int seconds = 3]) async {
      for (var i = 0; i < seconds * 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> shot(String name) async {
      await settle();
      await binding.takeScreenshot(name);
    }

    await settle(5);
    await shot('01-matrix');

    await tester.tap(find.byIcon(Icons.layers_outlined));
    await shot('02-tasks');

    await tester.tap(find.byIcon(Icons.equalizer_rounded));
    await shot('03-stats');

    await tester.tap(find.byIcon(Icons.add));
    await settle();
    await tester.enterText(
      find.byType(TextField).first,
      lang == 'vi' ? 'uống' : 'dr',
    );
    await shot('04-templates');
    Navigator.of(tester.element(find.byType(TextField).first)).pop();
    await settle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle();
    await tester.scrollUntilVisible(find.byType(LockerEntryCard), 200);
    await tester.tap(find.byType(LockerEntryCard));
    await shot('05-themes');
  });
}
