import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Starlight Nebula: deep indigo-to-violet bricks tinted by the habit color,
/// with fixed star specks and a slow twinkle in the overlay. No blur.
class NebulaSkin extends BrickSkin {
  const NebulaSkin();

  static const Color _indigo = Color(0xFF1A1052);
  static const Color _violet = Color(0xFF6A35C8);
  static const double _twinkleSeconds = 2.8;
  static const int _twinkles = 6;

  @override
  bool get animated => true;

  /// Slow shimmer needs far fewer frames than a glitch.
  @override
  Duration overlayFrameDelay(double t) => const Duration(milliseconds: 83);

  @override
  Color get panelColor => const Color(0xFF060316);

  @override
  Color get panelBorderColor => _violet.withValues(alpha: 0.3);

  @override
  void paintSlot(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(BrickSkin.radius),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0x1F6A35C8));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x3D8A63E0),
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
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(_indigo, color, 0.18)!,
            Color.lerp(_violet, color, 0.3)!,
          ],
        ).createShader(rect)
        ..color = Colors.white.withValues(alpha: opacity),
    );
    // Habit-colored nebula glow along the lower edge.
    canvas.drawRect(
      Rect.fromLTRB(
        rect.left + 2,
        rect.bottom - 3,
        rect.right - 2,
        rect.bottom - 1,
      ),
      Paint()..color = color.withValues(alpha: 0.75 * opacity),
    );
    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFB79CFF).withValues(alpha: 0.4 * opacity),
    );
    // Fixed star specks, positions derived from the brick position.
    final seed = (rect.left * 7 + rect.top * 13).round();
    final rng = overlayRandom(seed);
    final star = Paint()..color = Colors.white.withValues(alpha: 0.8 * opacity);
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left + 2 + rng.nextDouble() * (rect.width - 5),
          rect.top + 2 + rng.nextDouble() * (rect.height - 7),
          1,
          1,
        ),
        star,
      );
    }
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
    for (var i = 0; i < _twinkles; i++) {
      final shifted = t / _twinkleSeconds + i / _twinkles;
      final cycle = shifted.floor();
      final phase = shifted - cycle;
      final rng = overlayRandom(cycle * _twinkles + i + 101);
      final rect = bricks[rng.nextInt(bricks.length)];
      final strength = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
      // Slow drift across the brick while the star shines.
      final x = rect.left + rect.width * (0.2 + 0.5 * rng.nextDouble());
      final y = rect.top + rect.height * (0.2 + 0.4 * rng.nextDouble());
      final center = Offset(x + phase * 3, y);
      paint.color = Colors.white.withValues(alpha: 0.9 * strength);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 1 + 3 * strength, height: 1),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 1, height: 1 + 3 * strength),
        paint,
      );
    }
  }
}
