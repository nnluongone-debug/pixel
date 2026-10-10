/// Inclusive span of epoch days.
class DayWindow {
  const DayWindow(this.start, this.end);

  final int start;
  final int end;

  int get length => end - start + 1;
}

/// Range chips on the analytics screen.
enum AnalyticsRange {
  week(7),
  month(30),
  year(365),
  allTime(null);

  const AnalyticsRange(this.days);

  /// Window length, or null for the whole history.
  final int? days;

  /// Window ending [today]. All Time starts at [firstDay] (the oldest habit
  /// or check-in), or [today] when there is no history yet.
  DayWindow window(int today, int? firstDay) {
    final length = days;
    if (length == null) return DayWindow(firstDay ?? today, today);
    return DayWindow(today - length + 1, today);
  }

  /// Equally long window right before [window]; null for All Time.
  DayWindow? previousWindow(int today) {
    final length = days;
    if (length == null) return null;
    return DayWindow(today - 2 * length + 1, today - length);
  }
}
