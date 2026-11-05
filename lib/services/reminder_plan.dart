import '../core/l10n/l10n_labels.dart';
import '../data/models/habit.dart';
import '../l10n/app_localizations.dart';

/// One local notification to schedule: [weekday] is ISO (1 = Monday) for a
/// weekly repeat, or null for a daily repeat.
class ReminderEntry {
  const ReminderEntry({
    required this.id,
    required this.habitId,
    required this.weekday,
    required this.minutes,
    required this.title,
    required this.body,
  });

  final int id;
  final String habitId;
  final int? weekday;

  /// Minutes after local midnight.
  final int minutes;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is ReminderEntry &&
      other.id == id &&
      other.habitId == habitId &&
      other.weekday == weekday &&
      other.minutes == minutes &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, habitId, weekday, minutes, title, body);
}

/// A 24 h window at the finest interval (15 min) has 96 fire times.
const int _maxSlotsPerHabit = 96;

/// Notification title shared by scheduled and test prompts (brand name).
const String reminderTitle = 'PIXEL QUEST';

/// Which notifications should exist for [habits]: one daily entry for
/// every-day habits, otherwise one weekly entry per due weekday, for each
/// reminder time of each habit. Habits without a reminder or with an empty schedule produce nothing. Text is
/// rendered with [l10n] so a language change yields a different plan.
List<ReminderEntry> buildReminderPlan(
  Iterable<Habit> habits,
  AppLocalizations l10n,
) {
  final entries = <ReminderEntry>[];
  var slot = 0;
  for (final habit in habits) {
    final slots = habit.reminderSlots;
    if (slots.isEmpty || !habit.schedule.isValid) continue;
    final body = reminderBody(habit, l10n);
    final isDaily = habit.schedule == HabitSchedule.daily;
    final weekdays = isDaily ? <int?>[null] : habit.schedule.dueWeekdays;
    for (final (timeIndex, minutes) in slots.indexed) {
      for (final weekday in weekdays) {
        entries.add(
          ReminderEntry(
            // Unique per habit slot, time index (< 96) and weekday (0 = daily).
            id: (slot * _maxSlotsPerHabit + timeIndex) * 8 + (weekday ?? 0),
            habitId: habit.id,
            weekday: weekday,
            minutes: minutes,
            title: reminderTitle,
            body: body,
          ),
        );
      }
    }
    slot++;
  }
  return entries;
}

/// Body text built only from the habit's fixed quota, never from progress.
String reminderBody(Habit habit, AppLocalizations l10n) {
  switch (habit.type) {
    case HabitType.checklist:
      return l10n.reminderBodyChecklist(habit.name);
    case HabitType.timer:
      return l10n.reminderBodyQuota(habit.name, habit.target, l10n.unitMinutes);
    case HabitType.counter:
      return habit.unit.isEmpty
          ? l10n.reminderBodyQuotaNoUnit(habit.name, habit.target)
          : l10n.reminderBodyQuota(
              habit.name,
              habit.target,
              l10n.unitLabel(habit.unit),
            );
  }
}

/// First local time strictly after [now] that falls on [weekday] (any day
/// when null) at [minutes] after midnight. Built from calendar fields so
/// daylight-saving shifts keep the wall-clock time.
DateTime nextReminderTime(DateTime now, {int? weekday, required int minutes}) {
  for (var offset = 0; offset <= 7; offset++) {
    final candidate = DateTime(
      now.year,
      now.month,
      now.day + offset,
      minutes ~/ 60,
      minutes % 60,
    );
    if (candidate.isAfter(now) &&
        (weekday == null || candidate.weekday == weekday)) {
      return candidate;
    }
  }
  throw ArgumentError.value(weekday, 'weekday', 'Must be 1-7');
}

/// iOS keeps at most 64 pending notifications and silently drops the rest;
/// stay below it with room for the test prompt.
const int maxPendingReminders = 60;

/// Keeps the [max] entries that fire soonest after [now] (ordered by id so
/// an unchanged selection compares equal). The rest are scheduled later,
/// when a reschedule runs on app resume or after a habit change.
List<ReminderEntry> capReminderPlan(
  List<ReminderEntry> plan,
  DateTime now, {
  int max = maxPendingReminders,
}) {
  if (plan.length <= max) return plan;
  final soonest = [...plan]
    ..sort(
      (a, b) => nextReminderTime(now, weekday: a.weekday, minutes: a.minutes)
          .compareTo(
            nextReminderTime(now, weekday: b.weekday, minutes: b.minutes),
          ),
    );
  return soonest.take(max).toList()..sort((a, b) => a.id.compareTo(b.id));
}
