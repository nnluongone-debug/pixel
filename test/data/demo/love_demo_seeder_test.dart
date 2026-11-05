import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/demo/love_demo_seeder.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/domain/demo/love_pattern.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('pattern is 10 wide and needs 12 habits', () {
    for (final row in LovePattern.picture) {
      expect(row.length, LovePattern.columns);
    }
    expect(LovePattern.letterHabits, 8);
    expect(LovePattern.fillerHabits, 4);
    // The tallest column has 9 bricks, so the demo fits the 10x10 matrix.
    expect(LovePattern.letterHabits + LovePattern.fillerHabits, 12);
    expect(LovePattern.rows, lessThanOrEqualTo(12));
  });

  test('seed fills every column and pink bricks spell LOVE', () async {
    final now = DateTime(2026, 10, 10, 15);
    final db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    addTearDown(db.close);

    await LoveDemoSeeder(db, clock: () => now).seed(lang: 'vi');

    final habits = await db.query('habits');
    expect(habits, hasLength(12));
    final pink = {
      for (final h in habits)
        if (h['color_hex'] == LoveDemoSeeder.letterColor) h['id'],
    };
    final rows = await db.query('check_ins', orderBy: 'grid_x, grid_y');
    expect(
      rows,
      hasLength(
        [
          for (var c = 0; c < LovePattern.columns; c++) LovePattern.heightOf(c),
        ].reduce((a, b) => a + b),
      ),
    );

    // Column 0 is an empty margin, so derive the first day from the clock.
    final firstDay = DateKeys.epochDay(now) - LovePattern.columns + 1;
    for (final r in rows) {
      final column = (r['grid_x']! as int) - firstDay;
      final slot = r['grid_y']! as int;
      expect(
        pink.contains(r['habit_id']),
        LovePattern.isLetter(column, slot),
        reason: 'column $column slot $slot',
      );
    }
    expect(await db.query('sync_outbox'), isEmpty);
    final stats = await UserStatsRepository(db, clock: () => now).getStats();
    // 8 columns with bricks; the 2 empty margin days are rest days.
    expect(stats.streakDays, 8);
    expect(stats.currentLevel, greaterThan(1));
  });
}
