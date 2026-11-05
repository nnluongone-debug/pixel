import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/features/stats/stats_screen.dart';
import 'package:pixel_quest/features/stats/widgets/habit_breakdown_card.dart';
import 'package:pixel_quest/features/stats/widgets/rate_ring_gauge.dart';
import 'package:pixel_quest/features/stats/widgets/segmented_bar.dart';
import 'package:pixel_quest/providers/analytics_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/localized_test_app.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final screenNow = DateTime(2026, 10, 10, 9, 5);

  testWidgets('renders real analytics and reacts to range and month', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late Database db;
    late ProviderContainer container;
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      var seedNow = DateTime(2026, 10, 1, 8);
      final habits = HabitRepository(
        db,
        checkIns: CheckInRepository(db, clock: () => seedNow),
        stats: UserStatsRepository(db, clock: () => seedNow),
        clock: () => seedNow,
      );
      final water = await habits.createHabit(
        name: 'Drink Water',
        type: HabitType.checklist,
        target: 1,
        colorHex: '#00D2FF',
        iconName: 'water_drop',
      );
      for (final day in [1, 2, 3]) {
        seedNow = DateTime(2026, 10, day, 8);
        await habits.setCompleted(water.id, completed: true);
      }
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsClockProvider.overrideWithValue(() => screenNow),
        ],
      );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });

    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(home: const Scaffold(body: StatsScreen())),
      ),
    );
    await settle();

    expect(find.text('HABIT ANALYTICS'), findsOneWidget);
    expect(find.text('NEO_MATRIX.V4'), findsOneWidget);
    expect(find.text('SYNCED: TODAY 09:05'), findsOneWidget);
    expect(find.text('30D WINDOW'), findsOneWidget);
    expect(find.text('ACTIVITY MATRIX // OCT 2026'), findsOneWidget);
    expect(find.text('Drink Water'), findsOneWidget);
    expect(find.text('3 / 10 Days Target Met'), findsOneWidget);
    expect(find.text('3 DONE'), findsOneWidget);
    expect(find.text('30%'), findsNWidgets(2)); // rate tile + habit row
    expect(find.text('PIXEL BADGES (2/10)'), findsOneWidget);
    expect(find.byType(RateRingGauge), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HabitBreakdownCard),
        matching: find.byType(SegmentedBar),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Week'));
    await settle();
    expect(find.text('7D WINDOW'), findsOneWidget);
    // Oct 4..10 holds no check-ins and 7 due days.
    expect(find.text('0 / 7 Days Target Met'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await settle();
    expect(find.text('ACTIVITY MATRIX // SEP 2026'), findsOneWidget);

    await tester.tap(find.text('VIEW ALL'));
    await tester.pumpAndSettle();
    expect(
      find.text('Badges are trophies only and award no XP.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an empty state without habits', (tester) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late Database db;
    late ProviderContainer container;
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsClockProvider.overrideWithValue(() => screenNow),
        ],
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
          locale: const Locale('vi'),
          home: const Scaffold(body: StatsScreen()),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('PHÂN TÍCH THÓI QUEN'), findsOneWidget);
    expect(find.textContaining('Chưa có thói quen'), findsOneWidget);
    expect(find.text('HUY HIỆU PIXEL (0/10)'), findsOneWidget);
    expect(find.text('TUẦN'), findsNothing);
    expect(find.text('Tuần'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
    expect(
      find.textContaining('MA TRẬN HOẠT ĐỘNG // THÁNG 10 2026'),
      findsOneWidget,
    );
    expect(find.text('--'), findsOneWidget);
  });
}
