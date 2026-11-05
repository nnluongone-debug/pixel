import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'brick_skin.dart';

/// Default skin: flat neon bricks with a soft glow halo.
class NeonGlowSkin extends BrickSkin {
  const NeonGlowSkin();

  @override
  Color get panelColor => AppColors.surfaceLowest;

  @override
  Color get panelBorderColor => AppColors.outlineVariant.withValues(alpha: 0.2);

  /// Translucent dark fill with a thin dim outline.
  @override
  void paintSlot(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(BrickSkin.radius),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.matrixSlotFill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.matrixSlotBorder,
    );
  }

  @override
  void paintBrick(
    Canvas canvas,
    Rect rect,
    Color color, {
    double opacity = 1,
    double glow = 1,
  }) {
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(BrickSkin.radius),
    );

    if (glow > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(
            alpha: (0.7 * glow).clamp(0.0, 1.0) * opacity,
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 2 * glow),
      );
    }
    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: opacity));
  }
}
