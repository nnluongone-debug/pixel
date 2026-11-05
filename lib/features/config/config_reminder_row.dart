import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import '../habit_editor/alerts_section.dart';
import '../habit_editor/habit_editor_sheet.dart';
import '../habit_editor/reminder_repeat_panel.dart';

/// One habit's reminder schedule inside the notifications card; tap edits.
class ConfigReminderRow extends StatelessWidget {
  const ConfigReminderRow({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => HabitEditorSheet.show(context, habit: habit),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputInset,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: AppGlow.soft(color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: AppTextStyles.bodyLg,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.l10n.cadenceLabel(habit.schedule),
                    style: AppTextStyles.labelSm,
                  ),
                ],
              ),
            ),
            _ReminderTimes(habit: habit),
          ],
        ),
      ),
    );
  }
}

/// Right side of a row: "every 1h · 08:00–22:00" or the fixed times.
class _ReminderTimes extends StatelessWidget {
  const _ReminderTimes({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelLg.copyWith(color: AppColors.cyan);
    final every = habit.reminderEvery;
    if (every != null) {
      final l10n = context.l10n;
      return Text(
        l10n.configEveryRow(
          reminderEveryLabel(l10n, every),
          formatReminderTime(context, habit.reminderFrom),
          formatReminderTime(context, habit.reminderTo),
        ),
        style: AppTextStyles.labelMd.copyWith(color: AppColors.cyan),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final time in habit.reminderTimes)
          Text(formatReminderTime(context, time), style: style),
      ],
    );
  }
}
