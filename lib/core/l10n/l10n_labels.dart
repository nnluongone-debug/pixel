import '../../data/models/habit.dart';
import '../../l10n/app_localizations.dart';

/// Shared display labels for values stored as codes in the database.
extension L10nLabels on AppLocalizations {
  /// Short unit label for a stored unit code (`GL`, `PG`, `X`, `MIN`, …).
  /// Unknown codes (older or custom units) are shown as stored.
  String unitLabel(String code) => switch (code.toUpperCase()) {
    'GL' => unitGlasses,
    'PG' => unitPages,
    'X' || 'TIMES' => unitTimes,
    'REPS' => unitReps,
    'MIN' => unitMinutes,
    _ => code,
  };

  /// Short weekday label for an ISO weekday (1 = Monday … 7 = Sunday).
  String weekdayShort(int isoWeekday) =>
      weekdayShortLabels.split(' ')[isoWeekday - 1];

  /// "DAILY", "WEEKDAYS" or the due days, e.g. "M W F".
  String cadenceLabel(HabitSchedule schedule) => switch (schedule.cadence) {
    HabitCadence.daily => cadenceDaily,
    HabitCadence.weekdays => cadenceWeekdays,
    HabitCadence.custom => [
      for (final d in schedule.dueWeekdays) weekdayShort(d),
    ].join(' '),
  };

  /// Daily goal, e.g. "8 GL", "30 MIN" or the checklist mark.
  String goalLabel(HabitType type, String unit, int target) => switch (type) {
    HabitType.counter => '$target ${unitLabel(unit)}'.trim(),
    HabitType.checklist => tasksGoalCheck,
    HabitType.timer => '$target $unitMinutes',
  };
}
