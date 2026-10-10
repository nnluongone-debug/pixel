import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/domain/analytics/badge_evaluator.dart';
import 'package:pixel_quest/domain/analytics/history_index.dart';
import 'package:pixel_quest/domain/analytics/month_heatmap.dart';
import 'package:pixel_quest/domain/analytics/pixel_badge.dart';

import 'analytics_fixtures.dart';

void main() {
  group('MonthHeatmap', () {
    test('pads to whole Monday-first weeks', () {
      final index = HistoryIndex(habits: [makeHabit('a')], records: []);
      // October 2026 starts on Thursday and ends on Saturday.
      final map = MonthHeatmap.build(
        index: index,
        year: 2026,
        month: 10,
        today: todayEpoch,
      );
      expect(map.cells.length % 7, 0);
      expect(map.cells.first.date, DateTime(2026, 9, 28));
      expect(map.cells.first.inMonth, isFalse);
      expect(map.cells.last.date, DateTime(2026, 11, 1));
      expect(map.cells.where((c) => c.isToday).single.date.day, 10);
      expect(map.cells.where((c) => c.isFuture).isNotEmpty, isTrue);
    });

    test('levels follow completed share and rate stops at today', () {
      final a = makeHabit('a');
      final b = makeHabit('b');
      final c = makeHabit('c');
      final d = makeHabit('d');
      final index = HistoryIndex(
        habits: [a, b, c, d],
        records: [
          record('a', todayEpoch - 1),
          record('a', todayEpoch - 2),
          record('b', todayEpoch - 2),
          record('a', todayEpoch - 3),
          record('b', todayEpoch - 3),
          record('c', todayEpoch - 3),
          for (final h in ['a', 'b', 'c', 'd']) record(h, todayEpoch - 4),
        ],
      );
      final map = MonthHeatmap.build(
        index: index,
        year: 2026,
        month: 10,
        today: todayEpoch,
      );
      int level(int ago) => map.cells
          .firstWhere((x) => x.inMonth && x.date.day == 10 - ago)
          .level;
      expect(
        [level(1), level(2), level(3), level(4), level(0)],
        [1, 2, 3, 4, 0],
      );
      expect(map.perfectDays, 1);
      expect(map.rate.due, 40); // Oct 1..10 x 4 habits
      expect(map.rate.done, 10);
    });

    test('a future month has no rate', () {
      final index = HistoryIndex(habits: [makeHabit('a')], records: []);
      final map = MonthHeatmap.build(
        index: index,
        year: 2026,
        month: 12,
        today: todayEpoch,
      );
      expect(map.rate.percent, isNull);
      expect(map.cells.every((c) => c.level == 0), isTrue);
    });
  });

  group('BadgeEvaluator', () {
    BadgeStatus find(List<BadgeStatus> all, BadgeDefinition d) =>
        all.firstWhere((s) => s.definition.id == d.id);

    test('empty history unlocks nothing and shows progress', () {
      final all = BadgeEvaluator.evaluate(
        HistoryIndex(habits: [], records: []),
        todayEpoch,
      );
      expect(all.length, BadgeCatalog.all.length);
      expect(all.any((s) => s.isUnlocked), isFalse);
      final warrior = find(all, BadgeCatalog.warrior);
      expect(warrior.progressKind, BadgeProgressKind.streakDays);
      expect((warrior.progress, warrior.goal), (0, 7));
    });

    test('streak badges unlock on the day the run reaches the goal', () {
      final records = [
        ...daysAgo('a', [30, 29, 28, 27, 26, 25, 24]), // 7-run ends today-24
        ...daysAgo('a', [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]), // 10-run ends -1
      ];
      final index = HistoryIndex(habits: [makeHabit('a')], records: records);
      final all = BadgeEvaluator.evaluate(index, todayEpoch);
      expect(find(all, BadgeCatalog.firstBlock).unlockedDay, todayEpoch - 30);
      expect(find(all, BadgeCatalog.warrior).unlockedDay, todayEpoch - 24);
      expect(find(all, BadgeCatalog.lineClearer).unlockedDay, todayEpoch - 1);
      expect(find(all, BadgeCatalog.legend).isUnlocked, isFalse);
      final legend = find(all, BadgeCatalog.legend);
      expect((legend.progress, legend.goal), (10, 30));
    });

    test('block count badges unlock on the nth block', () {
      final records = [
        for (var i = 0; i < 25; i++) record('a', todayEpoch - 100 + i),
      ];
      final all = BadgeEvaluator.evaluate(
        HistoryIndex(habits: [makeHabit('a')], records: records),
        todayEpoch,
      );
      expect(find(all, BadgeCatalog.brickLayer).unlockedDay, todayEpoch - 76);
      final master = find(all, BadgeCatalog.brickMaster);
      expect(master.progressKind, BadgeProgressKind.blocks);
      expect((master.progress, master.goal), (25, 100));
    });

    test('perfect day, perfect week and levels', () {
      final a = makeHabit('a');
      final b = makeHabit('b', schedule: HabitSchedule.weekdays);
      // Seven perfect days: Mon Oct 5 .. Sun Oct 11 is not reachable, so use
      // Sun Sep 27 .. Sat Oct 3 (b is due Mon-Fri only).
      final start = todayEpoch - 13;
      final recs = [
        for (var i = 0; i < 7; i++) record('a', start + i, xp: 300),
        for (var i = 0; i < 7; i++)
          if (b.schedule.includesEpochDay(start + i)) record('b', start + i),
      ];
      final all = BadgeEvaluator.evaluate(
        HistoryIndex(habits: [a, b], records: recs),
        todayEpoch,
      );
      expect(find(all, BadgeCatalog.perfectDay).unlockedDay, start);
      expect(find(all, BadgeCatalog.perfectWeek).unlockedDay, start + 6);
      // 300 XP per record: level 2 needs 100, level 5 needs 100+150+200+250.
      expect(find(all, BadgeCatalog.level5).unlockedDay, start + 2);
      expect(find(all, BadgeCatalog.level10).isUnlocked, isFalse);
    });

    test('an unfinished today does not break a perfect run', () {
      final a = makeHabit('a');
      final recs = [for (var i = 1; i <= 7; i++) record('a', todayEpoch - i)];
      final all = BadgeEvaluator.evaluate(
        HistoryIndex(habits: [a], records: recs),
        todayEpoch,
      );
      expect(find(all, BadgeCatalog.perfectWeek).unlockedDay, todayEpoch - 1);
    });
  });
}
