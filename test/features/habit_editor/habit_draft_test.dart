import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habit_editor/habit_draft.dart';

void main() {
  const base = HabitDraft(name: 'Read');

  test('repeat window with TO <= FROM is rejected', () {
    final draft = base.copyWith(
      remindersOn: true,
      repeatMode: true,
      reminderFrom: 600,
      reminderTo: 600,
    );
    expect(draft.error, HabitDraftError.window);
    expect(draft.copyWith(reminderTo: 601).error, isNull);
  });

  test('window is ignored when reminders are off or in specific mode', () {
    final bad = base.copyWith(reminderFrom: 900, reminderTo: 600);
    expect(bad.error, isNull);
    expect(bad.copyWith(remindersOn: true).error, isNull);
  });

  test('saved values: off stores nothing, interval only in repeat mode', () {
    final draft = base.copyWith(
      remindersOn: true,
      reminderTimes: const [600],
      reminderEvery: 90,
    );
    expect(draft.savedEvery, isNull);
    expect(draft.savedTimes, [600]);
    expect(draft.copyWith(repeatMode: true).savedEvery, 90);
    final off = draft.copyWith(remindersOn: false, repeatMode: true);
    expect(off.savedEvery, isNull);
    expect(off.savedTimes, isEmpty);
  });

  test('repeat slots span the inclusive window', () {
    final draft = base.copyWith(
      reminderEvery: 30,
      reminderFrom: 480,
      reminderTo: 570,
    );
    expect(draft.repeatSlots, [480, 510, 540, 570]);
  });

  test('fromHabit restores repeat mode and keeps specific times', () {
    final habit = Habit(
      id: 'h',
      name: 'Read',
      type: HabitType.counter,
      target: 1,
      currentProgress: 0,
      colorHex: '#2DE38E',
      iconName: 'book',
      createdAt: DateTime(2026),
      reminderTimes: const [600],
      reminderEvery: 45,
      reminderFrom: 540,
      reminderTo: 1080,
    );
    final draft = HabitDraft.fromHabit(habit);
    expect(draft.remindersOn, isTrue);
    expect(draft.repeatMode, isTrue);
    expect(draft.reminderEvery, 45);
    expect(draft.reminderTimes, [600]);
    expect(draft.reminderFrom, 540);
    expect(draft.reminderTo, 1080);
  });
}
