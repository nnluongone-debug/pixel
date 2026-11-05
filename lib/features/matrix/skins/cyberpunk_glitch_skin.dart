import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Dark bricks with magenta/cyan channel-offset edges and scanlines; the
/// overlay briefly RGB-splits a few random bricks every few seconds.
class CyberpunkGlitchSkin extends BrickSkin {
  const CyberpunkGlitchSkin();

  static const Color magenta = Color(0xFFFF2BD6);
  static const Color cyan = Color(0xFF00F0FF);
  static const double _periodSeconds = 3.2;
  static const double _glitchSeconds = 0.12;

  @override
  bool get animated => true;

  @override
  Color get panelColor => const Color(0xFF07060F);

  @override
  Color get panelBorderColor => magenta.withValues(alpha: 0.35);

  @override
  void paintSlot(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = const Color(0x3314102A));
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = cyan.withValues(alpha: 0.14),
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
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
      rect.shift(const Offset(-1, 0)).deflate(0.5),
      edge..color = magenta.withValues(alpha: 0.85 * opacity),
    );
    canvas.drawRect(
      rect.shift(const Offset(1, 0)).deflate(0.5),
      edge..color = cyan.withValues(alpha: 0.85 * opacity),
    );
    // Dark body tinted by the habit color, bright core stripe.
    canvas.drawRect(
      rect.deflate(1),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF0A0A14),
          color,
          0.28,
        )!.withValues(alpha: opacity),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left + 2, rect.center.dy - 1, rect.width - 4, 2),
      Paint()..color = color.withValues(alpha: opacity),
    );
    // Scanlines.
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * opacity);
    for (var y = rect.top + 1; y < rect.bottom; y += 2) {
      canvas.drawRect(Rect.fromLTWH(rect.left, y, rect.width, 0.7), scan);
    }
  }

  /// Frame by frame during a glitch (~24 fps), then asleep until the next.
  @override
  Duration overlayFrameDelay(double t) {
    final intoCycle = t - (t / _periodSeconds).floor() * _periodSeconds;
    if (intoCycle < _glitchSeconds) return const Duration(milliseconds: 41);
    final untilNext = _periodSeconds - intoCycle;
    return Duration(microseconds: (untilNext * 1e6).ceil() + 1000);
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
    final cycle = (t / _periodSeconds).floor();
    if (t - cycle * _periodSeconds > _glitchSeconds) return;

    final rng = overlayRandom(cycle);
    final count = 1 + rng.nextInt(3);
    for (var i = 0; i < count; i++) {
      final index = rng.nextInt(bricks.length);
      final rect = bricks[index];
      final dx = 2 + rng.nextDouble() * 3;
      canvas.drawRect(
        rect.shift(Offset(-dx, 0)),
        Paint()
          ..color = magenta.withValues(alpha: 0.6)
          ..blendMode = BlendMode.plus,
      );
      canvas.drawRect(
        rect.shift(Offset(dx, 0)),
        Paint()
          ..color = cyan.withValues(alpha: 0.6)
          ..blendMode = BlendMode.plus,
      );
      canvas.drawRect(
        rect.deflate(1),
        Paint()..color = colors[index].withValues(alpha: 0.9),
      );
    }
  }
}
