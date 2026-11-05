import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/reminder_providers.dart';

/// Optional "Enable reminders" button on the last intro page. Never blocks
/// finishing the intro; the result is shown as a short status line.
class OnboardingReminderAction extends ConsumerStatefulWidget {
  const OnboardingReminderAction({super.key});

  @override
  ConsumerState<OnboardingReminderAction> createState() =>
      _OnboardingReminderActionState();
}

class _OnboardingReminderActionState
    extends ConsumerState<OnboardingReminderAction> {
  bool _busy = false;
  bool? _granted;

  Future<void> _request() async {
    if (_busy) return;
    setState(() => _busy = true);
    var granted = false;
    try {
      granted = await ref.read(reminderServiceProvider).requestPermission();
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
    ref.invalidate(notificationsEnabledProvider);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _granted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final granted = _granted;
    if (granted != null) {
      return Text(
        granted ? l10n.onboardingRemindersOn : l10n.onboardingRemindersDenied,
        style: AppTextStyles.labelLg.copyWith(
          color: granted ? AppColors.mint : AppColors.amber,
        ),
        textAlign: TextAlign.center,
      );
    }
    return OutlinedButton.icon(
      onPressed: _busy ? null : _request,
      icon: const Icon(Icons.notifications_active_outlined),
      label: Text(l10n.onboardingEnableReminders),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: AppTextStyles.labelLg,
      ),
    );
  }
}
