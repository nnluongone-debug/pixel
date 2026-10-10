import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/domain/progression/streak_calculator.dart';
import 'package:pixel_quest/domain/progression/xp_rules.dart';

void main() {
  group('XpRules', () {
    test('check-in XP grows with prior streak and is capped', () {
      expect(XpRules.xpForCheckIn(priorStreakDays: 0), 25);
      expect(XpRules.xpForCheckIn(priorStreakDays: 3), 40);
      expect(XpRules.xpForCheckIn(priorStreakDays: 100), 75);
    });

    test('level is derived from lifetime XP with carry-over', () {
      final l1 = XpRules.statsFromTotalXp(99, streakDays: 0);
      expect((l1.currentLevel, l1.currentXp, l1.targetXp), (1, 99, 100));

      // 100 (L1) + 150 (L2) = 250 -> exactly level 3.
      final l3 = XpRules.statsFromTotalXp(260, streakDays: 2);
      expect((l3.currentLevel, l3.currentXp, l3.targetXp), (3, 10, 200));
      expect(l3.streakDays, 2);
    });
  });

  group('StreakCalculator', () {
    const today = 20000;

    test('current streak counts back from today', () {
      expect(StreakCalculator.currentStreak({20000, 19999, 19998}, today), 3);
    });

    test('streak survives until midnight if only yesterday is done', () {
      expect(StreakCalculator.currentStreak({19999, 19998}, today), 2);
      expect(StreakCalculator.currentStreak({19997}, today), 0);
    });

    test('longest streak finds the best run', () {
      expect(StreakCalculator.longestStreak({1, 2, 3, 7, 8, 10}), 3);
      expect(StreakCalculator.longestStreak({}), 0);
    });
  });

  group('DateKeys', () {
    test('round-trips and shifts across month boundaries', () {
      expect(DateKeys.fromDate(DateTime(2026, 3, 9)), '2026-03-09');
      expect(DateKeys.shift('2026-03-01', -1), '2026-02-28');
      expect(
        DateKeys.epochDayOfKey('2026-03-30') -
            DateKeys.epochDayOfKey('2026-03-28'),
        2,
      );
    });
  });
}
