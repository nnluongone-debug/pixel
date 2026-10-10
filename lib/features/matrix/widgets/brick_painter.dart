import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Canvas primitives for matrix slots and arcade bricks.
abstract final class BrickPainter {
  static const double radius = 2;

  /// Empty slot: translucent dark fill with a thin dim outline.
  static void paintSlot(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(radius),
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

  /// Flat neon brick with a soft glow halo.
  ///
  /// [glow] scales the halo (1 = resting, >1 = landing flash).
  static void paintBrick(
    Canvas canvas,
    Rect rect,
    Color color, {
    double opacity = 1,
    double glow = 1,
  }) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));

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
