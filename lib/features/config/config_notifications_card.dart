import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/habit_providers.dart';
import '../../providers/reminder_providers.dart';
import '../../services/reminder_service.dart';
import '../habit_editor/alerts_section.dart';
import 'config_reminder_row.dart';

/// Notification permission, the scheduled-prompt summary and, on tap, the
/// per-habit reminder schedule folded out below it.
class ConfigNotificationsCard extends ConsumerStatefulWidget {
  const ConfigNotificationsCard({super.key});

  @override
  ConsumerState<ConfigNotificationsCard> createState() =>
      _ConfigNotificationsCardState();
}

class _ConfigNotificationsCardState
    extends ConsumerState<ConfigNotificationsCard> {
  bool _busy = false;
  bool _expanded = false;

  Future<void> _request() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final blocked = context.l10n.configBlocked;
    final granted = await ref.read(reminderServiceProvider).requestPermission();
    ref.invalidate(notificationsEnabledProvider);
    ref.invalidate(reminderSummaryProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!granted) messenger?.showSnackBar(SnackBar(content: Text(blocked)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = ref.watch(notificationsEnabledProvider).value;
    final color = enabled == true ? AppColors.mint : AppColors.amber;
    final status = switch (enabled) {
      true => 'PUSH_READY',
      false => 'PUSH_BLOCKED',
      null => l10n.configChecking,
    };
    final habits = ref.watch(habitsControllerProvider).value ?? const [];
    final withReminder = [
      for (final h in habits)
        if (h.hasReminder) h,
    ]..sort((a, b) => a.reminderSlots.first.compareTo(b.reminderSlots.first));

    return Container(
      width: double.infinity,
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active_outlined, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.configNotifications,
                          style: AppTextStyles.headlineSm,
                        ),
                      ),
                      Text(
                        status,
                        style: AppTextStyles.labelSm.copyWith(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryLine(
                          summary: ref.watch(reminderSummaryProvider).value,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.configScheduledCount(withReminder.length),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.expand_more,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        if (withReminder.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              l10n.configNoReminders,
                              style: AppTextStyles.bodySm,
                            ),
                          ),
                        for (final habit in withReminder) ...[
                          ConfigReminderRow(habit: habit),
                          if (habit != withReminder.last)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
          ),
          if (enabled == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _request,
                  child: Text(l10n.configAllow),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Scheduled N prompts, next at Mon 20:30" from the plugin's pending list.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.summary});

  final ReminderSummary? summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = summary?.next;
    final text = summary == null
        ? ''
        : next == null
        ? l10n.configSummaryNone
        : l10n.configSummary(
            summary!.pending,
            '${l10n.weekdayShort(next.weekday)} '
            '${formatReminderTime(context, next.hour * 60 + next.minute)}',
          );
    return Text(text, style: AppTextStyles.labelSm);
  }
}
