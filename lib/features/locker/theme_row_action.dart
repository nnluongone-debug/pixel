import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';

/// Right side of a theme row: EQUIP, ACTIVE, or the unlock condition chip.
class ThemeRowAction extends StatelessWidget {
  const ThemeRowAction({
    super.key,
    required this.theme,
    required this.unlocked,
    required this.active,
    required this.progress,
    required this.onEquip,
  });

  final BrickTheme theme;
  final bool unlocked;
  final bool active;
  final ThemeProgress? progress;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (active) {
      return _Chip(
        label: l10n.lockerActive,
        icon: Icons.check,
        filled: true,
        color: AppColors.mint,
      );
    }
    if (unlocked) {
      return GestureDetector(
        onTap: onEquip,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          child: Container(
            constraints: const BoxConstraints(minWidth: 76, minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderActive),
            ),
            child: Text(l10n.lockerEquip, style: AppTextStyles.labelLg),
          ),
        ),
      );
    }
    final unlock = theme.unlock;
    if (unlock.proOnly) {
      return _Chip(
        label: l10n.lockerPro,
        icon: Icons.lock_outline,
        color: AppColors.textSecondary,
      );
    }
    final label = unlock.level != null
        ? l10n.lockerLevelChip(unlock.level!)
        : l10n.lockerStreakProgress(
            (progress?.bestStreak ?? 0).clamp(0, unlock.streakDays!),
            unlock.streakDays!,
          );
    return Text(
      label,
      style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.textOnNeon : color;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: filled ? color : null,
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
