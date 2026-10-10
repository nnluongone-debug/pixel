import '../../core/l10n/l10n.dart';
import '../../data/models/habit.dart';

/// Reasons a draft cannot be saved; the sheet maps them to localized text.
enum HabitDraftError { titleEmpty, noDays, quota }

/// A unit chip in the cadence section. Each chip also decides the habit type.
class HabitUnitOption {
  const HabitUnitOption({
    required this.type,
    required this.unit,
    required this.defaultTarget,
  });

  final HabitType type;

  /// Stored in `habits.unit`; empty for timers and checklists.
  final String unit;
  final int defaultTarget;

  /// Localized chip text; the stored [unit] code stays language-neutral.
  String labelOf(AppLocalizations l10n) => switch (type) {
    HabitType.timer => l10n.editorChipMinutes,
    HabitType.checklist => l10n.editorChipCheck,
    HabitType.counter => switch (unit) {
      'PG' => l10n.editorChipPages,
      'GL' => l10n.editorChipGlasses,
      _ => l10n.editorChipTimes,
    },
  };

  static const pages = HabitUnitOption(
    type: HabitType.counter,
    unit: 'PG',
    defaultTarget: 20,
  );
  static const minutes = HabitUnitOption(
    type: HabitType.timer,
    unit: '',
    defaultTarget: 30,
  );
  static const times = HabitUnitOption(
    type: HabitType.counter,
    unit: 'X',
    defaultTarget: 3,
  );
  static const glasses = HabitUnitOption(
    type: HabitType.counter,
    unit: 'GL',
    defaultTarget: 8,
  );
  static const check = HabitUnitOption(
    type: HabitType.checklist,
    unit: '',
    defaultTarget: 1,
  );

  static const all = [pages, minutes, times, glasses, check];
}

/// Editable form state of the habit editor. Immutable; the sheet swaps it
/// on every change.
class HabitDraft {
  const HabitDraft({
    this.name = '',
    this.iconName = 'book',
    this.colorHex = '#2DE38E',
    this.cadence = HabitCadence.daily,
    this.customDays = const {DateTime.monday},
    this.type = HabitType.counter,
    this.unit = 'PG',
    this.target = 20,
    this.reminderMinutes,
  });

  factory HabitDraft.fromHabit(Habit habit) => HabitDraft(
    name: habit.name,
    iconName: habit.iconName,
    colorHex: habit.colorHex,
    cadence: habit.schedule.cadence,
    customDays: habit.schedule.dueWeekdays.toSet(),
    type: habit.type,
    unit: habit.unit,
    target: habit.target,
    reminderMinutes: habit.reminderMinutes,
  );

  static const _keep = Object();

  final String name;
  final String iconName;
  final String colorHex;
  final HabitCadence cadence;
  final Set<int> customDays;
  final HabitType type;
  final String unit;
  final int target;
  final int? reminderMinutes;

  /// Timers step in 5-minute increments, everything else by 1.
  int get step => type == HabitType.timer ? 5 : 1;
  bool get hasQuota => type != HabitType.checklist;

  HabitSchedule get schedule => switch (cadence) {
    HabitCadence.daily => HabitSchedule.daily,
    HabitCadence.weekdays => HabitSchedule.weekdays,
    HabitCadence.custom => HabitSchedule.fromWeekdays(customDays),
  };

  bool isSelected(HabitUnitOption option) =>
      option.type == type && (type != HabitType.counter || option.unit == unit);

  /// First problem that blocks saving, or null when the draft is valid.
  /// Name length is re-checked by the repository; this gives inline errors.
  HabitDraftError? get error {
    if (name.trim().isEmpty) return HabitDraftError.titleEmpty;
    if (!schedule.isValid) return HabitDraftError.noDays;
    if (target <= 0) return HabitDraftError.quota;
    return null;
  }

  HabitDraft withUnit(HabitUnitOption option) => copyWith(
    type: option.type,
    unit: option.unit,
    target: option.defaultTarget,
  );

  HabitDraft copyWith({
    String? name,
    String? iconName,
    String? colorHex,
    HabitCadence? cadence,
    Set<int>? customDays,
    HabitType? type,
    String? unit,
    int? target,
    Object? reminderMinutes = _keep,
  }) => HabitDraft(
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
    cadence: cadence ?? this.cadence,
    customDays: customDays ?? this.customDays,
    type: type ?? this.type,
    unit: unit ?? this.unit,
    target: target ?? this.target,
    reminderMinutes: identical(reminderMinutes, _keep)
        ? this.reminderMinutes
        : reminderMinutes as int?,
  );
}
