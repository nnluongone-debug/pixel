import '../../../core/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/habit_icons.dart';
import '../../../domain/analytics/habit_consistency.dart';
import '../stats_formatters.dart';
import 'segmented_bar.dart';

/// One habit of the consistency breakdown.
class HabitBreakdownCard extends StatelessWidget {
  const HabitBreakdownCard({super.key, required this.consistency});

  final HabitConsistency consistency;

  @override
  Widget build(BuildContext context) {
    final c = consistency;
    final color = AppColors.fromHex(c.habit.colorHex);
    final small = AppTextStyles.labelMd.copyWith(color: AppColors.textMuted);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(HabitIcons.of(c.habit.iconName), size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSm.copyWith(fontSize: 18),
                ),
              ),
              Text(context.l10n.habitStat(c), style: small),
              const SizedBox(width: 8),
              Text(
                '${c.percent}%',
                style: AppTextStyles.labelLg.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedBar(ratio: c.ratio, color: color),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.l10n.statsDaysTargetMet(c.metDays, c.dueDays),
                  overflow: TextOverflow.ellipsis,
                  style: small,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.statsStreak(c.streak),
                style: AppTextStyles.labelMd.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
