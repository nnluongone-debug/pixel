import '../../data/models/user_stats.dart';
import '../progression/streak_calculator.dart';
import 'analytics_range.dart';
import 'history_index.dart';

/// Figures behind the four tiles at the top of the analytics screen.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.rate,
    required this.rateDelta,
    required this.blocks,
    required this.perfectClears,
  });

  /// Global streak (any check-in keeps it alive), as shown on the Matrix tab.
  final int currentStreak;

  /// Longest global streak ever.
  final int bestStreak;

  /// Completed vs due habit-days inside the range.
  final DayTally rate;

  /// Rate change in percentage points versus the previous equally long
  /// window; null for All Time or when nothing was due back then.
  final double? rateDelta;

  /// Check-ins inside the range.
  final int blocks;

  /// Days inside the range where every due habit was completed.
  final int perfectClears;

  factory AnalyticsSummary.compute({
    required HistoryIndex index,
    required AnalyticsRange range,
    required int today,
    required UserStats stats,
  }) {
    final window = range.window(today, index.firstDay);
    final rate = index.tallyRange(window.start, window.end);

    double? delta;
    final previous = range.previousWindow(today);
    final currentRatio = rate.ratio;
    if (previous != null && currentRatio != null) {
      final before = index.tallyRange(previous.start, previous.end).ratio;
      if (before != null) delta = (currentRatio - before) * 100;
    }

    return AnalyticsSummary(
      currentStreak: stats.streakDays,
      bestStreak: StreakCalculator.longestStreak(index.activeDays),
      rate: rate,
      rateDelta: delta,
      blocks: index.blocksIn(window.start, window.end),
      perfectClears: index.perfectDays(window.start, window.end),
    );
  }
}
