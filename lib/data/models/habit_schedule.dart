/// Which weekdays a habit is due, stored as a bitmask in
/// `habits.schedule_days`: bit 0 = Monday … bit 6 = Sunday.
extension type const HabitSchedule(int mask) {
  static const HabitSchedule daily = HabitSchedule(0x7F);
  static const HabitSchedule weekdays = HabitSchedule(0x1F);

  /// Builds a schedule from ISO weekdays (`DateTime.monday` … `sunday`).
  factory HabitSchedule.fromWeekdays(Iterable<int> weekdays) {
    var mask = 0;
    for (final day in weekdays) {
      if (day < DateTime.monday || day > DateTime.sunday) {
        throw ArgumentError.value(day, 'weekday', 'Must be 1-7');
      }
      mask |= 1 << (day - 1);
    }
    return HabitSchedule(mask);
  }

  bool get isValid => mask > 0 && mask <= 0x7F;

  /// [weekday] is ISO: `DateTime.monday` (1) … `DateTime.sunday` (7).
  bool includesWeekday(int weekday) => mask & (1 << (weekday - 1)) != 0;

  bool includes(DateTime date) => includesWeekday(date.weekday);

  /// Weekday for an epoch day (1970-01-01 was a Thursday).
  static int weekdayOfEpochDay(int epochDay) => (epochDay + 3) % 7 + 1;

  bool includesEpochDay(int epochDay) =>
      includesWeekday(weekdayOfEpochDay(epochDay));

  List<int> get dueWeekdays => [
    for (var d = DateTime.monday; d <= DateTime.sunday; d++)
      if (includesWeekday(d)) d,
  ];

  HabitCadence get cadence => switch (this) {
    daily => HabitCadence.daily,
    weekdays => HabitCadence.weekdays,
    _ => HabitCadence.custom,
  };
}

/// The three cadence presets offered in the editor.
enum HabitCadence { daily, weekdays, custom }
