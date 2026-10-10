import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/l10n_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/month_heatmap.dart';
import '../../../providers/analytics_providers.dart';
import '../stats_formatters.dart';
import 'stat_tile.dart';

/// Mint scale for heatmap levels 0 (nothing) to 4 (every due habit done).
const List<Color> heatLevelColors = [
  AppColors.cellEmpty,
  Color(0xFF1B5A41),
  Color(0xFF1F9463),
  AppColors.mint,
  AppColors.primary,
];

/// Month calendar colored by completed share of due habits.
class ActivityMatrixCard extends ConsumerWidget {
  const ActivityMatrixCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmap = ref.watch(monthHeatmapProvider);
    final data = ref.watch(analyticsDataProvider).value;
    if (heatmap == null || data == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final notifier = ref.read(heatmapMonthProvider.notifier);
    final month = DateTime(heatmap.year, heatmap.month);
    final current = DateTime(data.loadedAt.year, data.loadedAt.month);
    final efficiency = heatmap.rate.percent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statsHeatmapTitle(
                    l10n.monthYear(month, context.localeTag),
                  ),
                  maxLines: 2,
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.mint),
                ),
              ),
              if (efficiency != null)
                StatChip(
                  l10n.statsHeatmapEfficiency(efficiency),
                  color: AppColors.mint,
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                label: l10n.statsPrevMonth,
                onTap: () => notifier.shift(-1),
              ),
              _NavButton(
                icon: Icons.chevron_right,
                label: l10n.statsNextMonth,
                onTap: month.isBefore(current) ? () => notifier.shift(1) : null,
              ),
            ],
          ),
          Row(
            children: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.weekdayShort(d),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < heatmap.cells.length; i += 7)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  for (var j = i; j < i + 7; j++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: j == i + 6 ? 0 : 6),
                        child: HeatCellView(cell: heatmap.cells[j]),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Legend(),
              Text(
                l10n.statsPerfectClear(heatmap.perfectDays),
                style: AppTextStyles.labelSm.copyWith(color: AppColors.mint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeatCellView extends StatelessWidget {
  const HeatCellView({super.key, required this.cell});

  final HeatCell cell;

  @override
  Widget build(BuildContext context) {
    final level = cell.level;
    final color = heatLevelColors[level];
    final lit = level >= 3 && cell.inMonth;
    final l10n = context.l10n;
    final date = StatsFormat.monthDay(cell.date, context.localeTag);
    final label = cell.tally.due == 0
        ? l10n.statsCellNoneDue(date)
        : l10n.statsCellDone(date, cell.tally.done, cell.tally.due);
    return Semantics(
      label: label,
      child: Opacity(
        opacity: cell.inMonth ? 1 : 0.3,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: cell.isToday
                    ? AppColors.textPrimary
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: lit ? AppGlow.cell(color) : null,
            ),
            child: Text(
              '${cell.date.day}'.padLeft(2, '0'),
              style: AppTextStyles.labelSm.copyWith(
                color: level >= 3
                    ? AppColors.textOnNeon
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      color: AppColors.textSecondary,
      disabledColor: AppColors.outlineVariant,
      icon: Icon(icon),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.l10n.statsLegendLess,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: 6),
        for (final color in heatLevelColors)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Text(
          context.l10n.statsLegendMore,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
