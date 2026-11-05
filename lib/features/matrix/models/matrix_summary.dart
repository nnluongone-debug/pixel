import '../widgets/matrix_layout.dart';
import '../widgets/pixel_matrix_grid.dart';
import 'check_in_block.dart';

/// Fill numbers derived from the same stacking the grid draws.
class MatrixSummary {
  const MatrixSummary({
    required this.filled,
    required this.tallest,
    required this.rows,
  });

  factory MatrixSummary.of(
    List<CheckInBlock> blocks,
    DateTime today, {
    int rows = PixelMatrixGrid.minRows,
  }) {
    final placement = MatrixPlacement.build(
      blocks,
      MatrixCalendar(today: today),
      rows,
    );
    return MatrixSummary(
      filled: placement.filledCells,
      tallest: placement.tallest,
      rows: rows,
    );
  }

  final int filled;
  final int tallest;

  /// Grid height in rows.
  final int rows;

  int get totalCells => MatrixCalendar.defaultColumns * rows;

  /// Share of all matrix cells that hold a brick.
  int get clearedPercent => (filled * 100 / totalCells).round();

  /// Tallest column as a share of the full height.
  int get capPercent => (tallest * 100 / rows).round();
}
