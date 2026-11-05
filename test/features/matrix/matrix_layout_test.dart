import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/features/matrix/models/check_in_block.dart';
import 'package:pixel_quest/features/matrix/models/matrix_summary.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_layout.dart';
import 'package:pixel_quest/features/matrix/widgets/pixel_matrix_grid.dart';

CheckInBlock block(String id, String date, int stack) => CheckInBlock(
  id: id,
  habitId: 'h-$id',
  dateKey: date,
  stackIndex: stack,
  color: const Color(0xFF00E5FF),
);

void main() {
  final today = DateTime(2026, 10, 10, 15);
  final calendar = MatrixCalendar(today: today);

  test('calendar spans 10 rolling days ending today', () {
    expect(calendar.firstKey, '2026-10-01');
    expect(calendar.lastKey, '2026-10-10');
    expect(calendar.todayColumn, 9);
    expect(calendar.columnOf('2026-10-01'), 0);
    expect(calendar.columnOf('2026-10-10'), 9);
    expect(calendar.columnOf('2026-09-30'), isNull);
    expect(calendar.columnOf('2026-10-11'), isNull);
  });

  test('daysBack counts from today', () {
    expect(
      [for (var c = 0; c < 10; c++) calendar.daysBack(c)],
      [
        9, 8, 7, 6, 5, 4, 3, 2, 1, 0, //
      ],
    );
  });

  test('bricks stack bottom-up per day, closing gaps in stack order', () {
    final placement = MatrixPlacement.build(
      [
        block('c', '2026-10-10', 7),
        block('a', '2026-10-10', 0),
        block('b', '2026-10-10', 3),
        block('x', '2026-10-05', 0),
      ],
      calendar,
      18,
    );
    expect(placement.visible['a']!.slot, 0);
    expect(placement.visible['b']!.slot, 1);
    expect(placement.visible['c']!.slot, 2);
    expect(placement.visible['x']!.column, 4);
    expect(placement.filledCells, 4);
    expect(placement.tallest, 3);
  });

  test('bricks beyond the row count become an overflow badge', () {
    final placement = MatrixPlacement.build(
      [for (var i = 0; i < 20; i++) block('$i', '2026-10-10', i)],
      calendar,
      18,
    );
    expect(placement.visible.length, 18);
    expect(placement.overflow[9], 2);
    expect(placement.tallest, 18);
  });

  test('geometry stacks slot 0 at the bottom of the 18-row grid', () {
    final g = MatrixGeometry(width: 300, columns: 10, rows: 18);
    final bottom = g.slotRect(0, 0);
    final top = g.slotRect(0, 17);
    expect(top.top, 0);
    expect(bottom.bottom, closeTo(g.height, 0.001));
    expect(g.columnLeft(9) + g.cellWidth, closeTo(300, 0.001));
  });

  test('cells are square', () {
    final g = MatrixGeometry(width: 370, columns: 10, rows: 12);
    expect(g.cellHeight, g.cellWidth);
    expect(g.height, closeTo(12 * g.cellWidth + 11 * g.cellGap, 0.001));
  });

  test('rows follow the habit count with a floor of 10', () {
    List<CheckInBlock> day(String date, int n) => [
      for (var i = 0; i < n; i++) block('$date-$i', date, i),
    ];
    expect(PixelMatrixGrid.rowsFor(const []), 10);
    expect(PixelMatrixGrid.rowsFor(day('2026-10-10', 7)), 10);
    expect(PixelMatrixGrid.rowsFor(day('2026-10-10', 10)), 10);
    // Grows only with checked-off bricks on one day, not with total bricks.
    expect(
      PixelMatrixGrid.rowsFor([
        ...day('2026-10-09', 9),
        ...day('2026-10-10', 9),
      ]),
      10,
    );
    expect(PixelMatrixGrid.rowsFor(day('2026-10-10', 12)), 12);
  });

  test('summary scales with the row count', () {
    final blocks = [for (var i = 0; i < 6; i++) block('t$i', '2026-10-10', i)];
    final summary = MatrixSummary.of(blocks, today, rows: 12);
    expect(summary.totalCells, 120);
    expect(summary.clearedPercent, 5); // 6 / 120
    expect(summary.capPercent, 50); // 6 / 12
  });

  test('summary reports filled share of 100 cells and tallest column', () {
    final blocks = [
      for (var i = 0; i < 9; i++) block('t$i', '2026-10-10', i),
      block('y', '2026-10-09', 0),
    ];
    final summary = MatrixSummary.of(blocks, today);
    expect(summary.filled, 10);
    expect(summary.clearedPercent, 10); // 10 / 100
    expect(summary.tallest, 9);
    expect(summary.capPercent, 90); // 9 / 10
  });
}
