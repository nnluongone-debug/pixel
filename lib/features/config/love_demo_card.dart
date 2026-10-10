import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/demo/love_demo_seeder.dart';
import '../../domain/analytics/pixel_badge.dart';
import '../../providers/account_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/locale_providers.dart';
import '../../providers/repository_providers.dart';
import '../stats/badge_unlock_listener.dart';

/// Config card that replaces local data with the LOVE matrix demo.
/// Disabled while signed in so sample data never syncs to an account.
class LoveDemoCard extends ConsumerStatefulWidget {
  const LoveDemoCard({super.key});

  @override
  ConsumerState<LoveDemoCard> createState() => _LoveDemoCardState();
}

class _LoveDemoCardState extends ConsumerState<LoveDemoCard> {
  bool _busy = false;

  Future<void> _build() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: Text(
          l10n.configDemoConfirmTitle,
          style: AppTextStyles.headlineSm,
        ),
        content: Text(l10n.configDemoConfirmBody, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.configDemoConfirm,
              style: AppTextStyles.labelLg.copyWith(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await LoveDemoSeeder(
        ref.read(databaseProvider),
      ).seed(lang: ref.read(effectiveLocaleProvider).languageCode);
      // The demo unlocks most badges at once; skip the popup parade.
      await ref.read(sharedPreferencesProvider).setStringList(
        BadgeUnlockListener.seenKey,
        [for (final id in BadgeId.values) id.name],
      );
      ref.read(habitsControllerProvider.notifier).refreshAll();
      HapticFeedback.heavyImpact();
      messenger.showSnackBar(SnackBar(content: Text(l10n.configDemoDone)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.configDemoFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = ref.watch(authUserProvider).value != null;
    const pink = Color(0xFFFF4D94);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(glowColor: signedIn ? null : pink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.configDemoTitle,
            style: AppTextStyles.labelLg.copyWith(
              color: pink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            signedIn ? l10n.configDemoSignedIn : l10n.configDemoBody,
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: pink,
                foregroundColor: AppColors.textOnNeon,
              ),
              onPressed: signedIn || _busy ? null : _build,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite_rounded),
              label: Text(l10n.configDemoButton),
            ),
          ),
        ],
      ),
    );
  }
}
