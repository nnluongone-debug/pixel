import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/domain/progression/streak_calculator.dart';
import 'package:pixel_quest/domain/progression/streak_freeze.dart';

bool _always(int _) => true;

/// Days [from]..[to] inclusive.
Set<int> _range(int from, int to) => {for (var d = from; d <= to; d++) d};

void main() {
  const start = 0; // freezes active for every test day
  StreakFreezeState sim(Set<int> days, int today, [bool Function(int)? due]) =>
      StreakFreeze.simulate(days, today, due ?? _always, startDay: start);

  test('7 active days, one miss, then active keeps the streak', () {
    final days = {..._range(1, 7), 9}; // day 8 missed
    final s = sim(days, 9);
    expect(s.streak, 8);
    expect(s.held, 0);
    expect(s.frozenDays, {8});
  });

  test('6 active days then a miss resets (no freeze earned yet)', () {
    final s = sim({..._range(1, 6), 8}, 8);
    expect(s.streak, 1);
    expect(s.frozenDays, isEmpty);
    expect(sim(_range(1, 6), 8).streak, 0);
  });

  test('two held freezes bridge two missed days, three break it', () {
    final base = _range(1, 14);
    final two = sim({...base, 17}, 17); // 15, 16 missed
    expect(two.streak, 15);
    expect(two.held, 0);
    expect(two.frozenDays, {15, 16});

    final three = sim(base, 17); // 15, 16, 17 missed; 17 is today (grace)
    expect(three.streak, 14);
    final broken = sim({...base, 19}, 19); // 15, 16, 17, 18 missed
    expect(broken.streak, 1);
    expect(broken.held, 0);
    // The streak reset, so the freezes spent on 15, 16 are not shown.
    expect(broken.frozenDays, isEmpty);
  });

  test('held=1, two missed due days: reset, no frozen days reported', () {
    final days = {..._range(1, 7), 10}; // 8, 9 missed
    final s = sim(days, 10);
    expect(s.streak, 1);
    expect(s.held, 0); // the spent freeze is not refunded
    expect(s.frozenDays, isEmpty);
    // Same gap still open at today: today has grace, streak alive, day 8 frozen.
    final open = sim(_range(1, 7), 9);
    expect(open.streak, 7);
    expect(open.frozenDays, {8});
  });

  test('a long gap with no freezes held resets, inventory carries over', () {
    final s = sim({..._range(1, 7), 12, ..._range(13, 18)}, 18);
    // 8..11 missed: freezes 1 then break. 12..18 active again = 7 days.
    expect(s.streak, 7);
    expect(s.held, 1);
  });

  test('off days and today never spend a freeze', () {
    bool due(int d) => d % 2 == 0; // odd days off
    final days = _range(1, 14).where((d) => d % 2 == 0).toSet();
    final s = sim(days, 15, due);
    expect(s.frozenDays, isEmpty);
    // Today due but not done yet: grace, no freeze spent.
    final t = sim(_range(1, 14), 15);
    expect(t.frozenDays, isEmpty);
    expect(t.held, 2);
    expect(t.streak, 14);
  });

  test('held caps at 2', () {
    expect(sim(_range(1, 30), 30).held, 2);
    expect(sim(_range(1, 21), 21).held, 2);
  });

  test('before startDay misses reset without freezes', () {
    final days = {..._range(1, 7), 9};
    final s = StreakFreeze.simulate(days, 9, _always, startDay: 100);
    expect(s.streak, 1);
    expect(s.held, 0);
    expect(s.frozenDays, isEmpty);
  });

  test('best never drops below the current streak', () {
    final rng = Random(7);
    for (var i = 0; i < 200; i++) {
      final days = {
        for (var d = 0; d < 60; d++)
          if (rng.nextInt(10) < 8) d,
      };
      final s = sim(days, 59, (d) => d % 7 != 6);
      expect(s.best, greaterThanOrEqualTo(s.streak));
    }
  });

  test('backfilling a frozen day makes it real and returns the freeze', () {
    final before = sim({..._range(1, 7), 9}, 9);
    expect(before.frozenDays, {8});
    expect(before.streak, 8);
    final after = sim({..._range(1, 9)}, 9);
    expect(after.frozenDays, isEmpty);
    expect(after.streak, 9);
    expect(after.held, 1);
  });

  test('freezes off equals StreakCalculator on random histories', () {
    final rng = Random(42);
    for (var i = 0; i < 200; i++) {
      final today = 100;
      final dueMask = rng.nextInt(127) + 1;
      bool due(int d) => dueMask & (1 << (d % 7)) != 0;
      final density = 3 + rng.nextInt(7);
      final days = {
        for (var d = 40; d <= today; d++)
          if (rng.nextInt(10) < density) d,
      };
      final s = StreakFreeze.simulate(days, today, due, startDay: today + 1);
      expect(
        s.streak,
        StreakCalculator.scheduledStreak(days, today, due),
        reason: 'streak case $i',
      );
      expect(
        s.best,
        StreakCalculator.longestScheduledStreak(days, due),
        reason: 'best case $i',
      );
      expect(s.frozenDays, isEmpty);
      expect(s.held, 0);
    }
  });
}
