/// Streak math over sets of epoch days (see `DateKeys.epochDay`).
abstract final class StreakCalculator {
  /// Consecutive active days ending today. If today has no activity yet,
  /// the streak is still alive when yesterday was active (grace until
  /// midnight), and counts back from yesterday.
  static int currentStreak(Set<int> activeDays, int today) {
    var cursor = activeDays.contains(today) ? today : today - 1;
    var count = 0;
    while (activeDays.contains(cursor)) {
      count++;
      cursor--;
    }
    return count;
  }

  /// Consecutive active days strictly before [day]. Used to compute the
  /// streak bonus of a new check-in on [day].
  static int streakBefore(Set<int> activeDays, int day) {
    var cursor = day - 1;
    var count = 0;
    while (activeDays.contains(cursor)) {
      count++;
      cursor--;
    }
    return count;
  }

  /// Longest run of consecutive active days ever.
  static int longestStreak(Set<int> activeDays) {
    var best = 0;
    for (final day in activeDays) {
      if (activeDays.contains(day - 1)) continue; // not the start of a run
      var length = 1;
      while (activeDays.contains(day + length)) {
        length++;
      }
      if (length > best) best = length;
    }
    return best;
  }

  /// How far back schedule-aware walks look (about 10 years).
  static const int _lookbackDays = 3660;

  /// Habit streak that skips days the habit isn't due ([isDue] false).
  /// Completing on an off day still counts. Today gets the same grace as
  /// [currentStreak]: not done yet doesn't break the streak.
  static int scheduledStreak(
    Set<int> activeDays,
    int today,
    bool Function(int epochDay) isDue,
  ) => _walkBack(activeDays, today, isDue, graceDay: today);

  /// Like [scheduledStreak] but strictly before [day], with no grace.
  static int scheduledStreakBefore(
    Set<int> activeDays,
    int day,
    bool Function(int epochDay) isDue,
  ) => _walkBack(activeDays, day - 1, isDue);

  /// Longest schedule-aware run ever.
  static int longestScheduledStreak(
    Set<int> activeDays,
    bool Function(int epochDay) isDue,
  ) {
    if (activeDays.isEmpty) return 0;
    final sorted = activeDays.toList()..sort();
    var best = 0;
    var run = 0;
    for (var day = sorted.first; day <= sorted.last; day++) {
      if (activeDays.contains(day)) {
        run++;
        if (run > best) best = run;
      } else if (isDue(day)) {
        run = 0;
      }
    }
    return best;
  }

  static int _walkBack(
    Set<int> activeDays,
    int from,
    bool Function(int epochDay) isDue, {
    int? graceDay,
  }) {
    var count = 0;
    for (var day = from; day > from - _lookbackDays; day--) {
      if (activeDays.contains(day)) {
        count++;
      } else if (isDue(day) && day != graceDay) {
        break;
      }
    }
    return count;
  }
}
