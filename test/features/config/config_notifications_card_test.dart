import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/config/config_notifications_card.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/reminder_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:pixel_quest/services/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/localized_test_app.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('reminder list folds out of the notifications card', (
    tester,
  ) async {
    late Database db;
    late ProviderContainer container;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationsEnabledProvider.overrideWith((ref) async => true),
          reminderSummaryProvider.overrideWith(
            (ref) async => const ReminderSummary(0, null),
          ),
        ],
      );
      await container
          .read(habitRepositoryProvider)
          .createHabit(
            name: 'Wake Up',
            type: HabitType.checklist,
            target: 1,
            colorHex: '#FF9F43',
            iconName: 'sun',
            reminderTimes: const [360],
          );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          home: const Scaffold(
            body: SingleChildScrollView(child: ConfigNotificationsCard()),
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('PUSH_READY'), findsOneWidget);
    expect(find.text('1 HABIT'), findsOneWidget);
    expect(find.text('Wake Up'), findsNothing);

    await tester.tap(find.text('NOTIFICATIONS'));
    await tester.pumpAndSettle();
    expect(find.text('Wake Up'), findsOneWidget);

    await tester.tap(find.text('NOTIFICATIONS'));
    await tester.pumpAndSettle();
    expect(find.text('Wake Up'), findsNothing);
  });
}
