import 'dart:math';

import '../../core/l10n/l10n_labels.dart';
import '../../data/models/habit.dart';
import '../../l10n/app_localizations.dart';

/// Text and mini-bar math for habit cards, kept pure so it is unit-tested.
abstract final class HabitDisplay {
  static const int maxSegments = 8;

  /// Badge next to the habit name: "5/8 GL", "15D STREAK", "3.5 / 4 HRS",
  /// or a live "FOCUS 12:34" while a focus session runs.
  static String badge(
    AppLocalizations l10n,
    Habit habit, {
    int streak = 0,
    Duration? focusElapsed,
  }) {
    switch (habit.type) {
      case HabitType.counter:
        final unit = habit.unit.isEmpty ? '' : ' ${l10n.unitLabel(habit.unit)}';
        return '${habit.currentProgress}/${habit.target}$unit';
      case HabitType.checklist:
        return l10n.gridHudStreak(streak);
      case HabitType.timer:
        if (focusElapsed != null) {
          return l10n.gridBadgeFocus(clock(focusElapsed));
        }
        return timerProgress(l10n, habit.currentProgress, habit.target);
    }
  }

  /// Minutes as hours once the target reaches an hour, else minutes.
  static String timerProgress(
    AppLocalizations l10n,
    int progressMinutes,
    int targetMinutes,
  ) {
    if (targetMinutes >= 60) {
      return l10n.gridBadgeHours(hours(progressMinutes), hours(targetMinutes));
    }
    return l10n.gridBadgeAmount(
      progressMinutes,
      targetMinutes,
      l10n.unitMinutes,
    );
  }

  /// 210 -> "3.5", 240 -> "4", 100 -> "1.7".
  static String hours(int minutes) {
    final text = (minutes / 60).toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  /// "04:07" or "1:02:03".
  static String clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  /// Checklists show the last [maxSegments] streak days; others show the
  /// target split into at most [maxSegments] pixels.
  static int segmentCount(Habit habit) => habit.type == HabitType.checklist
      ? maxSegments
      : min(habit.target, maxSegments);

  static int filledSegments(Habit habit, {int streak = 0}) {
    if (habit.type == HabitType.checklist) return min(streak, maxSegments);
    final total = segmentCount(habit);
    if (habit.isCompleted) return total;
    return (habit.currentProgress / habit.target * total).floor();
  }
}
