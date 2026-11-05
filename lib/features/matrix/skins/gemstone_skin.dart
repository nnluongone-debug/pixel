import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Faceted gem: light and dark triangles in the habit color, a specular
/// corner, and a few twinkling four-point stars in the overlay.
class GemstoneSkin extends BrickSkin {
  const GemstoneSkin();

  static const int _stars = 5;
  static const double _twinkleSeconds = 1.6;

  @override
  bool get animated => true;

  @override
  Color get panelColor => const Color(0xFF0A0B16);

  @override
  Color get panelBorderColor => const Color(0xFFB9C6FF).withValues(alpha: 0.2);

  @override
  void paintSlot(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(BrickSkin.radius),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0x33B9C6FF));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x33B9C6FF),
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
    final light = Color.lerp(color, Colors.white, 0.45)!;
    final dark = Color.lerp(color, Colors.black, 0.4)!;
    final inset = rect.height * 0.28;
    final inner = rect.deflate(inset);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(BrickSkin.radius)),
    );
    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: opacity));
    // Four trapezoid facets between the outer and inner rectangles.
    void facet(List<Offset> points, Color c) => canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = c.withValues(alpha: opacity),
    );
    facet([rect.topLeft, rect.topRight, inner.topRight, inner.topLeft], light);
    facet([
      rect.topLeft,
      inner.topLeft,
      inner.bottomLeft,
      rect.bottomLeft,
    ], Color.lerp(color, light, 0.4)!);
    facet([
      rect.topRight,
      rect.bottomRight,
      inner.bottomRight,
      inner.topRight,
    ], Color.lerp(color, dark, 0.5)!);
    facet([
      rect.bottomLeft,
      inner.bottomLeft,
      inner.bottomRight,
      rect.bottomRight,
    ], dark);
    // Specular corner.
    canvas.drawRect(
      Rect.fromLTWH(rect.left + 1.5, rect.top + 1.5, 2.5, 2.5),
      Paint()..color = Colors.white.withValues(alpha: 0.9 * opacity),
    );
    canvas.restore();
  }

  @override
  void paintOverlay(
    Canvas canvas,
    Size size,
    List<Rect> bricks,
    List<Color> colors,
    double t,
  ) {
    if (bricks.isEmpty) return;
    final paint = Paint();
    for (var i = 0; i < _stars; i++) {
      // Each star lives one slot of time then hops to another random brick.
      final shifted = t / _twinkleSeconds + i / _stars;
      final cycle = shifted.floor();
      final phase = shifted - cycle;
      final rng = overlayRandom(cycle * _stars + i);
      final rect = bricks[rng.nextInt(bricks.length)];
      final strength = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
      final center = Offset(
        rect.left + rect.width * (0.25 + rng.nextDouble() * 0.5),
        rect.top + rect.height * (0.25 + rng.nextDouble() * 0.5),
      );
      final arm = 1 + 4 * strength;
      paint.color = Colors.white.withValues(alpha: 0.95 * strength);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 2 * arm, height: 1.2),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 1.2, height: 2 * arm),
        paint,
      );
    }
  }
}
