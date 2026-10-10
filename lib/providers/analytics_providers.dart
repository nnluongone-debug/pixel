import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_key_utils.dart';
import '../data/models/user_stats.dart';
import '../data/repositories/analytics_repository.dart';
import '../domain/analytics/analytics_range.dart';
import '../domain/analytics/analytics_summary.dart';
import '../domain/analytics/badge_evaluator.dart';
import '../domain/analytics/habit_consistency.dart';
import '../domain/analytics/history_index.dart';
import '../domain/analytics/month_heatmap.dart';
import '../domain/analytics/pixel_badge.dart';
import 'habit_providers.dart';
import 'repository_providers.dart';

/// "Now" for analytics; override in tests.
final analyticsClockProvider = Provider<Clock>((ref) => DateTime.now);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepository(ref.watch(databaseProvider)),
);

/// History snapshot every analytics figure is derived from.
class AnalyticsData {
  const AnalyticsData({
    required this.index,
    required this.stats,
    required this.today,
    required this.loadedAt,
  });

  final HistoryIndex index;
  final UserStats stats;

  /// Epoch day of [loadedAt].
  final int today;
  final DateTime loadedAt;
}

/// Reloads after every habit mutation because it awaits the habits and
/// stats providers, which the habits controller invalidates.
final analyticsDataProvider = FutureProvider<AnalyticsData>((ref) async {
  final habits = await ref.watch(habitsControllerProvider.future);
  final stats = await ref.watch(userStatsProvider.future);
  final records = await ref
      .watch(analyticsRepositoryProvider)
      .getCheckInRecords();
  final now = ref.read(analyticsClockProvider)();
  return AnalyticsData(
    index: HistoryIndex(habits: habits, records: records),
    stats: stats,
    today: DateKeys.epochDay(now),
    loadedAt: now,
  );
});

class AnalyticsRangeNotifier extends Notifier<AnalyticsRange> {
  @override
  AnalyticsRange build() => AnalyticsRange.month;

  void select(AnalyticsRange range) => state = range;
}

final analyticsRangeProvider =
    NotifierProvider<AnalyticsRangeNotifier, AnalyticsRange>(
      AnalyticsRangeNotifier.new,
    );

/// First day of the month shown in the activity matrix.
class HeatmapMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    // Re-centres on the current month once the day rolls over.
    ref.watch(currentDayProvider);
    final now = ref.read(analyticsClockProvider)();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final heatmapMonthProvider = NotifierProvider<HeatmapMonthNotifier, DateTime>(
  HeatmapMonthNotifier.new,
);

// Derived values are null until the first load finishes. They keep the
// previous snapshot while reloading, so the screen never flashes.

final analyticsSummaryProvider = Provider<AnalyticsSummary?>((ref) {
  final data = ref.watch(analyticsDataProvider).value;
  if (data == null) return null;
  return AnalyticsSummary.compute(
    index: data.index,
    range: ref.watch(analyticsRangeProvider),
    today: data.today,
    stats: data.stats,
  );
});

final monthHeatmapProvider = Provider<MonthHeatmap?>((ref) {
  final data = ref.watch(analyticsDataProvider).value;
  if (data == null) return null;
  final month = ref.watch(heatmapMonthProvider);
  return MonthHeatmap.build(
    index: data.index,
    year: month.year,
    month: month.month,
    today: data.today,
  );
});

final habitConsistencyProvider = Provider<List<HabitConsistency>?>((ref) {
  final data = ref.watch(analyticsDataProvider).value;
  if (data == null) return null;
  final range = ref.watch(analyticsRangeProvider);
  return HabitConsistency.compute(
    index: data.index,
    window: range.window(data.today, data.index.firstDay),
    today: data.today,
  );
});

final badgesProvider = Provider<List<BadgeStatus>?>((ref) {
  final data = ref.watch(analyticsDataProvider).value;
  if (data == null) return null;
  return BadgeEvaluator.evaluate(data.index, data.today);
});
