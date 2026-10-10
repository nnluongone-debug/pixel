import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import 'matrix_layout.dart';

/// "-9D … YST NOW" row aligned to the grid columns; NOW glows mint.
class DayLabelRow extends StatelessWidget {
  const DayLabelRow({
    super.key,
    required this.geometry,
    required this.calendar,
  });

  final MatrixGeometry geometry;
  final MatrixCalendar calendar;

  /// "-9D" … "-2D", "YST", "NOW" in the current language.
  static String _label(BuildContext context, int back) => switch (back) {
    0 => context.l10n.gridDayNow,
    1 => context.l10n.gridDayYesterday,
    _ => context.l10n.gridDayAgo(back),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: geometry.width,
      child: Row(
        children: [
          for (var column = 0; column < calendar.columns; column++) ...[
            if (column > 0) SizedBox(width: geometry.cellGap),
            SizedBox(
              width: geometry.cellWidth,
              child: Text(
                _label(context, calendar.daysBack(column)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 8,
                  color: calendar.isToday(column)
                      ? AppColors.primary
                      : AppColors.textMuted,
                  fontWeight: calendar.isToday(column)
                      ? FontWeight.w800
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
