import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/domain/progression/streak_calculator.dart';
import 'package:pixel_quest/domain/progression/xp_rules.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Realistic data for store screenshots: nine everyday habits with a
/// colorful, mostly-complete last two weeks and a half-done today.
abstract final class StoreDemoSeeder {
  static const _days = 16;

  /// (vi, en, icon, color, type, unit, target, today's progress)
  static const _habits = [
    (
      'Uống nước',
      'Drink water',
      'water_drop',
      '#00D2FF',
      HabitType.counter,
      'GL',
      8,
      5,
    ),
    ('Đọc sách', 'Read', 'book', '#F9CA24', HabitType.counter, 'PG', 20, 20),
    ('Thiền', 'Meditate', 'zen', '#A29BFE', HabitType.timer, '', 10, 10),
    ('Chạy bộ', 'Run', 'run', '#FF9F43', HabitType.timer, '', 20, 0),
    (
      'Tập thể dục',
      'Workout',
      'fitness',
      '#2DE38E',
      HabitType.timer,
      '',
      30,
      30,
    ),
    (
      'Viết nhật ký',
      'Journal',
      'journal',
      '#FF4D94',
      HabitType.checklist,
      '',
      1,
      1,
    ),
    (
      'Ngủ sớm',
      'Sleep early',
      'sleep',
      '#A29BFE',
      HabitType.checklist,
      '',
      1,
      0,
    ),
    (
      'Luyện ngoại ngữ',
      'Practice a language',
      'language',
      '#FF7675',
      HabitType.checklist,
      '',
      1,
      1,
    ),
    (
      'Uống vitamin',
      'Take vitamins',
      'pill',
      '#2DE38E',
      HabitType.checklist,
      '',
      1,
      1,
    ),
  ];

  /// Habits skipped on day `d` (days before today) — keeps the stacks uneven.
  static bool _skipped(int habit, int d) =>
      (habit * 7 + d * 3) % 11 < 2 + habit % 3;

  static Future<void> seed(Database db, {required String lang}) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final today = DateKeys.epochDay(now);
    final todayKey = DateKeys.fromDate(now);
    final start = now.subtract(const Duration(days: _days));
    final habits = [
      for (final (i, h) in _habits.indexed)
        Habit(
          id: uuid.v4(),
          name: lang == 'vi' ? h.$1 : h.$2,
          type: h.$5,
          target: h.$7,
          currentProgress: 0,
          colorHex: h.$4,
          iconName: h.$3,
          unit: h.$6,
          schedule: HabitSchedule.daily,
          createdAt: DateTime(start.year, start.month, start.day, 7, i),
        ),
    ];
    await db.transaction((txn) async {
      for (final t in ['check_ins', 'habits', 'sync_outbox']) {
        await txn.delete(t);
      }
      final active = <int, Set<int>>{};
      final rows = <Map<String, Object?>>[];
      for (var back = _days - 1; back >= 0; back--) {
        final day = today - back;
        var slot = 0;
        for (final (i, h) in _habits.indexed) {
          final done = back == 0 ? h.$8 >= h.$7 : !_skipped(i, back);
          if (!done) continue;
          final days = active.putIfAbsent(i, () => {});
          final prior = StreakCalculator.streakBefore(days, day);
          days.add(day);
          rows.add({
            'id': uuid.v4(),
            'habit_id': habits[i].id,
            'date': DateKeys.shift(todayKey, -back),
            'xp_earned': XpRules.xpForCheckIn(priorStreakDays: prior),
            'grid_x': day,
            'grid_y': slot++,
            'updated_at': now.millisecondsSinceEpoch,
          });
        }
      }
      for (final (i, habit) in habits.indexed) {
        await txn.insert('habits', {
          ...habit.toMap(),
          'current_progress': _habits[i].$8,
          'progress_date': todayKey,
          'updated_at': now.millisecondsSinceEpoch,
        });
      }
      for (final r in rows) {
        await txn.insert('check_ins', r);
      }
      await UserStatsRepository(db).recalculate(txn, now: now);
    });
  }
}
