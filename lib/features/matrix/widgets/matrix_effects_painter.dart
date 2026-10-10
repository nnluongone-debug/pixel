import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'brick_painter.dart';
import 'drop_effect.dart';
import 'matrix_layout.dart';

/// Animated layer: falling bricks, landing squash/flash and sparkles.
/// Repaints every frame only while at least one effect is running.
class MatrixEffectsPainter extends CustomPainter {
  MatrixEffectsPainter({required this.geometry, required this.effects})
    : super(repaint: Listenable.merge([for (final e in effects) e.controller]));

  final MatrixGeometry geometry;
  final List<DropEffect> effects;

  static final double _fallMs = DropEffect.fall.inMilliseconds.toDouble();
  static final double _settleMs = DropEffect.settle.inMilliseconds.toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    for (final effect in effects) {
      final ms = effect.elapsedMs;
      if (ms < 0) continue;
      final placed = effect.placed;
      final target = geometry.slotRect(placed.column, placed.slot);
      final color = placed.block.color;

      if (ms < _fallMs) {
        _paintFalling(canvas, target, color, ms / _fallMs);
      } else {
        final u = ((ms - _fallMs) / _settleMs).clamp(0.0, 1.0);
        _paintLanded(canvas, target, color, u);
        _paintSparkles(canvas, target, color, effect, (ms - _fallMs) / 1000);
      }
    }
  }

  /// Accelerating fall from just above the grid, with a faint trail.
  void _paintFalling(Canvas c, Rect target, Color color, double t) {
    final startTop = -geometry.cellHeight * 1.6;
    final top = lerpDouble(
      startTop,
      target.top,
      Curves.easeInCubic.transform(t),
    )!;
    final rect = target.shift(Offset(0, top - target.top));
    final opacity = (t / 0.25).clamp(0.0, 1.0);

    final trailOffset = geometry.cellHeight * 0.6 * t;
    BrickPainter.paintBrick(
      c,
      rect.shift(Offset(0, -trailOffset)),
      color,
      opacity: 0.18 * opacity,
      glow: 0,
    );
    BrickPainter.paintBrick(c, rect, color, opacity: opacity, glow: 0.7);
  }

  /// Bottom-anchored squash on impact, then a fading glow flash.
  void _paintLanded(Canvas c, Rect target, Color color, double u) {
    final squash = u < 0.3 ? sin(pi * u / 0.3) * 0.16 : 0.0;
    final rect = Rect.fromLTRB(
      target.left - target.width * squash * 0.25,
      target.top + target.height * squash,
      target.right + target.width * squash * 0.25,
      target.bottom,
    );
    BrickPainter.paintBrick(c, rect, color, glow: 1 + 1.6 * (1 - u));
  }

  void _paintSparkles(
    Canvas canvas,
    Rect target,
    Color color,
    DropEffect effect,
    double seconds,
  ) {
    final sparkColor = Color.lerp(color, Colors.white, 0.55)!;
    final core = Paint();
    final halo = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (final s in effect.sparkles) {
      if (seconds > s.life) continue;
      final alpha = 1 - seconds / s.life;
      final center = Offset(
        target.left + s.x * target.width + s.vx * seconds,
        target.top + s.vy * seconds + 0.5 * Sparkle.gravity * seconds * seconds,
      );
      final rect = Rect.fromCenter(
        center: center,
        width: s.size,
        height: s.size,
      );
      halo.color = color.withValues(alpha: 0.6 * alpha);
      canvas.drawRect(rect.inflate(1.5), halo);
      core.color = sparkColor.withValues(alpha: alpha);
      canvas.drawRect(rect, core);
    }
  }

  @override
  bool shouldRepaint(MatrixEffectsPainter old) =>
      old.effects != effects || old.geometry.width != geometry.width;
}
