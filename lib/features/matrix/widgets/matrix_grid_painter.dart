import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'brick_painter.dart';
import 'matrix_layout.dart';

/// Static layer: empty slots plus every settled brick. It repaints only when
/// the data changes, so blur-heavy glows are not redrawn every frame.
class MatrixGridPainter extends CustomPainter {
  MatrixGridPainter({
    required this.geometry,
    required this.calendar,
    required this.placement,
    required this.hiddenIds,
  });

  final MatrixGeometry geometry;
  final MatrixCalendar calendar;
  final MatrixPlacement placement;

  /// Bricks currently drawn by the effects layer (still falling).
  final Set<String> hiddenIds;

  @override
  void paint(Canvas canvas, Size size) {
    for (var column = 0; column < geometry.columns; column++) {
      for (var slot = 0; slot < geometry.rows; slot++) {
        BrickPainter.paintSlot(canvas, geometry.slotRect(column, slot));
      }
    }

    for (final placed in placement.visible.values) {
      if (hiddenIds.contains(placed.block.id)) continue;
      BrickPainter.paintBrick(
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
      old.placement != placement ||
      old.hiddenIds != hiddenIds ||
      old.calendar.todayDay != calendar.todayDay ||
      old.geometry.width != geometry.width;
}
