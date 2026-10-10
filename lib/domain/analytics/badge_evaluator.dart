import '../progression/streak_calculator.dart';
import '../progression/xp_rules.dart';
import 'history_index.dart';
import 'pixel_badge.dart';

/// Works out which badges are unlocked and the day each one first was.
abstract final class BadgeEvaluator {
  static List<BadgeStatus> evaluate(HistoryIndex index, int today) {
    final perfect = _perfectRuns(index, today);
    final bestDay = _bestDay(index, today);
    final longest = StreakCalculator.longestStreak(index.activeDays);
    final total = index.records.length;
    final xp = index.records.fold<int>(0, (sum, r) => sum + r.xp);
    final level = XpRules.statsFromTotalXp(xp, streakDays: 0).currentLevel;

    BadgeStatus blocks(BadgeDefinition d, int goal) => _status(
      d,
      total >= goal ? index.records[goal - 1].epochDay : null,
      BadgeProgressKind.blocks,
      total,
      goal,
    );
    BadgeStatus streak(BadgeDefinition d, int goal) => _status(
      d,
      _streakUnlockDay(index.activeDays, goal),
      BadgeProgressKind.streakDays,
      longest,
      goal,
    );
    BadgeStatus levelBadge(BadgeDefinition d, int goal) => _status(
      d,
      _levelUnlockDay(index, goal),
      BadgeProgressKind.level,
      level,
      goal,
    );

    final statuses = [
      blocks(BadgeCatalog.firstBlock, 1),
      blocks(BadgeCatalog.brickLayer, 25),
      blocks(BadgeCatalog.brickMaster, 100),
      streak(BadgeCatalog.warrior, 7),
      streak(BadgeCatalog.lineClearer, 10),
      streak(BadgeCatalog.legend, 30),
      _status(
        BadgeCatalog.perfectDay,
        perfect.firstPerfectDay,
        bestDay == null
            ? BadgeProgressKind.noHabits
            : BadgeProgressKind.bestDay,
        bestDay?.done ?? 0,
        bestDay?.due ?? 0,
      ),
      _status(
        BadgeCatalog.perfectWeek,
        perfect.weekUnlockDay,
        BadgeProgressKind.perfectRun,
        perfect.bestRun,
        7,
      ),
      levelBadge(BadgeCatalog.level5, 5),
      levelBadge(BadgeCatalog.level10, 10),
    ];
    // Present in catalog order (easiest to hardest).
    final order = BadgeCatalog.all;
    return statuses..sort(
      (a, b) =>
          order.indexOf(a.definition).compareTo(order.indexOf(b.definition)),
    );
  }

  static BadgeStatus _status(
    BadgeDefinition d,
    int? day,
    BadgeProgressKind kind,
    int progress,
    int goal,
  ) => BadgeStatus(
    definition: d,
    unlockedDay: day,
    progressKind: kind,
    progress: progress,
    goal: goal,
  );

  /// Day the run of consecutive active days first reaches [goal].
  static int? _streakUnlockDay(Set<int> activeDays, int goal) {
    final sorted = activeDays.toList()..sort();
    for (final day in sorted) {
      if (activeDays.contains(day - 1)) continue;
      if (activeDays.contains(day + goal - 1) &&
          List.generate(goal, (i) => day + i).every(activeDays.contains)) {
        return day + goal - 1;
      }
    }
    return null;
  }

  /// Day lifetime XP first reached the amount needed for level [goal].
  static int? _levelUnlockDay(HistoryIndex index, int goal) {
    var needed = 0;
    for (var l = 1; l < goal; l++) {
      needed += XpRules.targetXpForLevel(l);
    }
    var xp = 0;
    for (final record in index.records) {
      xp += record.xp;
      if (xp >= needed) return record.epochDay;
    }
    return null;
  }

  /// Perfect-day facts. Days with nothing due neither extend nor break a
  /// run, and an unfinished today never breaks one.
  static ({int? firstPerfectDay, int? weekUnlockDay, int bestRun}) _perfectRuns(
    HistoryIndex index,
    int today,
  ) {
    final first = index.firstDay;
    int? firstPerfect;
    int? weekUnlock;
    var run = 0;
    var best = 0;
    if (first != null) {
      for (var day = first; day <= today; day++) {
        final tally = index.tally(day);
        if (tally.isPerfect) {
          firstPerfect ??= day;
          run++;
          if (run > best) best = run;
          if (run == 7) weekUnlock ??= day;
        } else if (tally.due > 0 && day != today) {
          run = 0;
        }
      }
    }
    return (
      firstPerfectDay: firstPerfect,
      weekUnlockDay: weekUnlock,
      bestRun: best,
    );
  }

  /// Day with the highest completed share, ties going to the busier day.
  static DayTally? _bestDay(HistoryIndex index, int today) {
    final first = index.firstDay;
    if (first == null) return null;
    DayTally? best;
    for (var day = first; day <= today; day++) {
      final t = index.tally(day);
      if (t.due == 0) continue;
      final better =
          best == null ||
          t.done * best.due > best.done * t.due ||
          (t.done * best.due == best.done * t.due && t.due > best.due);
      if (better) best = t;
    }
    return best;
  }
}
