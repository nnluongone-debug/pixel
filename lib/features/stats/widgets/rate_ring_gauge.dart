import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Ring of pixel segments; the first `ratio` share is lit.
class RateRingGauge extends StatelessWidget {
  const RateRingGauge({
    super.key,
    required this.ratio,
    this.color = AppColors.cyan,
    this.size = 44,
  });

  final double ratio;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: RateRingPainter(ratio: ratio.clamp(0.0, 1.0), color: color),
    );
  }
}

class RateRingPainter extends CustomPainter {
  const RateRingPainter({required this.ratio, required this.color});

  static const int segments = 20;

  final double ratio;
  final Color color;

  /// Segments lit for [ratio]; any progress lights at least one.
  static int litSegments(double ratio) =>
      ratio <= 0 ? 0 : math.max(1, (ratio * segments).round());

  @override
  void paint(Canvas canvas, Size size) {
    final lit = litSegments(ratio);
    final radius = size.shortestSide / 2;
    final pixel = size.shortestSide / 9;
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < segments; i++) {
      canvas.save();
      canvas.rotate(2 * math.pi * i / segments - math.pi / 2);
      canvas.translate(radius - pixel / 2, 0);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: pixel,
        height: pixel * 0.8,
      );
      canvas.drawRect(
        rect,
        Paint()..color = i < lit ? color : AppColors.cellEmpty,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(RateRingPainter old) =>
      old.ratio != ratio || old.color != color;
}
