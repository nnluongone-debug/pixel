import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habits/habit_display_format.dart';
import 'package:pixel_quest/l10n/app_localizations_en.dart';
import 'package:pixel_quest/l10n/app_localizations_vi.dart';

Habit habit(HabitType type, int progress, int target, {String unit = ''}) =>
    Habit(
      id: 'h',
      name: 'Test',
      type: type,
      target: target,
      currentProgress: progress,
      colorHex: '#00E5FF',
      iconName: 'water_drop',
      createdAt: DateTime(2026),
      unit: unit,
    );

void main() {
  final en = AppLocalizationsEn();
  final vi = AppLocalizationsVi();

  test('badges are localized', () {
    expect(
      HabitDisplay.badge(vi, habit(HabitType.counter, 5, 8, unit: 'GL')),
      '5/8 LY',
    );
    expect(
      HabitDisplay.badge(vi, habit(HabitType.checklist, 1, 1), streak: 15),
      'CHUỖI 15N',
    );
    expect(
      HabitDisplay.badge(vi, habit(HabitType.timer, 210, 240)),
      '3.5 / 4 GIỜ',
    );
  });

  test('badges per habit type', () {
    expect(
      HabitDisplay.badge(en, habit(HabitType.counter, 5, 8, unit: 'GL')),
      '5/8 GL',
    );
    expect(
      HabitDisplay.badge(en, habit(HabitType.checklist, 1, 1), streak: 15),
      '15D STREAK',
    );
    expect(
      HabitDisplay.badge(en, habit(HabitType.timer, 210, 240)),
      '3.5 / 4 HRS',
    );
    expect(
      HabitDisplay.badge(en, habit(HabitType.timer, 20, 30)),
      '20 / 30 MIN',
    );
    expect(
      HabitDisplay.badge(
        en,
        habit(HabitType.timer, 0, 240),
        focusElapsed: const Duration(minutes: 4, seconds: 7),
      ),
      'FOCUS 04:07',
    );
  });

  test('clock switches to hours past 60 minutes', () {
    expect(HabitDisplay.clock(const Duration(seconds: 3723)), '1:02:03');
  });

  test('mini bar segments', () {
    final water = habit(HabitType.counter, 5, 8);
    expect(HabitDisplay.segmentCount(water), 8);
    expect(HabitDisplay.filledSegments(water), 5);

    final focus = habit(HabitType.timer, 210, 240);
    expect(HabitDisplay.filledSegments(focus), 7);

    final small = habit(HabitType.counter, 2, 3);
    expect(HabitDisplay.segmentCount(small), 3);
    expect(HabitDisplay.filledSegments(habit(HabitType.counter, 9, 3)), 3);

    final workout = habit(HabitType.checklist, 1, 1);
    expect(HabitDisplay.filledSegments(workout, streak: 15), 8);
  });
}
