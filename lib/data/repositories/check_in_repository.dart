import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_key_utils.dart';
import '../../domain/progression/streak_calculator.dart';
import '../../domain/progression/xp_rules.dart';
import '../models/check_in.dart';
import '../models/habit_schedule.dart';
import '../sync/sync_outbox.dart';

/// Check-ins are the blocks of the pixel matrix. Column = day (`grid_x`),
/// row = stacking order inside that day (`grid_y`, 0 = base).
class CheckInRepository {
  CheckInRepository(this._db, {Clock? clock, Uuid? uuid})
    : _clock = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid();

  static const _table = 'check_ins';

  /// Day columns in the matrix. Its height grows with the habit count (one
  /// brick per habit per day), so there is no fixed row limit here.
  static const int matrixColumns = 10;

  final Database _db;
  final Clock _clock;
  final Uuid _uuid;

  // ---- Reads ----

  Future<List<CheckIn>> getForHabit(String habitId) async {
    final rows = await _db.query(
      _table,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return rows.map(CheckIn.fromMap).toList();
  }

  /// All blocks between [fromKey] and [toKey] inclusive (`YYYY-MM-DD`).
  Future<List<CheckIn>> getBetween(String fromKey, String toKey) async {
    final rows = await _db.query(
      _table,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [fromKey, toKey],
      orderBy: 'grid_x ASC, grid_y ASC',
    );
    return rows.map(CheckIn.fromMap).toList();
  }

  /// Blocks for the last [columns] days ending today, for the grid view.
  Future<List<CheckIn>> getMatrix({int columns = matrixColumns}) {
    final today = DateKeys.fromDate(_clock());
    return getBetween(DateKeys.shift(today, -(columns - 1)), today);
  }

  /// Current streak of one habit, skipping days it isn't scheduled (grace
  /// until midnight, like the global one).
  Future<int> getHabitStreak(String habitId) async {
    final schedule = await _scheduleOf(_db, habitId);
    return StreakCalculator.scheduledStreak(
      await _activeDaysOf(_db, habitId),
      DateKeys.epochDay(_clock()),
      schedule.includesEpochDay,
    );
  }

  Future<int> getHabitBestStreak(String habitId) async {
    final schedule = await _scheduleOf(_db, habitId);
    return StreakCalculator.longestScheduledStreak(
      await _activeDaysOf(_db, habitId),
      schedule.includesEpochDay,
    );
  }

  /// Fully filled horizontal rows across the visible matrix — the height of
  /// the shortest column. Drives "N ROWS COMPLETED TODAY".
  Future<int> getCompletedRows({int columns = matrixColumns}) =>
      _completedRows(_db, DateKeys.epochDay(_clock()), columns);

  Future<int> _completedRows(
    DatabaseExecutor executor,
    int endDay,
    int columns,
  ) async {
    final rows = await executor.rawQuery(
      'SELECT grid_x, COUNT(*) AS height FROM $_table '
      'WHERE grid_x BETWEEN ? AND ? GROUP BY grid_x',
      [endDay - columns + 1, endDay],
    );
    if (rows.length < columns) return 0;
    return rows.map((r) => r['height']! as int).reduce((a, b) => a < b ? a : b);
  }

  // ---- Writes (run inside the caller's transaction) ----

  Future<CheckIn?> findForDay(
    DatabaseExecutor executor,
    String habitId,
    String dateKey,
  ) async {
    final rows = await executor.query(
      _table,
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateKey],
      limit: 1,
    );
    return rows.isEmpty ? null : CheckIn.fromMap(rows.first);
  }

