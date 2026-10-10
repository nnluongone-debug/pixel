import 'dart:math';
import 'dart:ui';

import '../../../core/utils/date_key_utils.dart';
import '../models/check_in_block.dart';

/// Maps dates to the rolling day columns: [columns] days ending today, the
/// oldest on the left and today in the last column.
class MatrixCalendar {
  MatrixCalendar({required DateTime today, this.columns = defaultColumns})
    : todayDay = DateKeys.epochDay(today),
      firstDay = DateKeys.epochDay(today) - (columns - 1);

  static const int defaultColumns = 10;

  final int columns;
  final int todayDay;

  /// Epoch day of the leftmost column.
  final int firstDay;

  String get firstKey => _keyOf(firstDay);
  String get lastKey => _keyOf(todayDay);

  int get todayColumn => columns - 1;

  /// Column of [dateKey], or null when outside the window.
  int? columnOf(String dateKey) {
    final offset = DateKeys.epochDayOfKey(dateKey) - firstDay;
    return offset < 0 || offset >= columns ? null : offset;
  }

  bool isToday(int column) => column == todayColumn;

  /// Days between [column] and today (0 = today).
  int daysBack(int column) => todayColumn - column;

  static String _keyOf(int epochDay) => DateKeys.fromDate(
    DateTime.fromMillisecondsSinceEpoch(epochDay * 86400000, isUtc: true),
  );
}

/// Pixel geometry for the grid area (labels excluded).
class MatrixGeometry {
  MatrixGeometry({
    required this.width,
    required this.columns,
    required this.rows,
    this.cellGap = 4,
    this.brickAspect = 0.62,
  }) : cellWidth = (width - cellGap * (columns - 1)) / columns {
    cellHeight = cellWidth * brickAspect;
    height = rows * cellHeight + (rows - 1) * cellGap;
  }

  final double width;
  final int columns;
  final int rows;
  final double cellGap;
  final double brickAspect;
  final double cellWidth;
  late final double cellHeight;
  late final double height;

  double columnLeft(int column) => column * (cellWidth + cellGap);

  /// Slot 0 is the bottom row; higher slots stack upward.
  Rect slotRect(int column, int slot) => Rect.fromLTWH(
    columnLeft(column),
    (rows - 1 - slot) * (cellHeight + cellGap),
    cellWidth,
    cellHeight,
  );
}

/// A brick resolved to its day column and slot.
class PlacedBlock {
  const PlacedBlock(this.block, this.column, this.slot);

  final CheckInBlock block;
  final int column;
  final int slot;
}

/// Result of stacking all bricks into their day columns.
class MatrixPlacement {
  MatrixPlacement._(this.visible, this.overflow, this.columnHeights);

  /// Assigns each brick a slot from the bottom up, per day, in stacking
  /// order. Bricks beyond [rows] are counted in [overflow] instead.
  factory MatrixPlacement.build(
    List<CheckInBlock> blocks,
    MatrixCalendar calendar,
    int rows,
  ) {
    final byColumn = <int, List<CheckInBlock>>{};
    for (final block in blocks) {
      final column = calendar.columnOf(block.dateKey);
      if (column == null) continue;
      byColumn.putIfAbsent(column, () => []).add(block);
    }

    final visible = <String, PlacedBlock>{};
    final overflow = <int, int>{};
    final heights = List.filled(calendar.columns, 0);
    byColumn.forEach((column, list) {
      list.sort((a, b) {
        final byStack = a.stackIndex.compareTo(b.stackIndex);
        return byStack != 0 ? byStack : a.id.compareTo(b.id);
      });
      heights[column] = min(list.length, rows);
      for (var slot = 0; slot < list.length; slot++) {
        if (slot >= rows) {
          overflow[column] = list.length - rows;
          break;
        }
        visible[list[slot].id] = PlacedBlock(list[slot], column, slot);
      }
    });
    return MatrixPlacement._(visible, overflow, heights);
  }

  /// Visible bricks by block id.
  final Map<String, PlacedBlock> visible;

  /// Hidden brick count per column when a day exceeds its rows.
  final Map<int, int> overflow;

  /// Visible brick count per column.
  final List<int> columnHeights;

  int get filledCells => visible.length;

  int get tallest => columnHeights.fold(0, max);
}
