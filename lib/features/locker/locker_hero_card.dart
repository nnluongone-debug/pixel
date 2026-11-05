import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import '../../providers/cosmetics_providers.dart';
import '../../services/sound/sound_slot.dart';
import 'locker_equip.dart';
import 'locker_names.dart';
import 'theme_preview.dart';

/// "ACTIVE SKIN" card: big preview of the equipped theme, its tier and sound
/// pack (tap the pack to hear it).
class LockerHeroCard extends ConsumerWidget {
  const LockerHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ThemeCatalog.of(ref.watch(equippedThemeProvider));
    final color = theme.tier.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(glowColor: color, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.mint),
                const SizedBox(width: 6),
                Text(
                  l10n.lockerActiveSkin,
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.mint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(child: ThemePreview.hero(id: theme.id, size: 220)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.themeName(theme.id),
                  style: AppTextStyles.headlineSm,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.tierLine(theme.tier),
                  style: AppTextStyles.labelSm.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => LockerEquip.previewSound(ref, theme.sound, const [
              SoundSlot.complete,
              SoundSlot.levelUp,
            ]),
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 14, color: AppColors.cyan),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.soundPackName(theme.sound),
                    style: AppTextStyles.labelMd,
                    overflow: TextOverflow.ellipsis,
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
