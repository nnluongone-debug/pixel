import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';

void main() {
  test('reminder times round-trip as a sorted, unique CSV', () {
    expect(Habit.encodeTimes([480, 1230]), '480,1230');
    expect(Habit.decodeTimes('1230,480,480, 60'), [60, 480, 1230]);
    expect(Habit.decodeTimes(''), isEmpty);
    expect(Habit.decodeTimes(null), isEmpty);
    expect(Habit.decodeTimes('x,90'), [90]);
  });

  test('rows from before multi-time reminders keep their single time', () {
    final legacy = Habit.fromMap({
      'id': 'h',
      'name': 'Read',
      'type': 'counter',
      'target': 1,
      'current_progress': 0,
      'color_hex': '#2DE38E',
      'icon_name': 'book',
      'created_at': '2026-10-01T00:00:00.000Z',
      'reminder_minutes': 1230,
    });
    expect(legacy.reminderTimes, [1230]);
    expect(legacy.toMap()['reminder_times'], '1230');
  });

  test('repeat reminders expand into slots inside the window', () {
    final h = Habit(
      id: 'h',
      name: 'Water',
      type: HabitType.counter,
      target: 8,
      currentProgress: 0,
      colorHex: '#00D2FF',
      iconName: 'water_drop',
      createdAt: DateTime(2026),
      reminderTimes: const [600],
      reminderEvery: 90,
      reminderFrom: 8 * 60,
      reminderTo: 12 * 60,
    );
    // 08:00, 09:30, 11:00 — 12:30 would be past the 12:00 end.
    expect(h.reminderSlots, [480, 570, 660]);
    expect(h.hasReminder, isTrue);
    expect(h.copyWith(reminderEvery: null).reminderSlots, [600]);
    final row = h.toMap();
    expect(
      [row['reminder_every'], row['reminder_from'], row['reminder_to']],
      [90, 480, 720],
    );
    expect(Habit.fromMap(row).reminderSlots, [480, 570, 660]);
  });
}
