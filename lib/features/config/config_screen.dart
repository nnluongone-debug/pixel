import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_providers.dart';
import '../../providers/reminder_providers.dart';
import '../habit_editor/alerts_section.dart';
import '../habit_editor/habit_editor_sheet.dart';
import 'love_demo_card.dart';
import 'config_language_card.dart';
import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';

/// Config tab: language, notification permission, scheduled reminders.
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsControllerProvider).value ?? const [];
    final withReminder = [
      for (final h in habits)
        if (h.reminderMinutes != null) h,
    ]..sort((a, b) => a.reminderMinutes!.compareTo(b.reminderMinutes!));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Text(context.l10n.configTitle, style: AppTextStyles.headlineLg),
        const SizedBox(height: 16),
        const ConfigLanguageCard(),
        const SizedBox(height: 24),
        const _NotificationsCard(),
        const SizedBox(height: 24),
        Text(context.l10n.configScheduled, style: AppTextStyles.labelMd),
        const SizedBox(height: 8),
        if (withReminder.isEmpty)
          _Card(
            child: Text(
              context.l10n.configNoReminders,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          for (final habit in withReminder) ...[
            _ReminderRow(habit: habit),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 24),
        const LoveDemoCard(),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: AppGlow.card(),
    child: child,
  );
}

class _NotificationsCard extends ConsumerStatefulWidget {
  const _NotificationsCard();

  @override
  ConsumerState<_NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends ConsumerState<_NotificationsCard> {
  bool _busy = false;

  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = await action();
    ref.invalidate(notificationsEnabledProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    if (message != null) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<String?> _request() async {
    final l10n = context.l10n;
    final granted = await ref.read(reminderServiceProvider).requestPermission();
    return granted ? null : l10n.configBlocked;
  }

  Future<String?> _sendTest() async {
    final l10n = context.l10n;
    final service = ref.read(reminderServiceProvider);
    if (!await service.areNotificationsEnabled()) return l10n.configAllowFirst;
    return await service.showTestPrompt(l10n) ? null : l10n.configTestFailed;
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
    return _Card(
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
              Text(status, style: AppTextStyles.labelSm.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (enabled == false) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : () => _run(_request),
                    child: Text(l10n.configAllow),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _run(_sendTest),
                  child: Text(l10n.configSendTest),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => HabitEditorSheet.show(context, habit: habit),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppGlow.card(),
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
            Text(
              formatReminderTime(context, habit.reminderMinutes!),
              style: AppTextStyles.labelLg.copyWith(color: AppColors.cyan),
            ),
          ],
        ),
      ),
    );
  }
}
