import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'badge_sprites.dart';
import 'badge_tier_style.dart';

/// Draws a badge tile: rays, halo, pixel sprite, frame and orbiting sparks.
/// [phase] (0..1, looping) drives every animated layer.
class BadgeArtPainter extends CustomPainter {
  BadgeArtPainter({
    required this.sprite,
    required this.color,
    required this.style,
    required this.unlocked,
    required this.phase,
  }) : super(repaint: phase);

  final List<String> sprite;
  final Color color;
  final BadgeTierStyle style;
  final bool unlocked;
  final Animation<double> phase;

  static const _lockedTone = Color(0xFF5A6070);
  static const _rainbow = [
    AppColors.amber,
    AppColors.rose,
    AppColors.lavender,
    AppColors.cyan,
    AppColors.mint,
    AppColors.amber,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = phase.value;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width * .22),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.inputInset);

    final area = rect.deflate(size.width * 0.14);
    final cell = area.width / BadgeSprites.size;

    if (unlocked && style.rays) _paintRays(canvas, rrect, t);
    if (unlocked) _paintHalo(canvas, area, cell, t);
    _paintPixels(canvas, area, cell, t);
    _paintFrame(canvas, rrect, t);
    if (unlocked && style.orbiters > 0) _paintOrbiters(canvas, rect, t);
  }

  void _paintRays(Canvas canvas, RRect clip, double t) {
    canvas.save();
    canvas.clipRRect(clip);
    final c = clip.outerRect.center;
    final r = clip.outerRect.width;
    final paint = Paint()..color = AppColors.amber.withValues(alpha: 0.16);
    for (var i = 0; i < 8; i++) {
      final a = t * 2 * pi / 2 + i * pi / 4;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + cos(a - 0.14) * r, c.dy + sin(a - 0.14) * r)
        ..lineTo(c.dx + cos(a + 0.14) * r, c.dy + sin(a + 0.14) * r)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  void _paintHalo(Canvas canvas, Rect area, double cell, double t) {
    final breathe = style.pulse ? 0.7 + 0.3 * sin(t * 4 * pi) : 1.0;
    final paint = Paint()
      ..color = color.withValues(alpha: style.glow * breathe * 0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 1.2);
    _forEachPixel((x, y, ch) {
      if (ch == 'o') return;
      canvas.drawRect(_cellRect(area, cell, x, y), paint);
    });
  }

  void _paintPixels(Canvas canvas, Rect area, double cell, double t) {
    // The shine band crosses the sprite diagonally in the first third.
    final shinePos = t < 0.35 ? t / 0.35 * 30 - 4 : -100.0;
    final paint = Paint();
    _forEachPixel((x, y, ch) {
      var base = !unlocked
          ? _lockedTone
          : style.rainbow
          ? _rainbowAt((x + y) / 22 + t)
          : color;
      base = switch (ch) {
        '+' => Color.lerp(base, Colors.white, 0.45)!,
        'o' => Color.lerp(base, Colors.black, 0.4)!,
        _ => base,
      };
      if (unlocked && style.shine) {
        final f = (1 - ((x + y) - shinePos).abs() / 2.5).clamp(0.0, 1.0);
        base = Color.lerp(base, Colors.white, f * 0.75)!;
      }
      paint.color = unlocked ? base : base.withValues(alpha: 0.45);
      canvas.drawRect(_cellRect(area, cell, x, y).deflate(cell * 0.04), paint);
    });
  }

  void _paintFrame(Canvas canvas, RRect rrect, double t) {
    final frame = rrect.deflate(style.frameWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.frameWidth;
    if (!unlocked) {
      paint.color = _lockedTone.withValues(alpha: 0.6);
    } else if (style.rainbow) {
      paint.shader = SweepGradient(
        colors: _rainbow,
        transform: GradientRotation(t * 2 * pi),
      ).createShader(rrect.outerRect);
    } else {
      paint.color = color.withValues(alpha: 0.8);
    }
    canvas.drawRRect(frame, paint);
    if (unlocked && style.doubleFrame) {
      canvas.drawRRect(
        rrect.deflate(style.frameWidth + 2.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.35),
      );
    }
  }

  void _paintOrbiters(Canvas canvas, Rect rect, double t) {
    final c = rect.center;
    final radius = rect.width * 0.58;
    final s = rect.width * 0.06;
    final core = Paint();
    final halo = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, s);
    for (var i = 0; i < style.orbiters; i++) {
      final a = t * 2 * pi + i * 2 * pi / style.orbiters;
      final p = Offset(c.dx + cos(a) * radius, c.dy + sin(a) * radius);
      final tint = style.rainbow ? _rainbowAt(i / style.orbiters) : color;
      halo.color = tint.withValues(alpha: 0.7);
      canvas.drawRect(
        Rect.fromCenter(center: p, width: s * 2, height: s * 2),
        halo,
      );
      core.color = Color.lerp(tint, Colors.white, 0.6)!;
      canvas.drawRect(Rect.fromCenter(center: p, width: s, height: s), core);
    }
  }

  Color _rainbowAt(double v) {
    final x = (v % 1) * (_rainbow.length - 1);
    final i = x.floor();
    return Color.lerp(_rainbow[i], _rainbow[i + 1], x - i)!;
  }

  void _forEachPixel(void Function(int x, int y, String ch) visit) {
    for (var y = 0; y < sprite.length; y++) {
      final row = sprite[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] != '.') visit(x, y, row[x]);
      }
    }
  }

  Rect _cellRect(Rect area, double cell, int x, int y) =>
      Rect.fromLTWH(area.left + x * cell, area.top + y * cell, cell, cell);

  @override
  bool shouldRepaint(BadgeArtPainter old) =>
      old.sprite != sprite ||
      old.color != color ||
      old.unlocked != unlocked ||
      old.style != style ||
      old.phase != phase;
}
