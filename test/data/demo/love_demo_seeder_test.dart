import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/demo/love_demo_seeder.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/domain/demo/love_pattern.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('pattern is 10x15 and fits the demo habits', () {
    expect(LovePattern.picture, hasLength(LovePattern.rows));
    for (final row in LovePattern.picture) {
      expect(row.length, LovePattern.columns);
    }
    for (var c = 0; c < LovePattern.columns; c++) {
      expect(LovePattern.lettersInColumn(c), lessThanOrEqualTo(10));
    }
    expect(CheckInRepository.matrixRows, LovePattern.rows);
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
    expect(habits, hasLength(25));
    final pink = {
      for (final h in habits)
        if (h['color_hex'] == LoveDemoSeeder.letterColor) h['id'],
    };
    final rows = await db.query('check_ins', orderBy: 'grid_x, grid_y');
    expect(rows, hasLength(LovePattern.columns * LovePattern.rows));

    final firstDay = rows.first['grid_x']! as int;
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
    expect(stats.streakDays, 10);
    expect(stats.currentLevel, greaterThan(1));
  });
}
