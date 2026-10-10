import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/models/user_stats.dart';
import 'package:pixel_quest/domain/analytics/analytics_range.dart';
import 'package:pixel_quest/domain/analytics/analytics_summary.dart';
import 'package:pixel_quest/domain/analytics/habit_consistency.dart';
import 'package:pixel_quest/domain/analytics/history_index.dart';

import 'analytics_fixtures.dart';

void main() {
  group('HistoryIndex', () {
    test('a habit is not due before it was created', () {
      final h = makeHabit('a', created: DateTime(2026, 10, 8));
      final index = HistoryIndex(habits: [h], records: []);
      expect(index.isDue(h, todayEpoch - 3), isFalse);
      expect(index.isDue(h, todayEpoch - 2), isTrue);
    });

    test('schedule limits due days to selected weekdays', () {
      final h = makeHabit('a', schedule: HabitSchedule.weekdays);
      final index = HistoryIndex(habits: [h], records: []);
      expect(index.isDue(h, todayEpoch), isFalse); // Saturday
      expect(index.isDue(h, todayEpoch - 1), isTrue); // Friday
    });

    test('tally counts only due habits and ignores off-day check-ins', () {
      final daily = makeHabit('d');
      final weekdays = makeHabit('w', schedule: HabitSchedule.weekdays);
      final index = HistoryIndex(
        habits: [daily, weekdays],
        records: [record('d', todayEpoch), record('w', todayEpoch)],
      );
      final t = index.tally(todayEpoch); // Saturday: only daily is due
      expect((t.done, t.due, t.isPerfect), (1, 1, true));
      expect(index.tally(todayEpoch - 1).percent, 0);
    });

    test('tally ratio is null when nothing is due', () {
      final index = HistoryIndex(habits: [], records: []);
      expect(index.tally(todayEpoch).ratio, isNull);
      expect(index.firstDay, isNull);
    });

    test('firstDay is the oldest habit or check-in', () {
      final h = makeHabit('a', created: DateTime(2026, 10, 1));
      final index = HistoryIndex(
        habits: [h],
        records: [record('a', todayEpoch - 20)],
      );
      expect(index.firstDay, todayEpoch - 20);
    });
  });

  group('AnalyticsRange', () {
    test('windows end today and previous window abuts', () {
      final w = AnalyticsRange.week.window(100, null);
      expect((w.start, w.end, w.length), (94, 100, 7));
      final p = AnalyticsRange.week.previousWindow(100)!;
      expect((p.start, p.end), (87, 93));
      expect(AnalyticsRange.allTime.previousWindow(100), isNull);
      expect(AnalyticsRange.allTime.window(100, 40).start, 40);
    });
  });

  group('AnalyticsSummary', () {
    UserStats stats(int streak) => UserStats(
      currentLevel: 1,
      currentXp: 0,
      targetXp: 100,
      streakDays: streak,
    );

    test('rate, blocks, perfect clears and best streak', () {
      final a = makeHabit('a');
      final b = makeHabit('b');
      final index = HistoryIndex(
        habits: [a, b],
        records: [
          ...daysAgo('a', [0, 1, 2, 3]),
          ...daysAgo('b', [1, 2]),
          ...daysAgo('a', [10, 11, 12, 13, 14]),
        ],
      );
      final s = AnalyticsSummary.compute(
        index: index,
        range: AnalyticsRange.week,
        today: todayEpoch,
        stats: stats(4),
      );
      expect(s.rate.done, 6);
      expect(s.rate.due, 14);
      expect(s.blocks, 6);
      expect(s.perfectClears, 2);
      expect(s.currentStreak, 4);
      expect(s.bestStreak, 5);
    });

    test('delta compares with the previous equal window', () {
      final a = makeHabit('a');
      final index = HistoryIndex(
        habits: [a],
        records: [
          ...daysAgo('a', [0, 1, 2, 3, 4, 5, 6]),
          ...daysAgo('a', [7, 8, 9]),
        ],
      );
      final s = AnalyticsSummary.compute(
        index: index,
        range: AnalyticsRange.week,
        today: todayEpoch,
        stats: stats(10),
      );
      expect(s.rateDelta, closeTo(100 - 3 / 7 * 100, 1e-9));
    });

    test(
      'delta is null for All Time and when previous window had no habits',
      () {
        final a = makeHabit('a', created: DateTime(2026, 10, 9));
        final index = HistoryIndex(habits: [a], records: []);
        for (final range in [AnalyticsRange.allTime, AnalyticsRange.week]) {
          final s = AnalyticsSummary.compute(
            index: index,
            range: range,
            today: todayEpoch,
            stats: stats(0),
          );
          expect(s.rateDelta, isNull, reason: range.name);
        }
      },
    );
  });

  group('HabitConsistency', () {
    test('counts due vs met days since creation, streak is schedule-aware', () {
      final h = makeHabit(
        'a',
        created: DateTime(2026, 10, 5),
        schedule: HabitSchedule.weekdays,
        type: HabitType.timer,
        target: 25,
      );
      // Created Mon Oct 5; due Mon-Fri = 5 days up to Fri Oct 9.
      final index = HistoryIndex(
        habits: [h],
        records: [
          record('a', todayEpoch - 5), // Mon
          record('a', todayEpoch - 4), // Tue
          record('a', todayEpoch - 1), // Fri
        ],
      );
      final c = HabitConsistency.compute(
        index: index,
        window: AnalyticsRange.month.window(todayEpoch, null),
        today: todayEpoch,
      ).single;
      expect((c.metDays, c.dueDays, c.percent), (3, 5, 60));
      expect(c.minimumTotal, 75);
      expect(c.streak, 1); // Wed/Thu missed
    });
  });
}
