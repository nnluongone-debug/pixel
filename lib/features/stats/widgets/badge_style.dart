import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/pixel_badge.dart';

/// Accent color for each badge artwork.
abstract final class BadgeStyle {
  static Color color(BadgeGlyph glyph) => switch (glyph) {
    BadgeGlyph.block || BadgeGlyph.stack || BadgeGlyph.tower => AppColors.cyan,
    BadgeGlyph.shield || BadgeGlyph.line || BadgeGlyph.crown => AppColors.mint,
    BadgeGlyph.sun || BadgeGlyph.calendar => AppColors.amber,
    BadgeGlyph.star || BadgeGlyph.bolt => AppColors.lavender,
  };
}
