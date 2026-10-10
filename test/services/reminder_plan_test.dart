import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/l10n/app_localizations.dart';
import 'package:pixel_quest/services/reminder_plan.dart';

final en = lookupAppLocalizations(const Locale('en'));
final vi = lookupAppLocalizations(const Locale('vi'));

Habit habit({
  String id = 'h1',
  HabitType type = HabitType.counter,
  int target = 20,
  String unit = 'PG',
  HabitSchedule schedule = HabitSchedule.daily,
  int? reminder = 510,
}) => Habit(
  id: id,
  name: 'Read',
  type: type,
  target: target,
  currentProgress: 0,
  colorHex: '#2DE38E',
  iconName: 'book',
  createdAt: DateTime(2026, 1, 1),
  unit: unit,
  schedule: schedule,
  reminderMinutes: reminder,
);

void main() {
  group('buildReminderPlan', () {
    test('skips habits without reminder', () {
      expect(buildReminderPlan([habit(reminder: null)], en), isEmpty);
    });

    test('daily schedule yields one daily entry', () {
      final plan = buildReminderPlan([habit()], en);
      expect(plan, hasLength(1));
      expect(plan.single.weekday, isNull);
      expect(plan.single.minutes, 510);
      expect(plan.single.body, 'Read — 20 PG today');
    });

    test('custom schedule yields one weekly entry per due weekday', () {
      final plan = buildReminderPlan([
        habit(
          schedule: HabitSchedule.fromWeekdays([
            DateTime.monday,
            DateTime.friday,
          ]),
        ),
      ], en);
      expect(plan.map((e) => e.weekday), [DateTime.monday, DateTime.friday]);
    });

    test('weekdays preset yields five entries', () {
      final plan = buildReminderPlan([
        habit(schedule: HabitSchedule.weekdays),
      ], en);
      expect(plan, hasLength(5));
    });

    test('ids are unique across habits', () {
      final plan = buildReminderPlan([
        habit(id: 'a', schedule: HabitSchedule.weekdays),
        habit(id: 'b'),
        habit(id: 'c', schedule: HabitSchedule.weekdays),
      ], en);
      expect(plan.map((e) => e.id).toSet(), hasLength(plan.length));
    });

    test('body copy per type', () {
      expect(
        reminderBody(habit(type: HabitType.timer, target: 30, unit: ''), en),
        'Read — 30 MIN today',
      );
      expect(
        reminderBody(habit(type: HabitType.checklist, target: 1, unit: ''), en),
        'Read — mark it done today',
      );
      expect(reminderBody(habit(unit: '', target: 3), en), 'Read — 3 today');
    });

    test('body is localized to Vietnamese', () {
      expect(reminderBody(habit(), vi), 'Read — 20 TR hôm nay');
      expect(
        reminderBody(habit(type: HabitType.timer, target: 30, unit: ''), vi),
        'Read — 30 PHÚT hôm nay',
      );
      expect(
        reminderBody(habit(type: HabitType.checklist, unit: ''), vi),
        'Read — hãy đánh dấu hoàn thành hôm nay',
      );
    });

    test('changing language changes the plan', () {
      expect(
        buildReminderPlan([habit()], en),
        isNot(buildReminderPlan([habit()], vi)),
      );
    });

    test('equal plans compare equal', () {
      expect(
        buildReminderPlan([habit()], en),
        buildReminderPlan([habit()], en),
      );
    });
  });

  group('nextReminderTime', () {
    // 2026-10-10 is a Saturday.
    final now = DateTime(2026, 10, 10, 9, 0);

    test('daily later today', () {
      expect(
        nextReminderTime(now, minutes: 10 * 60),
        DateTime(2026, 10, 10, 10),
      );
    });

    test('daily already passed rolls to tomorrow', () {
      expect(nextReminderTime(now, minutes: 8 * 60), DateTime(2026, 10, 11, 8));
    });

    test('exactly now rolls to next occurrence', () {
      expect(nextReminderTime(now, minutes: 9 * 60), DateTime(2026, 10, 11, 9));
    });

    test('weekly picks the next matching weekday', () {
      final next = nextReminderTime(
        now,
        weekday: DateTime.monday,
        minutes: 510,
      );
      expect(next, DateTime(2026, 10, 12, 8, 30));
      expect(next.weekday, DateTime.monday);
    });

    test('same weekday already passed waits a week', () {
      expect(
        nextReminderTime(now, weekday: DateTime.saturday, minutes: 8 * 60),
        DateTime(2026, 10, 17, 8),
      );
    });

    test('rolls over month end', () {
      expect(
        nextReminderTime(DateTime(2026, 10, 31, 23, 0), minutes: 60),
        DateTime(2026, 11, 1, 1),
      );
    });
  });

  test('cap keeps the soonest-firing entries under the iOS limit', () {
    // Saturday 2026-10-10 09:00.
    final now = DateTime(2026, 10, 10, 9);
    final plan = [
      for (var i = 0; i < 70; i++)
        ReminderEntry(
          id: i,
          habitId: 'h$i',
          weekday: i % 7 + 1,
          minutes: 600,
          title: reminderTitle,
          body: 'b',
        ),
    ];
    final capped = capReminderPlan(plan, now);
    expect(capped, hasLength(maxPendingReminders));
    // Saturday 10:00 (weekday 6) fires first, so all 10 of them stay.
    expect(capped.where((e) => e.weekday == 6), hasLength(10));
    // Friday (weekday 5) is the furthest away and is the one trimmed.
    expect(capped.where((e) => e.weekday == 5), isEmpty);
    expect(capReminderPlan(plan.take(5).toList(), now), hasLength(5));
  });
}
