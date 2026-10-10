import '../../../core/l10n/l10n.dart';
import '../stats_formatters.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/pixel_badge.dart';
import 'badge_card.dart';

/// Bottom sheet listing every badge with its description.
class BadgesSheet extends StatelessWidget {
  const BadgesSheet({super.key, required this.badges});

  final List<BadgeStatus> badges;

  static Future<void> show(BuildContext context, List<BadgeStatus> badges) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BadgesSheet(badges: badges),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((b) => b.isUnlocked).length;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            context.l10n.statsBadgesTitle(unlocked, badges.length),
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.mint),
          ),
          const SizedBox(height: 4),
          Text(context.l10n.statsBadgesNoXp, style: AppTextStyles.bodySm),
          const SizedBox(height: 16),
          for (final badge in badges)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 148,
                    height: 212,
                    child: BadgeCard(status: badge),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.badgeDescription(badge.definition.id),
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
