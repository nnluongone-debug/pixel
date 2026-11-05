import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Gold Relic & Obsidian: obsidian-black brick framed by a gold relic bevel,
/// with the habit color as a small inlaid square. No blur.
class PureGoldSkin extends BrickSkin {
  const PureGoldSkin();

  static const Color _hi = Color(0xFFFFE9A0);
  static const Color _mid = Color(0xFFE6B422);
  static const Color _lo = Color(0xFF8A5A0A);

  @override
  Color get panelColor => const Color(0xFF0A0808);

  @override
  Color get panelBorderColor => _mid.withValues(alpha: 0.35);

  @override
  void paintSlot(Canvas canvas, Rect rect) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      const Radius.circular(BrickSkin.radius),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0x22E6B422));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _lo.withValues(alpha: 0.55),
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
    // Obsidian body with a faint violet sheen toward the top-left.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2630), Color(0xFF0B090D)],
        ).createShader(rect)
        ..color = Colors.white.withValues(alpha: opacity),
    );
    // Gold relic frame: bright top/left, dark bottom/right.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final r = rect.deflate(0.6);
    canvas.drawLine(
      r.bottomLeft,
      r.bottomRight,
      edge..color = _lo.withValues(alpha: opacity),
    );
    canvas.drawLine(r.topRight, r.bottomRight, edge);
    canvas.drawLine(
      r.topLeft,
      r.topRight,
      edge..color = _hi.withValues(alpha: opacity),
    );
    canvas.drawLine(r.topLeft, r.bottomLeft, edge);
    canvas.drawRRect(
      rrect.deflate(2.2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = _mid.withValues(alpha: 0.35 * opacity),
    );

    final side = (rect.height * 0.42).clamp(2.0, rect.width);
    final inlay = Rect.fromCenter(
      center: rect.center,
      width: side,
      height: side,
    );
    canvas.drawRect(
      inlay.inflate(1.2),
      Paint()..color = _mid.withValues(alpha: opacity),
    );
    canvas.drawRect(inlay, Paint()..color = color.withValues(alpha: opacity));
  }
}
