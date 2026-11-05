import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import 'locker_names.dart';
import 'theme_preview.dart';

/// "NEW THEME!" popup. Resolves to true when the player
/// chose to equip the item right away.
abstract final class CosmeticUnlockDialog {
  static Future<bool> show(BuildContext context, BrickTheme theme) async {
    HapticFeedback.heavyImpact();
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.lockerLater,
      barrierColor: const Color(0xD9000000),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, _, _) => _Body(theme: theme),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: child,
        ),
      ),
    );
    return result ?? false;
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.theme});

  final BrickTheme theme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = theme.tier.color;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          decoration: AppGlow.card(glowColor: color, radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.lockerNewTheme,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm.copyWith(
                  color: color,
                  shadows: [Shadow(color: color, blurRadius: 14)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tierLine(theme.tier),
                style: AppTextStyles.labelMd.copyWith(color: color),
              ),
              const SizedBox(height: 20),
              ThemePreview.hero(id: theme.id, size: 160),
              const SizedBox(height: 16),
              Text(
                l10n.themeName(theme.id),
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.lockerEquipNow),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.lockerLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
