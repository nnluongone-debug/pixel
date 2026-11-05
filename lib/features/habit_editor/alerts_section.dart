import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import 'editor_parts.dart';
import 'habit_draft.dart';
import 'reminder_repeat_panel.dart';

/// Formats minutes after midnight per the locale and 12/24-hour setting.
String formatReminderTime(BuildContext context, int minutes) =>
    MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));

/// Section 04: reminder switch with two modes: specific times (up to
/// [Habit.maxReminderTimes]) or "repeat every N minutes" in a window.
class AlertsSection extends StatelessWidget {
  const AlertsSection({
    super.key,
    required this.draft,
    required this.color,
    required this.onChanged,
  });

  /// Time offered when the switch is first turned on.
  static const defaultMinutes = 20 * 60 + 30;

  final HabitDraft draft;
  final Color color;
  final ValueChanged<HabitDraft> onChanged;

  /// Sorted, de-duplicated copy of [times].
  static List<int> normalize(Iterable<int> times) =>
      (times.toSet().toList()..sort());

  void _setTimes(List<int> times) {
    // Removing the last time turns reminders off.
    onChanged(
      draft.copyWith(reminderTimes: times, remindersOn: times.isNotEmpty),
    );
  }

  Future<void> _add(BuildContext context) async {
    final minutes = await pickReminderTime(context, defaultMinutes, color);
    if (minutes != null) {
      _setTimes(normalize([...draft.reminderTimes, minutes]));
    }
  }

  Future<void> _edit(BuildContext context, int old) async {
    final minutes = await pickReminderTime(context, old, color);
    if (minutes == null) return;
    _setTimes(
      normalize([
        for (final t in draft.reminderTimes)
          if (t != old) t,
        minutes,
      ]),
    );
  }

  void _toggle(bool on) {
    onChanged(
      draft.copyWith(
        remindersOn: on,
        // Specific mode needs at least one time to be "on".
        reminderTimes: on && !draft.repeatMode && draft.reminderTimes.isEmpty
            ? const [defaultMinutes]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = draft.remindersOn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: l10n.editorAlertsTag,
          title: l10n.editorNotifications,
          trailing: enabled ? 'PUSH_ARMED' : 'PUSH_OFF',
          trailingColor: enabled ? color : AppColors.textMuted,
        ),
        const SizedBox(height: 10),
        EditorPanel(
          accent: enabled ? color : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    enabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: enabled ? color : AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.editorDailyPrompt,
                          style: AppTextStyles.headlineSm,
                        ),
                        Text(
                          enabled ? l10n.editorPromptOn : l10n.editorNoReminder,
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    activeThumbColor: AppColors.textOnNeon,
                    activeTrackColor: color,
                    inactiveTrackColor: AppColors.surfaceHigh,
                    onChanged: _toggle,
                  ),
                ],
              ),
              if (enabled) ...[
                const SizedBox(height: 10),
                EditorSegmented<bool>(
                  color: color,
                  selected: draft.repeatMode,
                  options: {
                    false: l10n.editorModeTimes,
                    true: l10n.editorModeRepeat,
                  },
                  onChanged: (repeat) =>
                      onChanged(draft.copyWith(repeatMode: repeat)),
                ),
                const SizedBox(height: 10),
                if (draft.repeatMode)
                  ReminderRepeatPanel(
                    draft: draft,
                    color: color,
                    onChanged: onChanged,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final time in draft.reminderTimes)
                        _TimeChip(
                          label: formatReminderTime(context, time),
                          removeLabel: l10n.editorRemoveTime(
                            formatReminderTime(context, time),
                          ),
                          onTap: () => _edit(context, time),
                          onRemove: () => _setTimes([
                            for (final t in draft.reminderTimes)
                              if (t != time) t,
                          ]),
                        ),
                      if (draft.reminderTimes.length < Habit.maxReminderTimes)
                        EditorChip(
                          label: l10n.editorAddTime,
                          selected: false,
                          color: color,
                          onTap: () => _add(context),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Cyan time pill: tap to change the time, ✕ to remove it.
class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.removeLabel,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final String removeLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cyan),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: Text(
                label,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.cyan),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: removeLabel,
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 10, 8),
                child: Icon(Icons.close, size: 16, color: AppColors.cyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
