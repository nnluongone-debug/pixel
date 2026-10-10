import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/habit_icons.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_providers.dart';
import '../habit_editor/habit_editor_sheet.dart';
import '../habits/widgets/habit_card_parts.dart';

/// Tasks tab: every habit with its cadence; tap to edit, trash to delete.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: Text(l10n.tasksDeleteTitle, style: AppTextStyles.headlineSm),
        content: Text(
          l10n.tasksDeleteBody(habit.name),
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.commonDelete,
              style: AppTextStyles.labelLg.copyWith(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    HapticFeedback.mediumImpact();
    try {
      await ref.read(habitsControllerProvider.notifier).delete(habit.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tasksDeleteFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsControllerProvider);
    final l10n = context.l10n;
    return habits.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.commonError('$e'))),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text(
            l10n.tasksHeader(list.length),
            style: AppTextStyles.labelMd.copyWith(color: AppColors.mint),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text(
                l10n.tasksEmpty,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm,
              ),
            ),
          for (final habit in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskRow(
                habit: habit,
                onEdit: () => HabitEditorSheet.show(context, habit: habit),
                onDelete: () => _confirmDelete(context, ref, habit),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    final l10n = context.l10n;
    final goal = switch (habit.type) {
      HabitType.counter =>
        '${habit.target} ${l10n.unitLabel(habit.unit)}'.trim(),
      HabitType.checklist => l10n.tasksGoalCheck,
      HabitType.timer => '${habit.target} ${l10n.unitMinutes}',
    };
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              HabitIconBox(icon: HabitIcons.of(habit.iconName), color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: AppTextStyles.headlineSm),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.cadenceLabel(habit.schedule)} • $goal',
                      style: AppTextStyles.labelMd.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.tasksDeleteTooltip,
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
