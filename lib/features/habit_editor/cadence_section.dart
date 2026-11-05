import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import 'editor_parts.dart';
import 'habit_draft.dart';

/// Section 03: cadence, daily quota stepper and unit chips.
class CadenceSection extends StatelessWidget {
  const CadenceSection({
    super.key,
    required this.draft,
    required this.color,
    required this.onChanged,
  });

  static const maxTarget = 999;

  final HabitDraft draft;
  final Color color;
  final ValueChanged<HabitDraft> onChanged;

  void _toggleDay(int weekday) {
    final days = {...draft.customDays};
    if (!days.remove(weekday)) days.add(weekday);
    onChanged(draft.copyWith(customDays: days));
  }

  static String cadenceName(AppLocalizations l10n, HabitCadence cadence) =>
      switch (cadence) {
        HabitCadence.daily => l10n.cadenceDaily,
        HabitCadence.weekdays => l10n.cadenceWeekdays,
        HabitCadence.custom => l10n.cadenceCustom,
      };

  String _quotaUnit(AppLocalizations l10n) => switch (draft.type) {
    HabitType.timer => l10n.unitMinutes,
    _ => l10n.unitLabel(draft.unit),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: l10n.editorCadenceTag,
          title: l10n.editorCadenceTitle,
          trailing: l10n.editorLoop(cadenceName(l10n, draft.cadence)),
          trailingColor: color,
        ),
        const SizedBox(height: 10),
        _CadenceSwitch(
          selected: draft.cadence,
          color: color,
          onChanged: (c) => onChanged(draft.copyWith(cadence: c)),
        ),
        if (draft.cadence == HabitCadence.custom) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                _DayToggle(
                  letter: l10n.weekdayShort(d),
                  selected: draft.customDays.contains(d),
                  color: color,
                  onTap: () => _toggleDay(d),
                ),
            ],
          ),
        ],
        if (draft.hasQuota) ...[
          const SizedBox(height: 10),
          EditorPanel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.editorDailyQuota, style: AppTextStyles.labelSm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${draft.target}',
                            style: AppTextStyles.headlineXl,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _quotaUnit(l10n),
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StepperButton(
                  icon: Icons.remove,
                  tooltip: l10n.editorQuotaDecrease,
                  color: color,
                  onPressed: draft.target > draft.step
                      ? () => onChanged(
                          draft.copyWith(target: draft.target - draft.step),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                StepperButton(
                  icon: Icons.add,
                  tooltip: l10n.editorQuotaIncrease,
                  color: color,
                  onPressed: draft.target + draft.step <= maxTarget
                      ? () => onChanged(
                          draft.copyWith(target: draft.target + draft.step),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        // One compact row: chips share the width and shrink their text.
        Row(
          children: [
            for (final option in HabitUnitOption.all) ...[
              if (option != HabitUnitOption.all.first) const SizedBox(width: 6),
              Expanded(
                child: EditorChip(
                  label: option.labelOf(l10n),
                  color: color,
                  horizontalPadding: 4,
                  selected: draft.isSelected(option),
                  onTap: () => onChanged(draft.withUnit(option)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CadenceSwitch extends StatelessWidget {
  const _CadenceSwitch({
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final HabitCadence selected;
  final Color color;
  final ValueChanged<HabitCadence> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.inputInset,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (final cadence in HabitCadence.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: cadence == selected,
                child: GestureDetector(
                  onTap: () => onChanged(cadence),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cadence == selected
                          ? color.withValues(alpha: 0.14)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      border: cadence == selected
                          ? Border.all(color: color.withValues(alpha: 0.6))
                          : null,
                    ),
                    child: Text(
                      CadenceSection.cadenceName(context.l10n, cadence),
                      style: AppTextStyles.labelMd.copyWith(
                        color: cadence == selected
                            ? color
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.letter,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? color.withValues(alpha: 0.14) : null,
          border: Border.all(color: selected ? color : AppColors.borderActive),
        ),
        child: Text(
          letter,
          style: AppTextStyles.labelMd.copyWith(
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
