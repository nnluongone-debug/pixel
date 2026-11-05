import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Small pixel-brick illustration for an intro page. [filledRows] full rows
/// sit at the bottom; [extra] bricks lead the next row.
class OnboardingBrickArt extends StatelessWidget {
  const OnboardingBrickArt({
    super.key,
    required this.icon,
    required this.color,
    this.filledRows = 1,
    this.extra = 3,
  });

  final IconData icon;
  final Color color;
  final int filledRows;
  final int extra;

  static const _columns = 6;
  static const _rows = 4;
  static const _cell = 26.0;
  static const _gap = 4.0;

  Color _cellColor(int row, int col) {
    final fromBottom = _rows - 1 - row;
    if (fromBottom < filledRows) {
      return AppColors.habitPalette[(row + col) %
          AppColors.habitPalette.length];
    }
    if (fromBottom == filledRows && col < extra) return color;
    return AppColors.cellEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceRaised,
            border: Border.all(color: color.withValues(alpha: 0.6)),
            boxShadow: AppGlow.soft(color),
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 28),
        for (var row = 0; row < _rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: _gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 0; col < _columns; col++)
                  Container(
                    width: _cell,
                    height: _cell,
                    margin: const EdgeInsets.symmetric(horizontal: _gap / 2),
                    decoration: BoxDecoration(
                      color: _cellColor(row, col),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
