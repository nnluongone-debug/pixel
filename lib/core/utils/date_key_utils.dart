/// Source of "now"; injectable so day-boundary logic is testable.
typedef Clock = DateTime Function();

/// Helpers for the `YYYY-MM-DD` date keys stored in `check_ins.date`.
///
/// Keys are always in the device's local calendar, so a check-in at 23:30
/// belongs to that day, not to the UTC day.
abstract final class DateKeys {
  static String fromDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a key into a local midnight [DateTime]. Throws [FormatException]
  /// on malformed input.
  static DateTime toDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) throw FormatException('Invalid date key', key);
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Days since 1970-01-01 for a local calendar date. Computed in UTC so DST
  /// shifts never produce off-by-one gaps between consecutive days.
  static int epochDay(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    return utc.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  static int epochDayOfKey(String key) => epochDay(toDate(key));

  static String shift(String key, int days) {
    final date = toDate(key);
    return fromDate(DateTime(date.year, date.month, date.day + days));
  }
}
