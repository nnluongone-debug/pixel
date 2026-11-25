import '../core/utils/date_key_utils.dart';
import '../data/models/check_in.dart';
import '../data/models/habit.dart';
import '../data/models/user_stats.dart';

/// Builds the JSON payload the home screen widgets read (iOS App Group, Android
/// SharedPreferences). Payload version 1 is shared by both platforms.
/// Pure: all inputs are explicit so it is easy to test.
String _identity(String code) => code;

abstract final class HomeWidgetSnapshot {
  static const int version = 1;
  static const int skylineDays = 7;
  static const int towerDays = 12;

  /// [checkIns] must cover at least the last [towerDays] days ending today.
  /// [habitStreaks] maps habit id to its current streak (missing = 0).
  /// [lang] is the app's language code; the widget picks its labels by it.
  /// [skin] is the equipped brick theme id (`ThemeId.name`).
  /// [unitLabel] localizes stored unit codes (defaults to the code itself).
  static Map<String, Object?> build({
    required DateTime now,
    required List<Habit> habits,
    required List<CheckIn> checkIns,
    required UserStats stats,
    Map<String, int> habitStreaks = const {},
    String lang = 'en',
    String skin = 'neonGlow',
    String Function(String code) unitLabel = _identity,
  }) {
    final todayKey = DateKeys.fromDate(now);
    final today = DateKeys.toDate(todayKey);
    final colorById = {for (final h in habits) h.id: h.colorHex};

    final habitEntries = [
      for (final h in habits)
        _habitEntry(h, today, todayKey, habitStreaks[h.id] ?? 0, unitLabel),
    ];
    final due = habitEntries.where((h) => h['dueToday']! as bool);
    final weekStart = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
    );
    final weekStartKey = DateKeys.fromDate(weekStart);
    final weekEndKey = DateKeys.fromDate(weekEnd);

    return {
      'version': version,
      'lang': lang,
      'skin': skin,
      'generatedAt': now.toUtc().toIso8601String(),
      'today': todayKey,
      'level': stats.currentLevel,
      'xp': stats.currentXp,
      'targetXp': stats.targetXp,
      'streak': stats.streakDays,
      'habits': habitEntries,
      'todayTotal': due.length,
      'todayDone': due.where((h) => h['done']! as bool).length,
      'skyline': _days(todayKey, skylineDays, checkIns, colorById),
      'tower': _days(todayKey, towerDays, checkIns, colorById),
      'weekNumber': _isoWeek(today),
      'weekStart': weekStartKey,
      'weekEnd': weekEndKey,
      'weekBlocks': checkIns
          .where(
            (c) =>
                colorById.containsKey(c.habitId) &&
                c.date.compareTo(weekStartKey) >= 0 &&
                c.date.compareTo(weekEndKey) <= 0,
          )
          .length,
    };
  }

  static Map<String, Object?> _habitEntry(
    Habit h,
    DateTime today,
    String todayKey,
    int streak,
    String Function(String code) unitLabel,
  ) {
    // Progress resets lazily when a new day starts, so stale values from a
    // previous day must read as zero.
    final isToday = h.progressDate == todayKey;
    final progress = isToday ? h.currentProgress : 0;
    return {
      'id': h.id,
      'name': h.name,
      'colorHex': h.colorHex,
      'icon': h.iconName,
      'type': h.type.name,
      'progress': progress,
      'target': h.target,
      'unit': h.type == HabitType.timer
          ? unitLabel('MIN')
          : (h.unit.isEmpty ? '' : unitLabel(h.unit)),
      'done': progress >= h.target,
      'dueToday': h.isDueOn(today),
      'scheduleDays': h.schedule.mask,
      'streak': streak,
    };
  }

  /// Oldest day first. Each day lists block colors bottom-up.
  static List<Map<String, Object?>> _days(
    String todayKey,
    int count,
    List<CheckIn> checkIns,
    Map<String, String> colorById,
  ) {
    return [
      for (var i = count - 1; i >= 0; i--)
        () {
          final key = DateKeys.shift(todayKey, -i);
          final blocks = checkIns.where((c) => c.date == key).toList()
            ..sort((a, b) => a.gridY.compareTo(b.gridY));
          return <String, Object?>{
            'date': key,
            'weekday': DateKeys.toDate(key).weekday,
            'colors': [
              for (final c in blocks)
                if (colorById[c.habitId] != null) colorById[c.habitId],
            ],
          };
        }(),
    ];
  }

  /// ISO-8601 week number (weeks start Monday, week 1 contains Jan 4th).
  static int _isoWeek(DateTime date) {
    final thursday = DateTime.utc(
      date.year,
      date.month,
      date.day + 4 - date.weekday,
    );
    final firstDay = DateTime.utc(thursday.year, 1, 1);
    return (thursday.difference(firstDay).inDays ~/ 7) + 1;
  }
}
