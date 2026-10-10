import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/check_in.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/models/user_stats.dart';
import 'package:pixel_quest/services/home_widget_snapshot.dart';

Habit habit(
  String id,
  String color, {
  HabitType type = HabitType.counter,
  int target = 4,
  int progress = 0,
  String? progressDate = '2026-10-14',
  HabitSchedule schedule = HabitSchedule.daily,
}) => Habit(
  id: id,
  name: 'Habit $id',
  type: type,
  target: target,
  currentProgress: progress,
  colorHex: color,
  iconName: 'water_drop',
  createdAt: DateTime(2026, 1, 1),
  unit: 'GL',
  schedule: schedule,
  progressDate: progressDate,
);

CheckIn block(String habitId, String date, int y) => CheckIn(
  id: '$habitId$date',
  habitId: habitId,
  date: date,
  xpEarned: 10,
  gridX: 0,
  gridY: y,
);

void main() {
  // Wednesday of ISO week 42, 2026.
  final now = DateTime(2026, 10, 14, 9);
  const stats = UserStats(
    currentLevel: 3,
    currentXp: 40,
    targetXp: 100,
    streakDays: 5,
  );

  test('builds header, week info and JSON-encodable structure', () {
    final s = HomeWidgetSnapshot.build(
      now: now,
      habits: [habit('a', '#2DE38E')],
      checkIns: [],
      stats: stats,
    );
    expect(s['today'], '2026-10-14');
    expect(s['level'], 3);
    expect(s['streak'], 5);
    expect(s['weekNumber'], 42);
    expect(s['weekStart'], '2026-10-12');
    expect(s['weekEnd'], '2026-10-18');
    expect((s['skyline']! as List).length, 7);
    expect((s['tower']! as List).length, 12);
    expect((s['skyline']! as List).last, containsPair('date', '2026-10-14'));
  });

  test('counts done and due habits, ignores stale progress and off days', () {
    final s = HomeWidgetSnapshot.build(
      now: now,
      habits: [
        habit('done', '#2DE38E', progress: 4),
        habit('stale', '#00D2FF', progress: 4, progressDate: '2026-10-13'),
        habit(
          'weekend',
          '#FF7675',
          schedule: HabitSchedule.fromWeekdays([6, 7]),
        ),
      ],
      checkIns: [],
      stats: stats,
      habitStreaks: {'done': 7},
    );
    expect(s['todayTotal'], 2);
    expect(s['todayDone'], 1);
    final habits = (s['habits']! as List).cast<Map<String, Object?>>();
    expect(habits[0]['streak'], 7);
    expect(habits[1]['progress'], 0);
    expect(habits[2]['dueToday'], false);
  });

  test('orders block colors bottom-up and skips deleted habits', () {
    final s = HomeWidgetSnapshot.build(
      now: now,
      habits: [habit('a', '#2DE38E'), habit('b', '#00D2FF')],
      checkIns: [
        block('b', '2026-10-14', 1),
        block('a', '2026-10-14', 0),
        block('gone', '2026-10-14', 2),
      ],
      stats: stats,
    );
    final today = (s['skyline']! as List).last as Map<String, Object?>;
    expect(today['colors'], ['#2DE38E', '#00D2FF']);
  });

  test('week blocks only count the current Monday-Sunday week', () {
    final s = HomeWidgetSnapshot.build(
      now: now,
      habits: [habit('a', '#2DE38E')],
      checkIns: [
        block('a', '2026-10-11', 0),
        block('a', '2026-10-12', 0),
        block('a', '2026-10-14', 0),
      ],
      stats: stats,
    );
    expect(s['weekBlocks'], 2);
  });
}
