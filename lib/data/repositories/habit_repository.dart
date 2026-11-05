import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_key_utils.dart';
import '../models/habit.dart';
import '../models/progress_update.dart';
import '../sync/sync_outbox.dart';
import 'check_in_repository.dart';
import 'user_stats_repository.dart';

class HabitRepository {
  HabitRepository(
    this._db, {
    required this.checkIns,
    required this.stats,
    Clock? clock,
    Uuid? uuid,
  }) : _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  static const _table = 'habits';
  static const int maxNameLength = 32;

  final Database _db;
  final CheckInRepository checkIns;
  final UserStatsRepository stats;
  final Clock _clock;
  final Uuid _uuid;

  // ---- CRUD ----

  Future<Habit> createHabit({
    required String name,
    required HabitType type,
    required int target,
    required String colorHex,
    required String iconName,
    String unit = '',
    HabitSchedule schedule = HabitSchedule.daily,
    List<int>? reminderTimes,
    int? reminderEvery,
    int reminderFrom = Habit.defaultReminderFrom,
    int reminderTo = Habit.defaultReminderTo,
  }) async {
    final now = _clock();
    final habit = Habit(
      id: _uuid.v4(),
      name: _validName(name),
      type: type,
      target: _validTarget(target),
      currentProgress: 0,
      colorHex: colorHex,
      iconName: iconName,
      unit: unit.trim().toUpperCase(),
      schedule: _validSchedule(schedule),
      reminderTimes: _validReminders(reminderTimes ?? const []),
      reminderEvery: _validEvery(reminderEvery),
      reminderFrom: _validMinute(reminderFrom, 'reminderFrom'),
      reminderTo: _validWindowEnd(reminderFrom, reminderTo),
      createdAt: now,
      progressDate: DateKeys.fromDate(now),
    );
    final stamp = now.millisecondsSinceEpoch;
    await _db.transaction((txn) async {
      await txn.insert(_table, {...habit.toMap(), 'updated_at': stamp});
      await _enqueue(txn, habit.id, SyncOp.upsert, stamp);
    });
    return habit;
  }

