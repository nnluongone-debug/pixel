import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habits/widgets/habit_list_view.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/localized_test_app.dart';

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('+1 to target fires heavy haptic, awards XP and places a block', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );

    // Real in-memory SQLite; DB futures need real async outside fake time.
    late Database db;
    late ProviderContainer container;
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      await container
          .read(habitRepositoryProvider)
          .createHabit(
            name: 'Drink Water',
            type: HabitType.counter,
            target: 2,
            colorHex: '#00E5FF',
            iconName: 'water_drop',
            unit: 'gl',
          );
    });
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });

    Future<void> settleDb() async {
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
        child: localizedTestApp(
          home: const Scaffold(
            body: SingleChildScrollView(child: HabitListView()),
          ),
        ),
      ),
    );
    await settleDb();
    expect(find.text('0/2 GL'), findsOneWidget);
    expect(find.text('1 IN PROGRESS'), findsOneWidget);

    await tester.tap(find.text('+1'));
    await settleDb();
    expect(find.text('1/2 GL'), findsOneWidget);
    expect(haptics, ['HapticFeedbackType.lightImpact']);

    await tester.tap(find.text('+1'));
    await settleDb();
    expect(find.text('2/2 GL'), findsOneWidget);
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.text('0 IN PROGRESS'), findsOneWidget);

    late List<Map<String, Object?>> blocks;
    late Map<String, Object?> stats;
    await tester.runAsync(() async {
      blocks = await db.query('check_ins');
      stats = (await db.query('user_stats')).single;
    });
    expect(blocks, hasLength(1));
    expect(stats['current_xp'], 25);

    await tester.pumpAndSettle();
    expect(find.text('+25 XP'), findsNothing);
  });
}
