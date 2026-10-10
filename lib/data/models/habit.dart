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
    this.reminderMinutes,
    this.progressDate,
  });

  static const Object _keep = Object();

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

  /// Daily reminder as minutes after local midnight; null = no reminder.
  final int? reminderMinutes;

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
    Object? reminderMinutes = _keep,
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
      reminderMinutes: identical(reminderMinutes, _keep)
          ? this.reminderMinutes
          : reminderMinutes as int?,
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
    'reminder_minutes': reminderMinutes,
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
    reminderMinutes: map['reminder_minutes'] as int?,
    createdAt: DateTime.parse(map['created_at']! as String).toLocal(),
    progressDate: map['progress_date'] as String?,
  );
}
