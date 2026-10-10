import '../../data/models/habit.dart';
import '../progression/streak_calculator.dart';
import 'analytics_range.dart';
import 'history_index.dart';

/// One row of the consistency breakdown.
class HabitConsistency {
  const HabitConsistency({
    required this.habit,
    required this.metDays,
    required this.dueDays,
    required this.streak,
  });

  final Habit habit;

  /// Due days in the window where the target was met.
  final int metDays;

  /// Days in the window the habit was due, counted from the day it existed.
  final int dueDays;

  /// Schedule-aware current streak.
  final int streak;

  double get ratio => dueDays == 0 ? 0 : metDays / dueDays;

  int get percent => (ratio * 100).round();

  /// Least amount logged in the window: partial days are not stored, so only
  /// the [metDays] that reached [Habit.target] are known.
  int get minimumTotal => metDays * habit.target;

  static List<HabitConsistency> compute({
    required HistoryIndex index,
    required DayWindow window,
    required int today,
  }) {
    return [
      for (final habit in index.habits)
        () {
          var due = 0;
          var met = 0;
          for (var day = window.start; day <= window.end; day++) {
            if (!index.isDue(habit, day)) continue;
            due++;
            if (index.isDone(habit, day)) met++;
          }
          return HabitConsistency(
            habit: habit,
            metDays: met,
            dueDays: due,
            streak: StreakCalculator.scheduledStreak(
              index.doneDaysOf(habit.id),
              today,
              habit.schedule.includesEpochDay,
            ),
          );
        }(),
    ];
  }
}
