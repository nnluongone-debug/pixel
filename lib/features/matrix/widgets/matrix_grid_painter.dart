import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../skins/brick_skin.dart';
import 'matrix_layout.dart';

/// Static layer: empty slots plus every settled brick. It repaints only when
/// the data changes, so blur-heavy glows are not redrawn every frame.
class MatrixGridPainter extends CustomPainter {
  MatrixGridPainter({
    required this.skin,
    required this.geometry,
    required this.calendar,
    required this.placement,
    required this.hiddenIds,
  });

  final BrickSkin skin;
  final MatrixGeometry geometry;
  final MatrixCalendar calendar;
  final MatrixPlacement placement;

  /// Bricks currently drawn by the effects layer (still falling).
  final Set<String> hiddenIds;

  /// Number of static-layer paints; lets tests prove drop animations do not
  /// repaint this layer.
  @visibleForTesting
  static int paintCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    paintCount++;
    for (var column = 0; column < geometry.columns; column++) {
      for (var slot = 0; slot < geometry.rows; slot++) {
        skin.paintSlot(canvas, geometry.slotRect(column, slot));
      }
    }

    for (final placed in placement.visible.values) {
      if (hiddenIds.contains(placed.block.id)) continue;
      skin.paintBrick(
        canvas,
        geometry.slotRect(placed.column, placed.slot),
        placed.block.color,
      );
    }

    placement.overflow.forEach((column, count) {
      _paintOverflowBadge(canvas, column, count);
    });
  }

  /// "+N" tag over the top brick when a day has more bricks than rows.
  void _paintOverflowBadge(Canvas canvas, int column, int count) {
    final top = geometry.slotRect(column, geometry.rows - 1);
    final painter = TextPainter(
      text: TextSpan(
        text: '+$count',
        style: AppTextStyles.labelSm.copyWith(
          fontSize: 8,
          color: AppColors.textOnNeon,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      top.center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(MatrixGridPainter old) =>
      old.skin != skin ||
      old.placement != placement ||
      old.hiddenIds != hiddenIds ||
      old.calendar.todayDay != calendar.todayDay ||
      old.geometry.width != geometry.width;
}
