/// One stored check-in, reduced to what analytics needs.
class CheckInRecord {
  const CheckInRecord({
    required this.habitId,
    required this.epochDay,
    required this.xp,
  });

  final String habitId;

  /// Days since 1970-01-01 of the local calendar day (`check_ins.grid_x`).
  final int epochDay;
  final int xp;
}

/// Epoch-day to calendar-date conversion.
abstract final class EpochDays {
  /// Local midnight of [epochDay]. Built from calendar fields so DST shifts
  /// never move the result to a neighbouring day.
  static DateTime toDate(int epochDay) => DateTime(1970, 1, 1 + epochDay);
}
