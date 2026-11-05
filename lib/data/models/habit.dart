import 'habit_schedule.dart';

export 'habit_schedule.dart';

enum HabitType {
  /// Discrete units, e.g. glasses of water, pages.
  counter,

  /// Done / not done. Target is normally 1.
  checklist,

  /// Minutes of focused time.
  timer;

  static HabitType fromName(String name) => HabitType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => throw FormatException('Unknown habit type', name),
  );
}

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.target,
    required this.currentProgress,
    required this.colorHex,
    required this.iconName,
    required this.createdAt,
    this.unit = '',
    this.schedule = HabitSchedule.daily,
    this.reminderTimes = const [],
    this.reminderEvery,
    this.reminderFrom = defaultReminderFrom,
    this.reminderTo = defaultReminderTo,
    this.progressDate,
  });

  static const Object _keep = Object();

  /// Most daily reminder times a habit may have.
  static const int maxReminderTimes = 5;

  /// Choices for "every N minutes" reminders.
  static const List<int> reminderEveryChoices = [15, 30, 45, 60, 90, 120, 180];

  /// Default repeat window: 08:00–22:00.
  static const int defaultReminderFrom = 8 * 60;
  static const int defaultReminderTo = 22 * 60;

  final String id;
  final String name;
  final HabitType type;
  final int target;

  /// Progress for [progressDate]. Resets to 0 when a new day starts.
  final int currentProgress;
  final String colorHex;
  final String iconName;

  /// Short unit label shown after counters, e.g. `GL`, `PG`. Timers are
  /// always minutes and ignore it.
  final String unit;
  final DateTime createdAt;

  /// Weekdays the habit is due. Streaks skip days outside it.
  final HabitSchedule schedule;

  /// Reminder times as minutes after local midnight, sorted and unique;
  /// empty = no reminder.
  final List<int> reminderTimes;

  /// Repeat interval in minutes ("every N minutes"); null = use the fixed
  /// [reminderTimes] instead.
  final int? reminderEvery;

  /// Repeat window, minutes after midnight (inclusive start and end).
  final int reminderFrom;
  final int reminderTo;

  bool get hasReminder => reminderEvery != null || reminderTimes.isNotEmpty;

  /// Every time of day a reminder fires: the repeat slots within the window
  /// when [reminderEvery] is set, otherwise [reminderTimes].
  List<int> get reminderSlots {
    final every = reminderEvery;
    if (every == null || every <= 0) return reminderTimes;
    return [for (var m = reminderFrom; m <= reminderTo; m += every) m];
  }

  /// `480,1230` ↔ [480, 1230] for the `reminder_times` column.
  static String encodeTimes(List<int> times) => times.join(',');

  static List<int> decodeTimes(String? csv) {
    if (csv == null || csv.isEmpty) return const [];
    final times = {
      for (final part in csv.split(',')) ?int.tryParse(part.trim()),
    }.toList()..sort();
    return times;
  }

  /// `YYYY-MM-DD` day that [currentProgress] belongs to.
  final String? progressDate;

  bool get isCompleted => currentProgress >= target;

  bool isDueOn(DateTime date) => schedule.includes(date);

  double get completionRatio =>
      target <= 0 ? 0 : (currentProgress / target).clamp(0.0, 1.0);

  Habit copyWith({
    String? name,
    HabitType? type,
    int? target,
    int? currentProgress,
    String? colorHex,
    String? iconName,
    String? unit,
    HabitSchedule? schedule,
    List<int>? reminderTimes,
    Object? reminderEvery = _keep,
    int? reminderFrom,
    int? reminderTo,
    String? progressDate,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      unit: unit ?? this.unit,
      schedule: schedule ?? this.schedule,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      reminderEvery: identical(reminderEvery, _keep)
          ? this.reminderEvery
          : reminderEvery as int?,
      reminderFrom: reminderFrom ?? this.reminderFrom,
      reminderTo: reminderTo ?? this.reminderTo,
      createdAt: createdAt,
      progressDate: progressDate ?? this.progressDate,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'type': type.name,
    'target': target,
    'current_progress': currentProgress,
    'color_hex': colorHex,
    'icon_name': iconName,
    'unit': unit,
    'schedule_days': schedule.mask,
    'reminder_times': encodeTimes(reminderTimes),
    'reminder_every': reminderEvery,
    'reminder_from': reminderFrom,
    'reminder_to': reminderTo,
    'created_at': createdAt.toUtc().toIso8601String(),
    'progress_date': progressDate,
  };

  factory Habit.fromMap(Map<String, Object?> map) => Habit(
    id: map['id']! as String,
    name: map['name']! as String,
    type: HabitType.fromName(map['type']! as String),
    target: map['target']! as int,
    currentProgress: map['current_progress']! as int,
    colorHex: map['color_hex']! as String,
    iconName: map['icon_name']! as String,
    unit: map['unit'] as String? ?? '',
    schedule: HabitSchedule(map['schedule_days'] as int? ?? 0x7F),
    reminderEvery: map['reminder_every'] as int?,
    reminderFrom: map['reminder_from'] as int? ?? defaultReminderFrom,
    reminderTo: map['reminder_to'] as int? ?? defaultReminderTo,
    reminderTimes: switch (decodeTimes(map['reminder_times'] as String?)) {
      // Rows from before multi-time reminders only have the old column.
      final t when t.isEmpty && map['reminder_minutes'] is int => [
        map['reminder_minutes']! as int,
      ],
      final t => t,
    },
    createdAt: DateTime.parse(map['created_at']! as String).toLocal(),
    progressDate: map['progress_date'] as String?,
  );
}
