import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/new_unlock_marks.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import '../../providers/cosmetics_providers.dart';
import '../../providers/new_unlocks_provider.dart';
import '../../services/sound/sound_slot.dart';
import 'locker_equip.dart';
import 'locker_names.dart';
import 'theme_preview.dart';
import 'theme_row_action.dart';

/// One theme of the collection: thumbnail, names, state and, while locked,
/// how far the player is from the unlock condition.
class ThemeRow extends ConsumerWidget {
  const ThemeRow({super.key, required this.theme});

  final BrickTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unlocked = ref.watch(unlockedThemesProvider).contains(theme.id);
    final active = ref.watch(equippedThemeProvider) == theme.id;
    final progress = ref.watch(playerProgressProvider);
    final isNew = ref.watch(
      newUnlocksProvider.select(
        (s) => s[UnlockKind.theme]!.contains(theme.id.name),
      ),
    );
    final tierColor = theme.tier.color;
    final unlock = theme.unlock;
    final showProgress = !unlocked && !unlock.proOnly && progress != null;
    final tierText = [
      l10n.tierLine(theme.tier),
      if (unlocked && !unlock.isFree) l10n.lockerUnlockedMark,
    ].join(' • ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppGlow.card(glowColor: active ? AppColors.mint : null),
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: unlocked ? 1 : 0.8,
                child: ThemePreview(id: theme.id, size: 64),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.themeName(theme.id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? AppColors.mint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!unlocked && !unlock.proOnly) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ],
                        if (isNew) ...[
                          const SizedBox(width: 6),
                          const NewChip(),
                        ],
                        if (theme.tier == ThemeTier.cosmic) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.stars, size: 14, color: tierColor),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tierText,
                      style: AppTextStyles.labelSm.copyWith(color: tierColor),
                    ),
                    const SizedBox(height: 2),
                    _SoundLine(theme: theme),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ThemeRowAction(
                theme: theme,
                unlocked: unlocked,
                active: active,
                progress: progress,
                onEquip: () => LockerEquip.equip(ref, theme.id),
              ),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            _ProgressLine(
              theme: theme,
              progress: progress,
              ratio: unlock.ratio(progress, hasPro: ref.watch(hasProProvider)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoundLine extends ConsumerWidget {
  const _SoundLine({required this.theme});

  final BrickTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => LockerEquip.previewSound(ref, theme.sound, const [
      SoundSlot.complete,
      SoundSlot.levelUp,
    ]),
    child: Row(
      children: [
        const Icon(Icons.volume_up, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            context.l10n.soundPackName(theme.sound),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.theme,
    required this.progress,
    required this.ratio,
  });

  final BrickTheme theme;
  final ThemeProgress progress;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unlock = theme.unlock;
    final requirement = switch ((unlock.level, unlock.streakDays)) {
      (final int level, final int days) => l10n.lockerReqLevelOrStreak(
        level,
        days,
      ),
      (final int level, null) => l10n.lockerReqLevel(level),
      (null, final int days) => l10n.lockerReqStreak(days),
      _ => '',
    };
    final color = theme.tier.color;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: AppColors.cellEmpty,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                requirement,
                style: AppTextStyles.labelSm,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Floored, so a locked theme never reads 100%.
            Text('${(ratio * 100).floor()}%', style: AppTextStyles.labelSm),
          ],
        ),
      ],
    );
  }
}
