import '../../core/utils/date_key_utils.dart';

/// Outcome of replaying the check-in history with streak freezes.
class StreakFreezeState {
  const StreakFreezeState({
    required this.streak,
    required this.best,
    required this.held,
    required this.frozenDays,
  });

  static const empty = StreakFreezeState(
    streak: 0,
    best: 0,
    held: 0,
    frozenDays: {},
  );

  /// Current global streak (frozen days keep it alive but do not add to it).
  final int streak;

  /// Longest streak ever; never below [streak].
  final int best;

  /// Freezes available right now.
  final int held;

  /// Epoch days on which a freeze kept the current streak alive. Freezes
  /// spent on a gap that later broke the streak are not listed.
  final Set<int> frozenDays;
}

/// Earn / hold rules of the streak freeze. Freezes are a pure projection of
/// the history, so nothing is stored and every device agrees.
abstract final class StreakFreezeRules {
  /// +1 freeze each time the running streak reaches a multiple of this.
  static const int earnEvery = 7;

  /// Freezes that can be held at once.
  static const int maxHeld = 2;

  /// First epoch day (2026-11-26, v1.2.0) on which freezes are earned and
  /// used. Earlier history replays without freezes so existing streaks do
  /// not change on update.
  static final int releaseDay = DateKeys.epochDay(DateTime(2026, 11, 26));
}

abstract final class StreakFreeze {
  /// Replays [activeDays] forward to [today].
  ///
  /// A due day with no activity (never today, which has grace) spends a
  /// freeze when the streak is alive and one is held; otherwise it resets
  /// the streak. Days before [startDay] never earn or spend freezes, so with
  /// `startDay > today` this equals `StreakCalculator.scheduledStreak` and
  /// `longestScheduledStreak`. Active days on off days still count.
  ///
  /// Freezes spent on a gap are held as pending and only reported in
  /// `frozenDays` once the streak survives it (next active day, or the end of
  /// the replay with a live streak). If the gap exhausts the freezes and the
  /// streak resets, the pending days are discarded; the spent freezes stay
  /// spent (nothing is refunded).
  static StreakFreezeState simulate(
    Set<int> activeDays,
    int today,
    bool Function(int epochDay) isDue, {
    int? startDay,
  }) {
    if (activeDays.isEmpty) return StreakFreezeState.empty;
    final start = startDay ?? StreakFreezeRules.releaseDay;
    var day = activeDays.reduce((a, b) => a < b ? a : b);

    var run = 0;
    var best = 0;
    var held = 0;
    final frozen = <int>{};
    final pending = <int>{};
    for (; day <= today; day++) {
      if (activeDays.contains(day)) {
        frozen.addAll(pending);
        pending.clear();
        run++;
        if (run > best) best = run;
        if (day >= start && run % StreakFreezeRules.earnEvery == 0) {
          held = held < StreakFreezeRules.maxHeld ? held + 1 : held;
        }
      } else if (day != today && isDue(day)) {
        if (run > 0 && held > 0 && day >= start) {
          held--;
          pending.add(day);
        } else {
          run = 0;
          pending.clear();
        }
      }
    }
    if (run > 0) frozen.addAll(pending);
    return StreakFreezeState(
      streak: run,
      best: best,
      held: held,
      frozenDays: frozen,
    );
  }
}
