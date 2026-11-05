import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../skins/brick_skin.dart';
import 'matrix_layout.dart';

/// Third, cheap layer for animated skins (glitch jitter, gem twinkles). It
/// repaints on [time] ticks only; the static layer is untouched.
class MatrixOverlayPainter extends CustomPainter {
  MatrixOverlayPainter({
    required this.skin,
    required this.geometry,
    required this.placement,
    required this.hiddenIds,
    required ValueListenable<double> time,
  }) : _time = time,
       super(repaint: time) {
    for (final placed in placement.visible.values) {
      if (hiddenIds.contains(placed.block.id)) continue;
      _bricks.add(geometry.slotRect(placed.column, placed.slot));
      _colors.add(placed.block.color);
    }
  }

  final BrickSkin skin;
  final MatrixGeometry geometry;
  final MatrixPlacement placement;
  final Set<String> hiddenIds;
  final ValueListenable<double> _time;
  final List<Rect> _bricks = [];
  final List<Color> _colors = [];

  @override
  void paint(Canvas canvas, Size size) =>
      skin.paintOverlay(canvas, size, _bricks, _colors, _time.value);

  @override
  bool shouldRepaint(MatrixOverlayPainter old) =>
      old.skin != skin ||
      old.placement != placement ||
      old.hiddenIds != hiddenIds ||
      old.geometry.width != geometry.width;
}
