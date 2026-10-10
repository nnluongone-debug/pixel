import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_key_utils.dart';
import '../../domain/progression/streak_calculator.dart';
import '../../domain/progression/xp_rules.dart';
import '../models/habit_schedule.dart';
import '../models/user_stats.dart';

/// `user_stats` is a cached projection of `check_ins`: it is rebuilt from
/// the check-in history after every mutation, never patched incrementally.
class UserStatsRepository {
  UserStatsRepository(this._db, {Clock? clock})
    : _clock = clock ?? DateTime.now;

  static const _table = 'user_stats';

  final Database _db;
  final Clock _clock;

  /// Fresh stats. Recomputed on read so a streak broken while the app was
  /// closed shows up as 0 instead of the stale cached value.
  Future<UserStats> getStats() => recalculate(_db);

  /// Last persisted stats without recomputing.
  Future<UserStats> getCachedStats([DatabaseExecutor? executor]) async {
    final rows = await (executor ?? _db).query(_table, where: 'id = 1');
    return rows.isEmpty ? UserStats.initial : UserStats.fromMap(rows.first);
  }

  /// Rebuilds level, XP and global streak from `check_ins` and persists them.
  /// Pass a transaction as [executor] to keep it atomic with the mutation,
  /// and the mutation's [now] so both agree on what "today" is.
  Future<UserStats> recalculate(
    DatabaseExecutor executor, {
    DateTime? now,
  }) async {
    final xpRows = await executor.rawQuery(
      'SELECT COALESCE(SUM(xp_earned), 0) AS total FROM check_ins',
    );
    final totalXp = xpRows.first['total']! as int;

    final dayRows = await executor.rawQuery(
      'SELECT DISTINCT grid_x FROM check_ins',
    );
    final activeDays = {for (final r in dayRows) r['grid_x']! as int};
    final streak = StreakCalculator.scheduledStreak(
      activeDays,
      DateKeys.epochDay(now ?? _clock()),
      await _anyHabitDue(executor),
    );

    final stats = XpRules.statsFromTotalXp(totalXp, streakDays: streak);
    await executor.insert(_table, {
      'id': 1,
      ...stats.toMap(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return stats;
  }

  /// Longest global streak ever (any habit completed counts as active;
  /// days with nothing due never break it).
  Future<int> getBestStreak() async {
    final rows = await _db.rawQuery('SELECT DISTINCT grid_x FROM check_ins');
    return StreakCalculator.longestScheduledStreak({
      for (final r in rows) r['grid_x']! as int,
    }, await _anyHabitDue(_db));
  }

  /// A day counts toward the global streak only if at least one habit that
  /// already existed was scheduled on it, so a Mon-Fri routine keeps its
  /// streak over the weekend.
  Future<bool Function(int epochDay)> _anyHabitDue(
    DatabaseExecutor executor,
  ) async {
    final rows = await executor.query(
      'habits',
      columns: ['schedule_days', 'created_at'],
    );
    final habits = [
      for (final r in rows)
        (
          schedule: HabitSchedule(r['schedule_days']! as int),
          createdDay: DateKeys.epochDay(
            DateTime.parse(r['created_at']! as String).toLocal(),
          ),
        ),
    ];
    return (day) => habits.any(
      (h) => day >= h.createdDay && h.schedule.includesEpochDay(day),
    );
  }
}
