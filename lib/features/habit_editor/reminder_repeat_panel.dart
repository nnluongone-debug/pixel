import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import 'alerts_section.dart';
import 'editor_parts.dart';
import 'habit_draft.dart';

/// "15m", "1h", "1.5h": label of an every-N-minutes choice.
String reminderEveryLabel(AppLocalizations l10n, int minutes) {
  if (minutes < 60) return l10n.editorEveryMinutes(minutes);
  final hours = minutes / 60;
  return '${hours == hours.roundToDouble() ? hours.round() : hours}h';
}

/// Shows a themed time picker; returns minutes after midnight or null.
Future<int?> pickReminderTime(
  BuildContext context,
  int initial,
  Color color,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: color,
          onPrimary: AppColors.textOnNeon,
          surface: AppColors.surfaceRaised,
        ),
      ),
      child: child!,
    ),
  );
  return picked == null ? null : picked.hour * 60 + picked.minute;
}

/// Repeat mode: EVERY chips, FROM / TO buttons and a live prompt count.
class ReminderRepeatPanel extends StatelessWidget {
  const ReminderRepeatPanel({
    super.key,
    required this.draft,
    required this.color,
    required this.onChanged,
  });

  final HabitDraft draft;
  final Color color;
  final ValueChanged<HabitDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slots = draft.windowValid ? draft.repeatSlots : const <int>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.editorEvery, style: AppTextStyles.labelSm),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final every in Habit.reminderEveryChoices) ...[
              if (every != Habit.reminderEveryChoices.first)
                const SizedBox(width: 4),
              Expanded(
                child: EditorChip(
                  label: reminderEveryLabel(l10n, every),
                  color: color,
                  horizontalPadding: 2,
                  selected: draft.reminderEvery == every,
                  onTap: () => onChanged(draft.copyWith(reminderEvery: every)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TimeButton(
                label: l10n.editorFrom,
                minutes: draft.reminderFrom,
                invalid: !draft.windowValid,
                onTap: () async {
                  final m = await pickReminderTime(
                    context,
                    draft.reminderFrom,
                    color,
                  );
                  if (m != null) onChanged(draft.copyWith(reminderFrom: m));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeButton(
                label: l10n.editorTo,
                minutes: draft.reminderTo,
                invalid: !draft.windowValid,
                onTap: () async {
                  final m = await pickReminderTime(
                    context,
                    draft.reminderTo,
                    color,
                  );
                  if (m != null) onChanged(draft.copyWith(reminderTo: m));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          slots.isEmpty
              ? l10n.editorErrWindow
              : l10n.editorRepeatSummary(
                  slots.length,
                  formatReminderTime(context, slots.first),
                  formatReminderTime(context, slots.last),
                ),
          style: AppTextStyles.labelSm.copyWith(
            color: slots.isEmpty ? AppColors.error : AppColors.cyan,
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.minutes,
    required this.invalid,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final bool invalid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = invalid ? AppColors.error : AppColors.cyan;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.labelSm),
            const Spacer(),
            Text(
              formatReminderTime(context, minutes),
              style: AppTextStyles.labelMd.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
