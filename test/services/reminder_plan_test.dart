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
  List<int> reminders = const [510],
  int? every,
  int from = 480,
  int to = 1320,
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
  reminderTimes: reminders,
  reminderEvery: every,
  reminderFrom: from,
  reminderTo: to,
);

void main() {
  group('buildReminderPlan', () {
    test('skips habits without reminder', () {
      expect(buildReminderPlan([habit(reminders: const [])], en), isEmpty);
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

    test('one entry per time and due weekday with unique ids', () {
      final plan = buildReminderPlan([
        habit(id: 'a', reminders: const [480, 720, 1230]),
        habit(
          id: 'b',
          schedule: HabitSchedule.weekdays,
          reminders: const [600, 1200],
        ),
      ], en);
      expect(plan, hasLength(3 + 2 * 5));
      expect(plan.map((e) => e.id).toSet(), hasLength(plan.length));
      expect(plan.where((e) => e.habitId == 'a').map((e) => e.minutes), [
        480,
        720,
        1230,
      ]);
    });

    test('max times on a custom week stays unique and cap applies', () {
      final plan = buildReminderPlan([
        for (var i = 0; i < 3; i++)
          habit(
            id: 'h$i',
            schedule: HabitSchedule.fromWeekdays([1, 2, 3, 4, 5, 6]),
            reminders: const [60, 120, 180, 240, 300],
          ),
      ], en);
      expect(plan, hasLength(90));
      expect(plan.map((e) => e.id).toSet(), hasLength(90));
      expect(
        capReminderPlan(plan, DateTime(2026, 10, 10, 9)),
        hasLength(maxPendingReminders),
      );
    });

    test('repeat habit expands the window into slots', () {
      final plan = buildReminderPlan([
        habit(reminders: const [], every: 120, from: 480, to: 720),
      ], en);
      expect(plan.map((e) => e.minutes), [480, 600, 720]);
      expect(plan.every((e) => e.weekday == null), isTrue);
    });

    test('repeat habit on weekdays gets one entry per slot and day', () {
      final plan = buildReminderPlan([
        habit(
          schedule: HabitSchedule.weekdays,
          reminders: const [],
          every: 60,
          from: 480,
          to: 600,
        ),
      ], en);
      expect(plan, hasLength(3 * 5));
      expect(plan.map((e) => e.id).toSet(), hasLength(15));
    });

    test('invalid window yields no entries', () {
      expect(
        buildReminderPlan([
          habit(reminders: const [], every: 60, from: 600, to: 480),
        ], en),
        isEmpty,
      );
    });

    test('15-minute all-day repeat has unique ids and is capped', () {
      final plan = buildReminderPlan([
        habit(id: 'a', reminders: const [], every: 15, from: 0, to: 1439),
        habit(id: 'b', reminders: const [], every: 15, from: 0, to: 1439),
      ], en);
      expect(plan, hasLength(192));
      expect(plan.map((e) => e.id).toSet(), hasLength(192));
      expect(plan.every((e) => e.id < 1 << 31), isTrue);
      expect(
        capReminderPlan(plan, DateTime(2026, 10, 10, 9)),
        hasLength(maxPendingReminders),
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
