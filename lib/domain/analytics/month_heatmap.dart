import '../../core/utils/date_key_utils.dart';
import 'history_index.dart';

/// One calendar cell of the activity matrix.
class HeatCell {
  const HeatCell({
    required this.date,
    required this.tally,
    required this.inMonth,
    required this.isToday,
    required this.isFuture,
  });

  final DateTime date;
  final DayTally tally;

  /// False for the padding days of the adjacent months.
  final bool inMonth;
  final bool isToday;
  final bool isFuture;

  /// 0 = nothing completed (or nothing due), 4 = every due habit completed.
  int get level {
    final ratio = tally.ratio;
    if (isFuture || ratio == null || tally.done == 0) return 0;
    if (ratio >= 1) return 4;
    if (ratio >= 0.75) return 3;
    if (ratio >= 0.5) return 2;
    return 1;
  }
}

/// Monday-first month grid with its efficiency figures.
class MonthHeatmap {
  const MonthHeatmap({
    required this.year,
    required this.month,
    required this.cells,
    required this.rate,
    required this.perfectDays,
  });

  final int year;
  final int month;

  /// Whole weeks, 7 cells per row.
  final List<HeatCell> cells;

  /// Completed vs due habit-days from the 1st through today (or month end).
  final DayTally rate;
  final int perfectDays;

  factory MonthHeatmap.build({
    required HistoryIndex index,
    required int year,
    required int month,
    required int today,
  }) {
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    final gridStart = DateTime(year, month, 1 - (first.weekday - 1));
    final gridEnd = DateTime(year, month, last.day + (7 - last.weekday));
    final span = gridEnd.difference(gridStart).inHours ~/ 24 + 1;

    final cells = <HeatCell>[];
    for (var i = 0; i < span; i++) {
      final date = DateTime(gridStart.year, gridStart.month, gridStart.day + i);
      final day = DateKeys.epochDay(date);
      cells.add(
        HeatCell(
          date: date,
          tally: index.tally(day),
          inMonth: date.month == month,
          isToday: day == today,
          isFuture: day > today,
        ),
      );
    }

    final monthStart = DateKeys.epochDay(first);
    final monthEnd = DateKeys.epochDay(last);
    final rangeEnd = monthEnd < today ? monthEnd : today;
    return MonthHeatmap(
      year: year,
      month: month,
      cells: cells,
      rate: rangeEnd < monthStart
          ? const DayTally(0, 0)
          : index.tallyRange(monthStart, rangeEnd),
      perfectDays: rangeEnd < monthStart
          ? 0
          : index.perfectDays(monthStart, rangeEnd),
    );
  }
}
