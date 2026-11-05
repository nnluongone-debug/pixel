import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habit_detail/habit_detail_screen.dart';
import 'package:pixel_quest/features/habits/widgets/habit_list_view.dart';
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

  Future<void> settleDb(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<void> pump(WidgetTester tester, Widget home) async {
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
      await container
          .read(habitRepositoryProvider)
          .createHabit(
            name: 'Drink Water',
            type: HabitType.counter,
            target: 4,
            colorHex: '#00D2FF',
            iconName: 'water_drop',
            unit: 'GL',
          );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(home: home),
      ),
    );
    await settleDb(tester);
  }

  testWidgets('home card tap opens the detail; +1 moves the progress', (
    tester,
  ) async {
    await pump(
      tester,
      const Scaffold(body: SingleChildScrollView(child: HabitListView())),
    );
    await tester.tap(find.text('Drink Water'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailScreen), findsOneWidget);
    final detail = find.byType(HabitDetailScreen);
    expect(
      find.descendant(of: detail, matching: find.text('0/4 GL')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detail, matching: find.text('0%')),
      findsOneWidget,
    );

    await tester.tap(find.descendant(of: detail, matching: find.text('+1')));
    await settleDb(tester);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: detail, matching: find.text('1/4 GL')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detail, matching: find.text('25%')),
      findsOneWidget,
    );
  });

  testWidgets('unknown habit id shows a not-found message', (tester) async {
    await pump(tester, const HabitDetailScreen(habitId: 'missing'));
    expect(find.text('This habit no longer exists.'), findsOneWidget);
  });
}
