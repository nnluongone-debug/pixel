import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Retro progress bar made of equal pixel segments.
class SegmentedBar extends StatelessWidget {
  const SegmentedBar({
    super.key,
    required this.ratio,
    required this.color,
    this.segments = 20,
  });

  final double ratio;
  final Color color;
  final int segments;

  /// Segments lit for [ratio]; any progress lights at least one.
  static int litSegments(double ratio, int segments) =>
      ratio <= 0 ? 0 : (ratio * segments).round().clamp(1, segments);

  @override
  Widget build(BuildContext context) {
    final lit = litSegments(ratio, segments);
    return Row(
      children: [
        for (var i = 0; i < segments; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: EdgeInsets.only(right: i == segments - 1 ? 0 : 2),
              decoration: BoxDecoration(
                color: i < lit ? color : AppColors.cellEmpty,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
      ],
    );
  }
}
