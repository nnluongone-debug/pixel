import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habit_editor/habit_editor_sheet.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../support/localized_test_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late Database db;
  late ProviderContainer container;

  Future<void> pumpSheet(
    WidgetTester tester, {
    Habit? habit,
    Locale locale = const Locale('en'),
  }) async {
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
        ],
      );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          locale: locale,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => HabitEditorSheet.show(context, habit: habit),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Scrolls the sheet body until [finder] is on screen, then taps it.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    final body = find.byType(SingleChildScrollView);
    for (var i = 0; i < 6; i++) {
      if (tester.getRect(finder).bottom <= tester.getRect(body).bottom) break;
      await tester.drag(body, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> settleDb(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
  }

  Future<List<Habit>> habits(WidgetTester tester) async {
    late List<Habit> result;
    await tester.runAsync(
      () async =>
          result = await container.read(habitRepositoryProvider).getHabits(),
    );
    return result;
  }

  testWidgets('creates a habit with the chosen options', (tester) async {
    await pumpSheet(tester);
    expect(find.text('NEW HABIT'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Read 20 Pages');
    await tapVisible(tester, find.text('Minutes'));
    await tapVisible(tester, find.byTooltip('Increase quota'));
    await tapVisible(tester, find.text('CUSTOM'));
    await tapVisible(tester, find.text('W'));
    await tapVisible(tester, find.byType(Switch));
    final create = find.textContaining('CREATE HABIT');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await settleDb(tester);
    await tester.pumpAndSettle();

    final saved = await habits(tester);
    expect(saved, hasLength(1));
    final h = saved.single;
    expect(h.name, 'Read 20 Pages');
    expect(h.type, HabitType.timer);
    expect(h.target, 35); // 30 default + 5 step
    expect(h.unit, '');
    expect(h.schedule.dueWeekdays, [DateTime.monday, DateTime.wednesday]);
    expect(h.reminderTimes, [20 * 60 + 30]);
    expect(find.text('NEW HABIT'), findsNothing);
  });

  testWidgets('repeat mode persists every, from and to', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), 'Stretch');
    await tapVisible(tester, find.byType(Switch));
    await tapVisible(tester, find.text('REPEAT'));
    await tapVisible(tester, find.text('2h'));
    expect(find.textContaining('prompts a day'), findsOneWidget);
    final create = find.textContaining('CREATE HABIT');
    await tapVisible(tester, create);
    await settleDb(tester);
    await tester.pumpAndSettle();

    final h = (await habits(tester)).single;
    expect(h.reminderEvery, 120);
    expect(h.reminderFrom, 8 * 60);
    expect(h.reminderTo, 22 * 60);
    expect(h.hasReminder, isTrue);
  });

  testWidgets('specific mode stores no repeat interval', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), 'Stretch');
    await tapVisible(tester, find.byType(Switch));
    await tapVisible(tester, find.textContaining('CREATE HABIT'));
    await settleDb(tester);
    await tester.pumpAndSettle();

    final h = (await habits(tester)).single;
    expect(h.reminderEvery, isNull);
    expect(h.reminderTimes, [20 * 60 + 30]);
  });

  testWidgets('typing suggests a template that fills the form', (tester) async {
    await pumpSheet(tester, locale: const Locale('vi'));
    await tester.enterText(find.byType(TextField), 'uong');
    await tester.pump();
    expect(find.text('Uống nước'), findsOneWidget);
    expect(find.text('Uống vitamin'), findsOneWidget);

    await tester.tap(find.text('Uống nước'));
    await tester.pumpAndSettle();
    expect(find.text('GỢI Ý MẪU · CHẠM ĐỂ ĐIỀN SẴN'), findsNothing);
    await tapVisible(tester, find.textContaining('TẠO THÓI QUEN'));
    await settleDb(tester);
    await tester.pumpAndSettle();

    final h = (await habits(tester)).single;
    expect(h.name, 'Uống nước');
    expect(h.iconName, 'water_drop');
    expect(h.colorHex.toUpperCase(), '#00D2FF');
    expect(h.type, HabitType.counter);
    expect(h.unit, 'GL');
    expect(h.target, 8);
  });

  testWidgets('empty title shows inline error and saves nothing', (
    tester,
  ) async {
    await pumpSheet(tester);
    final create = find.textContaining('CREATE HABIT');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pump();
    expect(find.text('Enter a habit title'), findsOneWidget);
    expect(await habits(tester), isEmpty);
  });

  testWidgets('unit chips share one row', (tester) async {
    await pumpSheet(tester);
    await tapVisible(tester, find.text('Pages'));
    final ys = [
      for (final label in ['Pages', 'Minutes', 'Times', 'Glasses', 'Check'])
        tester.getCenter(find.text(label)).dy,
    ];
    // Same row: centers differ by far less than one chip height.
    expect(
      ys.reduce((a, b) => a > b ? a : b) - ys.reduce((a, b) => a < b ? a : b),
      lessThan(2),
    );
  });

  testWidgets('shows Vietnamese copy and validation errors', (tester) async {
    await pumpSheet(tester, locale: const Locale('vi'));
    expect(find.text('THÓI QUEN MỚI'), findsOneWidget);
    expect(find.text('NEW HABIT'), findsNothing);
    final create = find.textContaining('TẠO THÓI QUEN');
    await tapVisible(tester, create);
    expect(find.text('Nhập tên thói quen'), findsOneWidget);
    expect(await habits(tester), isEmpty);
  });

  testWidgets('edit mode prefills and saves changes', (tester) async {
    late Habit existing;
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
        ],
      );
      existing = await container
          .read(habitRepositoryProvider)
          .createHabit(
            name: 'Drink Water',
            type: HabitType.counter,
            target: 8,
            colorHex: '#00D2FF',
            iconName: 'water_drop',
            unit: 'GL',
            reminderTimes: [600, 1230],
          );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => HabitEditorSheet.show(context, habit: existing),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('EDIT HABIT'), findsOneWidget);
    expect(find.text('Drink Water'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hydrate');

    await tapVisible(tester, find.text('+ ADD TIME'));
    await tester.pumpAndSettle();
    // Time picker opened by "+ ADD TIME": cancel it.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    // Chip close icons come after the header and title-clear icons.
    await tapVisible(tester, find.byIcon(Icons.close).last);
    final save = find.text('SAVE CHANGES');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settleDb(tester);
    await tester.pumpAndSettle();

    final h = (await habits(tester)).single;
    expect(h.id, existing.id);
    expect(h.name, 'Hydrate');
    expect(h.unit, 'GL');
    expect(h.target, 8);
    expect(h.reminderTimes, [600]);
  });
}
