import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/habit_backfill_repository.dart';
import 'package:pixel_quest/features/habit_detail/habit_recent_days_strip.dart';
import 'package:pixel_quest/providers/habit_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/localized_test_app.dart';
import '../../support/silent_sound_service.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late Database db;
  late ProviderContainer container;
  late Habit habit;

  Future<void> settleDb(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> pump(WidgetTester tester, {required bool oldHabit}) async {
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
          silentSoundOverride,
        ],
      );
      habit = await container
          .read(habitRepositoryProvider)
          .createHabit(
            name: 'Read',
            type: HabitType.checklist,
            target: 1,
            colorHex: '#00D2FF',
            iconName: 'book',
          );
      if (oldHabit) {
        await db.update('habits', {
          'created_at': DateTime.now()
              .subtract(const Duration(days: 30))
              .toUtc()
              .toIso8601String(),
        });
        habit = (await container
            .read(habitRepositoryProvider)
            .getHabit(habit.id))!;
      }
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          home: Scaffold(body: HabitRecentDaysStrip(habit: habit)),
        ),
      ),
    );
    await settleDb(tester);
  }

  testWidgets('renders 7 chips, toggles yesterday on and off', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pump(tester, oldHabit: true);
    expect(find.byType(GestureDetector), findsNWidgets(7));
    final today = DateKeys.fromDate(DateTime.now());
    final yesterday = DateKeys.shift(today, -1);
    Future<Set<String>> done() async => (await tester.runAsync(
      () => container
          .read(habitBackfillRepositoryProvider)
          .doneDays(habit.id, yesterday, yesterday),
    ))!;

    final chip = find.byType(GestureDetector).last;
    await tester.tap(chip);
    await settleDb(tester);
    expect(await done(), {yesterday});
    expect(container.read(habitRecentDaysProvider(habit.id)).value, {
      yesterday,
    });

    await tester.tap(chip);
    await settleDb(tester);
    expect(await done(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('days before creation are disabled', (tester) async {
    await pump(tester, oldHabit: false);
    final today = DateKeys.fromDate(DateTime.now());
    final window = HabitBackfillRepository.windowKeys(today);
    expect(
      window.where((k) => HabitBackfillRepository.isEditable(habit, k, today)),
      isEmpty,
    );
    await tester.tap(find.byType(GestureDetector).last);
    await settleDb(tester);
    expect(container.read(habitRecentDaysProvider(habit.id)).value, isEmpty);
  });
}
