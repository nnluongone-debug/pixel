import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Four-shade green LCD look: no blur, hard 1px outline.
class GameBoySkin extends BrickSkin {
  const GameBoySkin();

  static const Color darkest = Color(0xFF0F380F);
  static const Color dark = Color(0xFF306230);
  static const Color light = Color(0xFF8BAC0F);
  static const Color lightest = Color(0xFF9BBC0F);

  @override
  Color get panelColor => lightest;

  @override
  Color get panelBorderColor => darkest;

  /// Maps a habit color to one of the four shades by luminance, so habits
  /// keep distinct tones (darker colors get darker greens).
  static Color shadeFor(Color color) {
    final l = color.computeLuminance();
    if (l < 0.37) return darkest;
    if (l < 0.45) return dark;
    if (l < 0.56) return light;
    return lightest;
  }

  @override
  void paintSlot(Canvas canvas, Rect rect) {
    // Faint dotted-LCD look: outline only, so empty slots never read as
    // light-shade bricks.
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = dark.withValues(alpha: 0.22),
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
    final shade = shadeFor(color);
    canvas.drawRect(rect, Paint()..color = shade.withValues(alpha: opacity));
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = darkest.withValues(alpha: opacity),
    );
    // Shaded lower half gives light bricks body against the panel.
    if (shade == lightest) {
      canvas.drawRect(
        Rect.fromLTRB(
          rect.left + 1,
          rect.center.dy,
          rect.right - 1,
          rect.bottom - 1,
        ),
        Paint()..color = light.withValues(alpha: opacity),
      );
    }
    // Single-pixel highlight keeps the lightest shade readable on the panel.
    if (shade != darkest) {
      canvas.drawRect(
        Rect.fromLTWH(rect.left + 2, rect.top + 2, 2, 2),
        Paint()..color = lightest.withValues(alpha: 0.8 * opacity),
      );
    }
  }
}
