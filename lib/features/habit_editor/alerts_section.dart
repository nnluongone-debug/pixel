import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import 'editor_parts.dart';

/// Formats minutes after midnight per the locale and 12/24-hour setting.
String formatReminderTime(BuildContext context, int minutes) =>
    MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));

/// Section 04: daily prompt toggle and time picker. Off = null reminder.
class AlertsSection extends StatelessWidget {
  const AlertsSection({
    super.key,
    required this.reminderMinutes,
    required this.color,
    required this.onChanged,
  });

  /// Time offered when the switch is first turned on.
  static const defaultMinutes = 20 * 60 + 30;

  final int? reminderMinutes;
  final Color color;
  final ValueChanged<int?> onChanged;

  Future<void> _pickTime(BuildContext context) async {
    final current = reminderMinutes ?? defaultMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
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
    if (picked != null) onChanged(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = reminderMinutes;
    final enabled = minutes != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: context.l10n.editorAlertsTag,
          title: context.l10n.editorNotifications,
          trailing: enabled ? 'PUSH_ARMED' : 'PUSH_OFF',
          trailingColor: enabled ? color : AppColors.textMuted,
        ),
        const SizedBox(height: 10),
        EditorPanel(
          accent: enabled ? color : null,
          child: Row(
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
                      context.l10n.editorDailyPrompt,
                      style: AppTextStyles.headlineSm,
                    ),
                    Text(
                      enabled
                          ? context.l10n.editorPromptOn
                          : context.l10n.editorNoReminder,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              if (enabled)
                GestureDetector(
                  onTap: () => _pickTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cyan),
                    ),
                    child: Text(
                      formatReminderTime(context, minutes),
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ),
              Switch(
                value: enabled,
                activeThumbColor: AppColors.textOnNeon,
                activeTrackColor: color,
                inactiveTrackColor: AppColors.surfaceHigh,
                onChanged: (on) => onChanged(on ? defaultMinutes : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
