import '../../../core/l10n/l10n.dart';
import '../stats_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/analytics_providers.dart';
import 'habit_breakdown_card.dart';

/// HABIT CONSISTENCY BREAKDOWN for the selected range.
class HabitBreakdownSection extends ConsumerWidget {
  const HabitBreakdownSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(habitConsistencyProvider);
    final range = ref.watch(analyticsRangeProvider);
    if (rows == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.l10n.statsBreakdownTitle,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.mint),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.rangeWindow(range),
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          Text(
            context.l10n.statsBreakdownEmpty,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          ),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitBreakdownCard(consistency: row),
          ),
      ],
    );
  }
}