  /// Drops a new block on top of [dateKey]'s column and awards XP with the
  /// habit's streak bonus and the line-clear bonus at that moment. A
  /// [backfill] block (logged for a past day) earns base XP only.
  Future<CheckIn> insertForDay(
    DatabaseExecutor executor,
    String habitId,
    String dateKey, {
    bool backfill = false,
  }) async {
    final day = DateKeys.epochDayOfKey(dateKey);
    var xp = XpRules.baseXpPerCheckIn;
    if (!backfill) {
      final schedule = await _scheduleOf(executor, habitId);
      final priorStreak = StreakCalculator.scheduledStreakBefore(
        await _activeDaysOf(executor, habitId),
        day,
        schedule.includesEpochDay,
      );
      xp = XpRules.xpForCheckIn(
        priorStreakDays: priorStreak,
        completedRows: await _completedRows(executor, day, matrixColumns),
      );
    }
    final heightRows = await executor.rawQuery(
      'SELECT COUNT(*) AS height FROM $_table WHERE date = ?',
      [dateKey],
    );

    final checkIn = CheckIn(
      id: _uuid.v4(),
      habitId: habitId,
      date: dateKey,
      xpEarned: xp,
      gridX: day,
      gridY: heightRows.first['height']! as int,
    );
    final stamp = _clock().millisecondsSinceEpoch;
    await executor.insert(_table, {...checkIn.toMap(), 'updated_at': stamp});
    await SyncOutbox.enqueue(
      executor,
      SyncEntity.checkIn,
      checkIn.id,
      SyncOp.upsert,
      stamp,
    );
    return checkIn;
  }

  /// Removes the habit's block on [dateKey]; blocks above it fall down.
  Future<bool> removeForDay(
    DatabaseExecutor executor,
    String habitId,
    String dateKey,
  ) async {
    final existing = await findForDay(executor, habitId, dateKey);
    if (existing == null) return false;
    await executor.delete(_table, where: 'id = ?', whereArgs: [existing.id]);
    await SyncOutbox.enqueue(
      executor,
      SyncEntity.checkIn,
      existing.id,
      SyncOp.delete,
      _clock().millisecondsSinceEpoch,
    );
    await compactColumn(executor, dateKey);
    return true;
  }

  /// Ids and dates of the habit's blocks (used before cascade deletes).
  Future<List<({String id, String date})>> blocksOfHabit(
    DatabaseExecutor executor,
    String habitId,
  ) async {
    final rows = await executor.query(
      _table,
      columns: ['id', 'date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return [
      for (final r in rows)
        (id: r['id']! as String, date: r['date']! as String),
    ];
  }

  /// Re-numbers `grid_y` of one day to 0..n-1, closing gaps left by removed
  /// blocks while keeping the original stacking order. Moved blocks are queued
  /// for sync unless [track] is false (remote changes being applied).
  Future<void> compactColumn(
    DatabaseExecutor executor,
    String dateKey, {
    bool track = true,
  }) async {
    final stamp = _clock().millisecondsSinceEpoch;
    final rows = await executor.query(
      _table,
      columns: ['id', 'grid_y'],
      where: 'date = ?',
      whereArgs: [dateKey],
      orderBy: 'grid_y ASC, id ASC',
    );
    for (var i = 0; i < rows.length; i++) {
      if (rows[i]['grid_y'] == i) continue;
      final id = rows[i]['id']! as String;
      await executor.update(
        _table,
        {'grid_y': i, if (track) 'updated_at': stamp},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (track) {
        await SyncOutbox.enqueue(
          executor,
          SyncEntity.checkIn,
          id,
          SyncOp.upsert,
          stamp,
        );
      }
    }
  }

  Future<HabitSchedule> _scheduleOf(
    DatabaseExecutor executor,
    String habitId,
  ) async {
    final rows = await executor.query(
      'habits',
      columns: ['schedule_days'],
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    if (rows.isEmpty) return HabitSchedule.daily;
    return HabitSchedule(rows.first['schedule_days']! as int);
  }

  Future<Set<int>> _activeDaysOf(
    DatabaseExecutor executor,
    String habitId,
  ) async {
    final rows = await executor.query(
      _table,
      columns: ['grid_x'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return {for (final r in rows) r['grid_x']! as int};
  }
}
