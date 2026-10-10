import '../../../core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/analytics_summary.dart';
import '../../../providers/analytics_providers.dart';
import '../stats_formatters.dart';
import 'rate_ring_gauge.dart';
import 'stat_tile.dart';

/// CURR STREAK / BEST STREAK / RATE / BLOCKS.
class StatTiles extends ConsumerWidget {
  const StatTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(analyticsSummaryProvider);
    if (summary == null) return const SizedBox.shrink();
    final range = ref.watch(analyticsRangeProvider);
    final delta = summary.rateDelta;
    final ratio = summary.rate.ratio;

    return Column(
      children: [
        _row(
          StatTile(
            label: l10n.statsTileCurrentStreak,
            value: '${summary.currentStreak}',
            unit: l10n.statsUnitDays,
            caption: l10n.statsCaptionStreakAlive,
            accent: AppColors.mint,
            topRight: const Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: AppColors.rose,
            ),
          ),
          StatTile(
            label: l10n.statsTileBestStreak,
            value: '${summary.bestStreak}',
            unit: l10n.statsUnitDays,
            caption: l10n.statsCaptionRecord,
            accent: AppColors.amber,
            topRight: const Icon(
              Icons.emoji_events_rounded,
              size: 18,
              color: AppColors.amber,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _row(
          StatTile(
            label: l10n.statsTileRate,
            value: StatsFormat.percent(summary.rate.percent),
            caption: _rateCaption(l10n, summary, l10n.rangeCaption(range)),
            accent: AppColors.textPrimary,
            topRight: delta == null
                ? null
                : StatChip(
                    l10n.delta(delta),
                    color: delta >= 0 ? AppColors.mint : AppColors.rose,
                  ),
            valueTrailing: RateRingGauge(ratio: ratio ?? 0),
          ),
          StatTile(
            label: l10n.statsTileBlocks,
            value: '${summary.blocks}',
            unit: l10n.statsUnitStack,
            caption: l10n.statsCaptionPerfectClears(summary.perfectClears),
            accent: AppColors.textPrimary,
            topRight: const Icon(
              Icons.view_module_rounded,
              size: 18,
              color: AppColors.lavender,
            ),
          ),
        ),
      ],
    );
  }

  static String _rateCaption(
    AppLocalizations l10n,
    AnalyticsSummary s,
    String rangeCaption,
  ) => s.rate.due == 0
      ? l10n.statsCaptionNothingDue(rangeCaption)
      : l10n.statsCaptionHabitDays(s.rate.done, s.rate.due);

  static Widget _row(Widget left, Widget right) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    ),
  );
}