  /// All habits with today's progress (stale days reset), oldest first.
  Future<List<Habit>> getHabits() async {
    await _resetStaleProgress(_db, DateKeys.fromDate(_clock()));
    final rows = await _db.query(_table, orderBy: 'created_at ASC, id ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<Habit?> getHabit(String id) async {
    await _resetStaleProgress(_db, DateKeys.fromDate(_clock()));
    return _find(_db, id);
  }

  /// Saves edits. Changing the target re-evaluates today's block, e.g.
  /// lowering it below current progress completes the habit.
  Future<ProgressUpdate> updateHabit(Habit habit) {
    return _transaction((txn, now) async {
      final before = await _require(txn, habit.id, now);
      final edited = before.copyWith(
        name: _validName(habit.name),
        type: habit.type,
        target: _validTarget(habit.target),
        colorHex: habit.colorHex,
        iconName: habit.iconName,
        unit: habit.unit.trim().toUpperCase(),
        schedule: _validSchedule(habit.schedule),
        reminderTimes: _validReminders(habit.reminderTimes),
        reminderEvery: _validEvery(habit.reminderEvery),
        reminderFrom: _validMinute(habit.reminderFrom, 'reminderFrom'),
        reminderTo: _validWindowEnd(habit.reminderFrom, habit.reminderTo),
      );
      await txn.update(
        _table,
        {
          'name': edited.name,
          'type': edited.type.name,
          'target': edited.target,
          'color_hex': edited.colorHex,
          'icon_name': edited.iconName,
          'unit': edited.unit,
          'schedule_days': edited.schedule.mask,
          'reminder_times': Habit.encodeTimes(edited.reminderTimes),
          'reminder_every': edited.reminderEvery,
          'reminder_from': edited.reminderFrom,
          'reminder_to': edited.reminderTo,
          'updated_at': now.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      await _enqueue(txn, habit.id, SyncOp.upsert, now.millisecondsSinceEpoch);
      return _applyProgress(txn, before, edited, now);
    });
  }

  /// Deletes the habit and its whole history; XP and streak are recomputed.
  Future<void> deleteHabit(String id) {
    return _transaction((txn, now) async {
      final blocks = await checkIns.blocksOfHabit(txn, id);
      final stamp = now.millisecondsSinceEpoch;
      await txn.delete(_table, where: 'id = ?', whereArgs: [id]);
      await _enqueue(txn, id, SyncOp.delete, stamp);
      for (final block in blocks) {
        await SyncOutbox.enqueue(
          txn,
          SyncEntity.checkIn,
          block.id,
          SyncOp.delete,
          stamp,
        );
      }
      for (final date in {for (final b in blocks) b.date}) {
        await checkIns.compactColumn(txn, date);
      }
      await stats.recalculate(txn, now: now);
    });
  }

  // ---- Progress ----

  /// Sets today's progress. Reaching the target places a block and awards
  /// XP; dropping from done to below target removes it and takes XP back.
  Future<ProgressUpdate> setProgress(String id, int value) {
    return _transaction((txn, now) async {
      final before = await _require(txn, id, now);
      return _applyProgress(txn, before, _withProgress(before, value), now);
    });
  }

  /// +[amount] units (glasses, pages, minutes). Negative amounts undo.
  Future<ProgressUpdate> incrementProgress(String id, {int amount = 1}) {
    return _transaction((txn, now) async {
      final before = await _require(txn, id, now);
      final value = before.currentProgress + amount;
      return _applyProgress(txn, before, _withProgress(before, value), now);
    });
  }

  /// Checklist habits. Takes the intended state instead of flipping, so a
  /// stale UI (e.g. yesterday's "done" shown after midnight) or a double
  /// tap can never do the opposite of what the user meant.
  Future<ProgressUpdate> setCompleted(String id, {required bool completed}) {
    return _transaction((txn, now) async {
      final before = await _require(txn, id, now);
      final value = completed ? before.target : 0;
      return _applyProgress(txn, before, _withProgress(before, value), now);
    });
  }

  /// Persists [after]'s progress and syncs today's block with the
  /// done/not-done transition from [before] to [after].
  Future<ProgressUpdate> _applyProgress(
    Transaction txn,
    Habit before,
    Habit after,
    DateTime now,
  ) async {
    final today = DateKeys.fromDate(now);
    final previousLevel = (await stats.getCachedStats(txn)).currentLevel;
    final changed = after.currentProgress != before.currentProgress;
    await txn.update(
      _table,
      {
        'current_progress': after.currentProgress,
        'progress_date': today,
        if (changed) 'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [after.id],
    );
    if (changed) {
      await _enqueue(txn, after.id, SyncOp.upsert, now.millisecondsSinceEpoch);
    }
    final existing = await checkIns.findForDay(txn, after.id, today);

    final placed = after.isCompleted && existing == null
        ? await checkIns.insertForDay(txn, after.id, today)
        : null;
    final removed =
        before.isCompleted &&
        !after.isCompleted &&
        existing != null &&
        await checkIns.removeForDay(txn, after.id, today);

    return ProgressUpdate(
      habit: after,
      stats: await stats.recalculate(txn, now: now),
      previousLevel: previousLevel,
      placedCheckIn: placed,
      removedCheckIn: removed,
    );
  }

  // ---- Helpers ----

  /// Runs [action] in a transaction with one clock reading, so an operation
  /// that straddles midnight still sees a single consistent day.
  Future<T> _transaction<T>(
    Future<T> Function(Transaction txn, DateTime now) action,
  ) {
    final now = _clock();
    return _db.transaction((txn) => action(txn, now));
  }

  Future<void> _enqueue(
    DatabaseExecutor executor,
    String id,
    SyncOp op,
    int updatedAt,
  ) => SyncOutbox.enqueue(executor, SyncEntity.habit, id, op, updatedAt);

  Habit _withProgress(Habit habit, int value) =>
      habit.copyWith(currentProgress: value < 0 ? 0 : value);

  /// Starts a new day for habits whose progress belongs to an earlier one.
  /// A habit that already has a block for [today] (e.g. after a time-zone
  /// change) resumes at its target instead of 0, so progress and matrix
  /// never disagree.
  Future<void> _resetStaleProgress(DatabaseExecutor executor, String today) {
    return executor.rawUpdate(
      'UPDATE $_table SET progress_date = ?, current_progress = CASE '
      'WHEN EXISTS (SELECT 1 FROM check_ins c '
      'WHERE c.habit_id = $_table.id AND c.date = ?) THEN target ELSE 0 END '
      'WHERE progress_date IS NULL OR progress_date != ?',
      [today, today, today],
    );
  }

  Future<Habit?> _find(DatabaseExecutor executor, String id) async {
    final rows = await executor.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Habit.fromMap(rows.first);
  }

  Future<Habit> _require(
    DatabaseExecutor executor,
    String id,
    DateTime now,
  ) async {
    await _resetStaleProgress(executor, DateKeys.fromDate(now));
    final habit = await _find(executor, id);
    if (habit == null) throw StateError('Habit $id not found');
    return habit;
  }

  String _validName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxNameLength) {
      throw ArgumentError.value(
        name,
        'name',
        'Must be 1-$maxNameLength characters',
      );
    }
    return trimmed;
  }

  HabitSchedule _validSchedule(HabitSchedule schedule) {
    if (!schedule.isValid) {
      throw ArgumentError.value(
        schedule.mask,
        'schedule',
        'Pick at least one day',
      );
    }
    return schedule;
  }

  int? _validEvery(int? every) {
    if (every != null && !Habit.reminderEveryChoices.contains(every)) {
      throw ArgumentError.value(
        every,
        'reminderEvery',
        'Must be one of ${Habit.reminderEveryChoices}',
      );
    }
    return every;
  }

  int _validMinute(int minute, String name) {
    if (minute < 0 || minute >= 24 * 60) {
      throw ArgumentError.value(minute, name, 'Must be 0-1439');
    }
    return minute;
  }

  int _validWindowEnd(int from, int to) {
    _validMinute(to, 'reminderTo');
    if (to <= from) {
      throw ArgumentError.value(to, 'reminderTo', 'Must be after the start');
    }
    return to;
  }

  /// Sorted, de-duplicated, each 0..1439, at most [Habit.maxReminderTimes].
  List<int> _validReminders(List<int> times) {
    final unique = times.toSet().toList()..sort();
    if (unique.length > Habit.maxReminderTimes) {
      throw ArgumentError.value(
        times.length,
        'reminderTimes',
        'At most ${Habit.maxReminderTimes} times',
      );
    }
    for (final m in unique) {
      if (m < 0 || m >= 24 * 60) {
        throw ArgumentError.value(m, 'reminderTimes', 'Must be 0-1439');
      }
    }
    return List.unmodifiable(unique);
  }

  int _validTarget(int target) {
    if (target <= 0) {
      throw ArgumentError.value(target, 'target', 'Must be greater than 0');
    }
    return target;
  }
}
