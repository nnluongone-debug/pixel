import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';

/// Rounded square with the habit icon on a tinted, outlined background.
class HabitIconBox extends StatelessWidget {
  const HabitIconBox({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: AppGlow.soft(color),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// Mono outlined tag, e.g. "5/8 GL" or "15D STREAK". [muted] greys it out
/// (e.g. "REST DAY").
class HabitBadge extends StatelessWidget {
  const HabitBadge({
    super.key,
    required this.text,
    required this.color,
    this.muted = false,
  });

  final String text;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tone = muted ? AppColors.textMuted : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Row of pixel segments. A segment that just became filled pops.
class MiniPixelBar extends StatelessWidget {
  const MiniPixelBar({
    super.key,
    required this.segments,
    required this.filled,
    required this.color,
  });

  final int segments;
  final int filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < segments; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          // Shrinks on narrow cards, never wider than a pixel brick.
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 16),
              // Keyed on fill state so filling restarts the pop animation.
              child: TweenAnimationBuilder<double>(
                key: ValueKey('$i-${i < filled}'),
                tween: Tween(begin: i < filled ? 1.4 : 1, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 8,
                  decoration: BoxDecoration(
                    color: i < filled ? color : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(2),
                    border: i < filled
                        ? null
                        : Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                    boxShadow: i < filled ? AppGlow.cell(color) : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "+25 XP" label that the card floats above its action button.
class XpFloatLabel extends StatelessWidget {
  const XpFloatLabel({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.gridXpGain(xp),
      style: AppTextStyles.labelLg.copyWith(
        color: AppColors.amber,
        fontWeight: FontWeight.w800,
        shadows: [const Shadow(color: AppColors.amber, blurRadius: 10)],
      ),
    );
  }
}
