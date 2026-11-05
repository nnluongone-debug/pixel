import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/cosmetics/theme_catalog.dart';
import 'cyberpunk_glitch_skin.dart';
import 'game_boy_skin.dart';
import 'gemstone_skin.dart';
import 'nebula_skin.dart';
import 'neon_glow_skin.dart';
import 'pure_gold_skin.dart';

/// Visual style for matrix slots and bricks. Skins are stateless and const,
/// so the painters can compare them by identity.
abstract class BrickSkin {
  const BrickSkin();

  /// Corner radius shared by slots and bricks.
  static const double radius = 2;

  /// Skin for theme [id].
  static BrickSkin of(ThemeId id) => switch (id) {
    ThemeId.gameBoy => const GameBoySkin(),
    ThemeId.cyberpunk => const CyberpunkGlitchSkin(),
    ThemeId.gemstone => const GemstoneSkin(),
    ThemeId.pureGold => const PureGoldSkin(),
    ThemeId.nebula => const NebulaSkin(),
    ThemeId.neonGlow => const NeonGlowSkin(),
  };

  /// Whether [paintOverlay] draws something that changes over time.
  bool get animated => false;

  /// How long the overlay may sleep after drawing at [t] before it must be
  /// painted again. Skins that idle between effects return the time to the
  /// next one so no frames are requested in between.
  Duration overlayFrameDelay(double t) => const Duration(milliseconds: 41);

  /// Background of the matrix panel and editor preview tile.
  Color get panelColor;

  /// Border color hint for the matrix panel.
  Color get panelBorderColor;

  /// Empty slot.
  void paintSlot(Canvas canvas, Rect rect);

  /// One brick. [glow] scales any halo (1 = resting, >1 = landing flash,
  /// 0 = none); skins without a halo may ignore it.
  void paintBrick(
    Canvas canvas,
    Rect rect,
    Color color, {
    double opacity = 1,
    double glow = 1,
  });

  /// Cheap per-frame decoration drawn above the cached static layer.
  /// [bricks]/[colors] are the settled bricks; [t] is seconds since start.
  void paintOverlay(
    Canvas canvas,
    Size size,
    List<Rect> bricks,
    List<Color> colors,
    double t,
  ) {}
}

/// Deterministic pseudo-random picks so the overlay needs no state.
Random overlayRandom(int seed) => Random(seed * 7919 + 13);
