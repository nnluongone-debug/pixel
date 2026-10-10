import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/pixel_badge.dart';

/// How rich a badge looks per rarity tier. Each tier keeps everything the
/// tier below has and adds more, so harder badges always look better.
class BadgeTierStyle {
  const BadgeTierStyle._({
    required this.glow,
    required this.frameWidth,
    required this.shine,
    required this.pulse,
    required this.doubleFrame,
    required this.orbiters,
    required this.rainbow,
    required this.rays,
    required this.burstParticles,
    required this.labelColor,
  });

  /// Halo strength behind the sprite (0..1).
  final double glow;
  final double frameWidth;

  /// Diagonal light sweep across the sprite every cycle.
  final bool shine;

  /// Halo breathes in and out.
  final bool pulse;
  final bool doubleFrame;

  /// Sparkles circling the tile.
  final int orbiters;

  /// Sprite pixels cycle through the neon palette.
  final bool rainbow;

  /// Light rays rotating behind the sprite.
  final bool rays;

  /// Sparks thrown by the unlock popup.
  final int burstParticles;
  final Color labelColor;

  bool get animated => shine || pulse || orbiters > 0 || rainbow || rays;

  static BadgeTierStyle of(BadgeTier tier) => switch (tier) {
    BadgeTier.common => const BadgeTierStyle._(
      glow: 0.35,
      frameWidth: 1,
      shine: false,
      pulse: false,
      doubleFrame: false,
      orbiters: 0,
      rainbow: false,
      rays: false,
      burstParticles: 14,
      labelColor: AppColors.textSecondary,
    ),
    BadgeTier.rare => const BadgeTierStyle._(
      glow: 0.5,
      frameWidth: 1.5,
      shine: true,
      pulse: false,
      doubleFrame: false,
      orbiters: 0,
      rainbow: false,
      rays: false,
      burstParticles: 22,
      labelColor: AppColors.cyan,
    ),
    BadgeTier.epic => const BadgeTierStyle._(
      glow: 0.7,
      frameWidth: 1.5,
      shine: true,
      pulse: true,
      doubleFrame: true,
      orbiters: 3,
      rainbow: false,
      rays: false,
      burstParticles: 32,
      labelColor: AppColors.lavender,
    ),
    BadgeTier.legendary => const BadgeTierStyle._(
      glow: 0.9,
      frameWidth: 2,
      shine: true,
      pulse: true,
      doubleFrame: true,
      orbiters: 6,
      rainbow: true,
      rays: true,
      burstParticles: 48,
      labelColor: AppColors.amber,
    ),
  };
}
