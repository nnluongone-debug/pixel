import '../../core/utils/date_key_utils.dart';
import '../../data/models/habit.dart';
import 'check_in_record.dart';

/// Habit-days due and completed on a day (or over a span of days).
class DayTally {
  const DayTally(this.done, this.due);

  final int done;
  final int due;

  /// Every due habit was completed (and at least one was due).
  bool get isPerfect => due > 0 && done == due;

  /// Completed share of due, or null when nothing was due.
  double? get ratio => due == 0 ? null : done / due;

  /// Whole percent, or null when nothing was due.
  int? get percent => due == 0 ? null : (done * 100 / due).round();
}

/// Immutable lookup over habits and their check-ins.
///
/// A habit is *due* on a day when it already existed and the schedule
/// includes the weekday. Check-ins exist only for days a target was met, so
/// "done" means a stored check-in on a due day. Schedules apply to the whole
/// history, since past schedules are not stored.
class HistoryIndex {
  HistoryIndex({
    required Iterable<Habit> habits,
    required Iterable<CheckInRecord> records,
  }) : habits = List.unmodifiable(habits),
       records = List.unmodifiable(
         records.toList()..sort((a, b) => a.epochDay - b.epochDay),
       ) {
    for (final habit in this.habits) {
      _createdDay[habit.id] = DateKeys.epochDay(habit.createdAt);
      _doneDays[habit.id] = <int>{};
    }
    for (final record in this.records) {
      activeDays.add(record.epochDay);
      _doneDays[record.habitId]?.add(record.epochDay);
    }
  }

  final List<Habit> habits;

  /// All check-ins, oldest first.
  final List<CheckInRecord> records;

  /// Days with at least one check-in.
  final Set<int> activeDays = {};

  final Map<String, int> _createdDay = {};
  final Map<String, Set<int>> _doneDays = {};

  /// Oldest day with a habit or check-in; null on an empty history.
  int? get firstDay {
    final days = [..._createdDay.values, ?activeDays.minOrNull];
    return days.isEmpty ? null : days.reduce((a, b) => a < b ? a : b);
  }

  Set<int> doneDaysOf(String habitId) => _doneDays[habitId] ?? const {};

  bool isDue(Habit habit, int day) =>
      day >= (_createdDay[habit.id] ?? day + 1) &&
      habit.schedule.includesEpochDay(day);

  bool isDone(Habit habit, int day) => doneDaysOf(habit.id).contains(day);

  DayTally tally(int day) {
    var due = 0;
    var done = 0;
    for (final habit in habits) {
      if (!isDue(habit, day)) continue;
      due++;
      if (isDone(habit, day)) done++;
    }
    return DayTally(done, due);
  }

  /// Summed tallies for [start]..[end] inclusive.
  DayTally tallyRange(int start, int end) {
    var due = 0;
    var done = 0;
    for (var day = start; day <= end; day++) {
      final t = tally(day);
      due += t.due;
      done += t.done;
    }
    return DayTally(done, due);
  }

  /// Days in [start]..[end] where every due habit was completed.
  int perfectDays(int start, int end) {
    var count = 0;
    for (var day = start; day <= end; day++) {
      if (tally(day).isPerfect) count++;
    }
    return count;
  }

  /// Check-ins whose day lies in [start]..[end].
  int blocksIn(int start, int end) =>
      records.where((r) => r.epochDay >= start && r.epochDay <= end).length;
}

extension on Iterable<int> {
  int? get minOrNull => isEmpty ? null : reduce((a, b) => a < b ? a : b);
}
