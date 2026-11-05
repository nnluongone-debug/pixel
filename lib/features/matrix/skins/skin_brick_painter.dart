import 'package:flutter/material.dart';

import 'brick_skin.dart';

/// Paints one brick (or an empty slot when [color] is null) filling the whole
/// canvas; used for small widgets such as mini progress bars.
class SkinBrickPainter extends CustomPainter {
  const SkinBrickPainter({required this.skin, this.color});

  final BrickSkin skin;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = color;
    if (c == null) {
      skin.paintSlot(canvas, rect);
    } else {
      skin.paintBrick(canvas, rect, c, glow: 0.6);
    }
  }

  @override
  bool shouldRepaint(SkinBrickPainter old) =>
      old.skin != skin || old.color != color;
}
