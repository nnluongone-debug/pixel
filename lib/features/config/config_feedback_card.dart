import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_info_providers.dart';
import '../../providers/growth_providers.dart';
import '../../providers/onboarding_providers.dart';
import '../../services/feedback_service.dart';

/// Feedback email, replay of the first-run intro, and the app version.
class ConfigFeedbackCard extends ConsumerWidget {
  const ConfigFeedbackCard({super.key});

  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final info = await ref.read(appInfoProvider.future);
    final uri = FeedbackService.buildMailUri(
      subject: l10n.feedbackEmailSubject,
      hint: l10n.feedbackEmailHint,
      version: info.version,
      build: info.buildNumber,
      locale: locale,
    );
    final opened = await ref.read(feedbackServiceProvider).open(uri);
    if (opened) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(l10n.feedbackNoMailApp(FeedbackService.supportEmail)),
        action: SnackBarAction(
          label: l10n.feedbackCopy,
          onPressed: () => Clipboard.setData(
            const ClipboardData(text: FeedbackService.supportEmail),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(appInfoProvider).value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline, color: AppColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.configFeedbackTitle,
                  style: AppTextStyles.headlineSm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.configFeedbackBody,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => _send(context, ref),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(l10n.configFeedbackSend),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(onboardingDoneProvider.notifier).reset(),
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: Text(l10n.configReplayIntro),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyan,
                side: const BorderSide(color: AppColors.cyan),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _UsageStatsToggle(),
          if (info != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.configAppVersion(info.version, info.buildNumber),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opt-out for anonymous usage analytics (see privacy policy).
class _UsageStatsToggle extends ConsumerWidget {
  const _UsageStatsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = ref.watch(usageAnalyticsEnabledProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.configUsageStatsTitle, style: AppTextStyles.labelMd),
              const SizedBox(height: 2),
              Text(
                l10n.configUsageStatsBody,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: enabled,
          onChanged: ref.read(usageAnalyticsEnabledProvider.notifier).set,
        ),
      ],
    );
  }
}
