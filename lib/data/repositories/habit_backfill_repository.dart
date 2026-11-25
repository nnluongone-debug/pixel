import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_key_utils.dart';
import '../../domain/progression/xp_rules.dart';
import '../models/habit.dart';
import '../models/progress_update.dart';
import 'check_in_repository.dart';
import 'user_stats_repository.dart';

/// Marks or unmarks a habit as done for one of the last [maxDaysBack] days
/// (never today, never before the habit existed). A past day is binary: one
/// block, base XP only. Today's progress is untouched.
class HabitBackfillRepository {
  HabitBackfillRepository(
    this._db, {
    required this.checkIns,
    required this.stats,
    Clock? clock,
  }) : _clock = clock ?? DateTime.now;

  static const int maxDaysBack = 7;

  final Database _db;
  final CheckInRepository checkIns;
  final UserStatsRepository stats;
  final Clock _clock;

  /// Day keys of the window, oldest first (today - 7 .. yesterday).
  static List<String> windowKeys(String today) => [
    for (var i = maxDaysBack; i >= 1; i--) DateKeys.shift(today, -i),
  ];

  /// Whether [dateKey] can be toggled for [habit] given [today]'s key.
  static bool isEditable(Habit habit, String dateKey, String today) {
    final day = DateKeys.epochDayOfKey(dateKey);
    final todayDay = DateKeys.epochDayOfKey(today);
    if (day >= todayDay || day < todayDay - maxDaysBack) return false;
    return day >= DateKeys.epochDay(habit.createdAt);
  }

  /// Day keys in [fromKey]..[toKey] (inclusive) the habit was done.
  Future<Set<String>> doneDays(
    String habitId,
    String fromKey,
    String toKey,
  ) async {
    final rows = await _db.query(
      'check_ins',
      columns: ['date'],
      where: 'habit_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [habitId, fromKey, toKey],
    );
    return {for (final r in rows) r['date']! as String};
  }

  /// Whether the habit's block on [dateKey] earned more than base XP (it was
  /// checked in on the day itself). Unmarking such a block loses that bonus.
  Future<bool> hasBonusXp(String habitId, String dateKey) async {
    final rows = await _db.query(
      'check_ins',
      columns: ['xp_earned'],
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateKey],
      limit: 1,
    );
    return rows.isNotEmpty &&
        (rows.first['xp_earned']! as int) > XpRules.baseXpPerCheckIn;
  }

  /// Idempotent: marking a done day or unmarking an open one changes nothing.
  /// Throws [ArgumentError] for an unknown habit or a day outside the window.
  Future<ProgressUpdate> setDone(
    String habitId,
    String dateKey, {
    required bool done,
  }) {
    final now = _clock();
    return _db.transaction((txn) async {
      final rows = await txn.query(
        'habits',
        where: 'id = ?',
        whereArgs: [habitId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw ArgumentError.value(habitId, 'habitId', 'unknown');
      }
      final habit = Habit.fromMap(rows.first);
      if (!isEditable(habit, dateKey, DateKeys.fromDate(now))) {
        throw ArgumentError.value(
          dateKey,
          'dateKey',
          'outside backfill window',
        );
      }
      final previousLevel = (await stats.getCachedStats(txn)).currentLevel;
      final existing = await checkIns.findForDay(txn, habitId, dateKey);
      final placed = done && existing == null
          ? await checkIns.insertForDay(txn, habitId, dateKey, backfill: true)
          : null;
      final removed =
          !done &&
          existing != null &&
          await checkIns.removeForDay(txn, habitId, dateKey);
      return ProgressUpdate(
        habit: habit,
        stats: await stats.recalculate(txn, now: now),
        previousLevel: previousLevel,
        placedCheckIn: placed,
        removedCheckIn: removed,
      );
    });
  }
}
