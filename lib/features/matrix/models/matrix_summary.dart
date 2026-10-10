import '../widgets/matrix_layout.dart';
import '../widgets/pixel_matrix_grid.dart';
import 'check_in_block.dart';

/// Fill numbers derived from the same stacking the grid draws.
class MatrixSummary {
  const MatrixSummary({required this.filled, required this.tallest});

  factory MatrixSummary.of(List<CheckInBlock> blocks, DateTime today) {
    final placement = MatrixPlacement.build(
      blocks,
      MatrixCalendar(today: today),
      PixelMatrixGrid.defaultRows,
    );
    return MatrixSummary(
      filled: placement.filledCells,
      tallest: placement.tallest,
    );
  }

  static const int totalCells =
      MatrixCalendar.defaultColumns * PixelMatrixGrid.defaultRows;

  final int filled;
  final int tallest;

  /// Share of all matrix cells that hold a brick.
  int get clearedPercent => (filled * 100 / totalCells).round();

  /// Tallest column as a share of the full height.
  int get capPercent => (tallest * 100 / PixelMatrixGrid.defaultRows).round();
}
