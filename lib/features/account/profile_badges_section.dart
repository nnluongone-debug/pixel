import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/analytics/pixel_badge.dart';
import '../../providers/analytics_providers.dart';
import '../habit_editor/editor_parts.dart';
import '../stats/stats_formatters.dart';
import '../stats/widgets/badge_style.dart';
import '../stats/widgets/pixel_badge_art.dart';

/// "PIXEL BADGES n/total": every unlocked badge, newest first.
class ProfileBadgesSection extends ConsumerWidget {
  const ProfileBadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = ref.watch(badgesProvider);
    final unlocked = [
      for (final b in all ?? const <BadgeStatus>[])
        if (b.isUnlocked) b,
    ]..sort((a, b) => b.unlockedDay!.compareTo(a.unlockedDay!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: '06',
          title: l10n.accountBadgesTitle,
          trailing: all == null ? '--' : '${unlocked.length}/${all.length}',
          trailingColor: AppColors.amber,
        ),
        const SizedBox(height: 10),
        if (all == null)
          const EditorPanel(
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (unlocked.isEmpty)
          EditorPanel(
            child: Text(l10n.accountBadgesEmpty, style: AppTextStyles.bodyMd),
          )
        else
          for (final badge in unlocked) _BadgeRow(status: badge),
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.status});

  final BadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final definition = status.definition;
    final color = BadgeStyle.color(definition.glyph);
    final date = DateTime.fromMillisecondsSinceEpoch(
      status.unlockedDay! * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppGlow.card(glowColor: color),
        child: Row(
          children: [
            PixelBadgeArt(definition: definition, unlocked: true, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.badgeTier(definition.tier),
                    style: AppTextStyles.labelSm.copyWith(color: color),
                  ),
                  Text(
                    l10n.badgeName(definition.id).toUpperCase(),
                    style: AppTextStyles.labelLg,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n.accountBadgeUnlockedOn(
                      StatsFormat.monthDay(date, context.localeTag),
                    ),
                    style: AppTextStyles.labelSm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
