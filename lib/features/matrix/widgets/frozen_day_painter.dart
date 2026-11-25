import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'matrix_layout.dart';

/// Ice tile at the base of each empty column whose day was saved by a streak
/// freeze: translucent cyan with a snowflake glyph.
class FrozenDayPainter extends CustomPainter {
  FrozenDayPainter({
    required this.geometry,
    required this.calendar,
    required this.placement,
    required this.frozenDays,
  });

  final MatrixGeometry geometry;
  final MatrixCalendar calendar;
  final MatrixPlacement placement;

  /// Epoch days on which a freeze was spent.
  final Set<int> frozenDays;

  /// Visible columns that get an ice tile: frozen and still empty.
  List<int> get columns => [
    for (final day in frozenDays)
      if (day >= calendar.firstDay &&
          day <= calendar.todayDay &&
          placement.columnHeights[day - calendar.firstDay] == 0)
        day - calendar.firstDay,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final column in columns) {
      final rect = geometry.slotRect(column, 0);
      final tile = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas.drawRRect(
        tile,
        Paint()..color = AppColors.cyan.withValues(alpha: 0.28),
      );
      canvas.drawRRect(
        tile,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.cyan.withValues(alpha: 0.8),
      );
      final glyph = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.ac_unit.codePoint),
          style: TextStyle(
            fontFamily: Icons.ac_unit.fontFamily,
            package: Icons.ac_unit.fontPackage,
            fontSize: rect.width * 0.6,
            color: AppColors.cyan,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      glyph.paint(
        canvas,
        rect.center - Offset(glyph.width / 2, glyph.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(FrozenDayPainter old) =>
      old.placement != placement ||
      old.frozenDays != frozenDays ||
      old.calendar.todayDay != calendar.todayDay ||
      old.geometry.width != geometry.width;
}
