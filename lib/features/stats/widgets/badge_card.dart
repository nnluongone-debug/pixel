import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/check_in_record.dart';
import '../../../domain/analytics/pixel_badge.dart';
import '../stats_formatters.dart';
import 'badge_style.dart';
import 'badge_tier_style.dart';
import 'pixel_badge_art.dart';
import 'segmented_bar.dart';
import 'stat_tile.dart';

/// A badge with its rarity, artwork and state: the unlock date, or a
/// progress bar toward it while locked.
class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.status});

  final BadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final definition = status.definition;
    final id = definition.id;
    final tier = BadgeTierStyle.of(definition.tier);
    final unlocked = status.isUnlocked;
    final color = unlocked
        ? BadgeStyle.color(definition.glyph)
        : AppColors.textMuted;
    final day = status.unlockedDay;
    final showProgress = !unlocked && status.goal > 0;

    return Semantics(
      label: l10n.statsBadgeSemantics(
        l10n.badgeName(id),
        unlocked ? l10n.statsBadgeUnlocked : l10n.statsBadgeLocked,
        l10n.badgeDescription(id),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppGlow.card(glowColor: unlocked ? color : null),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.badgeTier(definition.tier),
              style: AppTextStyles.labelSm.copyWith(
                color: unlocked ? tier.labelColor : AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            PixelBadgeArt(definition: definition, unlocked: unlocked),
            const SizedBox(height: 8),
            Text(
              l10n.badgeName(id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            if (unlocked)
              StatChip(l10n.statsBadgeUnlocked, color: color)
            else if (showProgress)
              SegmentedBar(
                ratio: (status.progress / status.goal).clamp(0.0, 1.0),
                color: AppColors.textSecondary,
                segments: 10,
              ),
            const SizedBox(height: 6),
            Text(
              day == null
                  ? l10n.badgeProgress(status)
                  : StatsFormat.monthDay(
                      EpochDays.toDate(day),
                      context.localeTag,
                    ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
