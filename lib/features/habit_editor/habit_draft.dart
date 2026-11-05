import '../../core/l10n/l10n.dart';
import '../../data/models/habit.dart';
import '../../domain/templates/habit_template.dart';

/// Reasons a draft cannot be saved; the sheet maps them to localized text.
enum HabitDraftError { titleEmpty, noDays, quota, window }

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
    this.remindersOn = false,
    this.repeatMode = false,
    this.reminderTimes = const [],
    this.reminderEvery = 60,
    this.reminderFrom = Habit.defaultReminderFrom,
    this.reminderTo = Habit.defaultReminderTo,
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
    remindersOn: habit.hasReminder,
    repeatMode: habit.reminderEvery != null,
    reminderTimes: habit.reminderTimes,
    reminderEvery: habit.reminderEvery ?? 60,
    reminderFrom: habit.reminderFrom,
    reminderTo: habit.reminderTo,
  );

  final String name;
  final String iconName;
  final String colorHex;
  final HabitCadence cadence;
  final Set<int> customDays;
  final HabitType type;
  final String unit;
  final int target;

  /// Master switch; off stores no reminder whatever the other fields hold.
  final bool remindersOn;

  /// True = "repeat every N minutes", false = specific times. Both modes
  /// keep their values while the user flips between them.
  final bool repeatMode;

  /// Specific times: minutes after midnight, sorted and unique.
  final List<int> reminderTimes;

  /// Repeat mode: interval in minutes and inclusive window.
  final int reminderEvery;
  final int reminderFrom;
  final int reminderTo;

  bool get windowValid => reminderTo > reminderFrom;

  /// Fire times of repeat mode, as [Habit.reminderSlots] computes them.
  List<int> get repeatSlots => [
    for (var m = reminderFrom; m <= reminderTo; m += reminderEvery) m,
  ];

  /// Values to persist: nothing when off, `reminderEvery` only in repeat mode.
  List<int> get savedTimes => remindersOn ? reminderTimes : const [];
  int? get savedEvery => remindersOn && repeatMode ? reminderEvery : null;

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
    final badWindow = remindersOn && repeatMode && !windowValid;
    if (badWindow) return HabitDraftError.window;
    return null;
  }

  HabitDraft withUnit(HabitUnitOption option) => copyWith(
    type: option.type,
    unit: option.unit,
    target: option.defaultTarget,
  );

  /// Fills identity, color, cadence and quota from [t]; reminders stay.
  HabitDraft withTemplate(HabitTemplate t, String languageCode) {
    final cadence = t.schedule.cadence;
    return copyWith(
      name: t.nameFor(languageCode),
      iconName: t.iconName,
      colorHex: t.colorHex,
      cadence: cadence,
      customDays: cadence == HabitCadence.custom
          ? t.schedule.dueWeekdays.toSet()
          : null,
      type: t.type,
      unit: t.unit,
      target: t.target,
    );
  }

  HabitDraft copyWith({
    String? name,
    String? iconName,
    String? colorHex,
    HabitCadence? cadence,
    Set<int>? customDays,
    HabitType? type,
    String? unit,
    int? target,
    bool? remindersOn,
    bool? repeatMode,
    List<int>? reminderTimes,
    int? reminderEvery,
    int? reminderFrom,
    int? reminderTo,
  }) => HabitDraft(
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
    cadence: cadence ?? this.cadence,
    customDays: customDays ?? this.customDays,
    type: type ?? this.type,
    unit: unit ?? this.unit,
    target: target ?? this.target,
    remindersOn: remindersOn ?? this.remindersOn,
    repeatMode: repeatMode ?? this.repeatMode,
    reminderTimes: reminderTimes ?? this.reminderTimes,
    reminderEvery: reminderEvery ?? this.reminderEvery,
    reminderFrom: reminderFrom ?? this.reminderFrom,
    reminderTo: reminderTo ?? this.reminderTo,
  );
}
