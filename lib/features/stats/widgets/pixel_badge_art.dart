import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/pixel_badge.dart';
import 'badge_art_painter.dart';
import 'badge_sprites.dart';
import 'badge_style.dart';
import 'badge_tier_style.dart';

/// Animated pixel-art badge tile. Unlocked badges glow in their color with
/// tier-dependent effects; locked ones show a grey silhouette and a lock so
/// the user can see what they are working toward.
class PixelBadgeArt extends StatefulWidget {
  const PixelBadgeArt({
    super.key,
    required this.definition,
    required this.unlocked,
    this.size = 64,
  });

  final BadgeDefinition definition;
  final bool unlocked;
  final double size;

  @override
  State<PixelBadgeArt> createState() => _PixelBadgeArtState();
}

class _PixelBadgeArtState extends State<PixelBadgeArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phase = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  BadgeTierStyle get _style => BadgeTierStyle.of(widget.definition.tier);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(PixelBadgeArt old) {
    super.didUpdateWidget(old);
    _syncAnimation();
  }

  /// Loops only when there is something to animate and motion is allowed.
  void _syncAnimation() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animate = widget.unlocked && _style.animated && !reduceMotion;
    if (animate && !_phase.isAnimating) {
      _phase.repeat();
    } else if (!animate && _phase.isAnimating) {
      _phase
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glyph = widget.definition.glyph;
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BadgeArtPainter(
                sprite: BadgeSprites.of(glyph),
                color: BadgeStyle.color(glyph),
                style: _style,
                unlocked: widget.unlocked,
                phase: _phase,
              ),
            ),
          ),
          if (!widget.unlocked)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: widget.size * 0.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
