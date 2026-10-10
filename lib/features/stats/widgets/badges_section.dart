import '../../../core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/analytics_providers.dart';
import 'badge_card.dart';
import 'badges_sheet.dart';

/// PIXEL BADGES (n/total) carousel with a VIEW ALL sheet.
class BadgesSection extends ConsumerWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgesProvider);
    if (badges == null) return const SizedBox.shrink();
    final unlocked = badges.where((b) => b.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.l10n.statsBadgesTitle(unlocked, badges.length),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.mint),
              ),
            ),
            TextButton(
              onPressed: () => BadgesSheet.show(context, badges),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cyan,
                visualDensity: VisualDensity.compact,
                textStyle: AppTextStyles.labelSm,
              ),
              child: Text(context.l10n.statsViewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 212,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                SizedBox(width: 148, child: BadgeCard(status: badges[i])),
          ),
        ),
      ],
    );
  }
}
