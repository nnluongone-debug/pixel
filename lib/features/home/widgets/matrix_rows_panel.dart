import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/habit.dart';
import '../../../domain/progression/xp_rules.dart';
import '../../../providers/habit_providers.dart';

/// Telemetry under the grid: cleared rows with their XP bonus, plus a
/// color legend of the active habits.
class MatrixRowsPanel extends ConsumerWidget {
  const MatrixRowsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(completedRowsProvider).value ?? 0;
    final habits = ref.watch(habitsControllerProvider).value ?? const <Habit>[];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  context.l10n.gridRowsCompleted(rows),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                context.l10n.gridRowsMultiplier(XpRules.rowBonus(rows)),
                style: AppTextStyles.labelSm.copyWith(color: AppColors.cyan),
              ),
            ],
          ),
          if (habits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [for (final habit in habits) _LegendItem(habit: habit)],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: AppGlow.soft(color),
          ),
        ),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            habit.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
