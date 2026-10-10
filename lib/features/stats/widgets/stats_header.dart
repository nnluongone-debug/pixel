import '../../../core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/analytics_range.dart';
import '../../../providers/analytics_providers.dart';
import '../stats_formatters.dart';

/// Title, version tag, range chips and the sync line.
class StatsHeader extends ConsumerWidget {
  const StatsHeader({super.key, required this.loadedAt});

  final DateTime loadedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(analyticsRangeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                context.l10n.statsTitle,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.mint),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NEO_MATRIX.V4',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final r in AnalyticsRange.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: r == AnalyticsRange.allTime ? 0 : 8,
                  ),
                  child: _RangeChip(
                    range: r,
                    selected: r == range,
                    onTap: () =>
                        ref.read(analyticsRangeProvider.notifier).select(r),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.syncLine(loadedAt),
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            ),
            Text(
              context.l10n.rangeCaption(range),
              style: AppTextStyles.labelSm.copyWith(color: AppColors.cyan),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.range,
    required this.selected,
    required this.onTap,
  });

  final AnalyticsRange range;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.mint : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.mint : AppColors.borderActive,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.l10n.rangeChip(range),
              style: AppTextStyles.labelMd.copyWith(
                color: selected ? AppColors.textOnNeon : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
