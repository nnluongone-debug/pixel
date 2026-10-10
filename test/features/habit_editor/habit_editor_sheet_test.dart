import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habit_editor/habit_editor_sheet.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
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
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
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
    expect(h.reminderMinutes, 20 * 60 + 30);
    expect(find.text('NEW HABIT'), findsNothing);
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
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
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
            reminderMinutes: 600,
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
    expect(h.reminderMinutes, 600);
  });
}
