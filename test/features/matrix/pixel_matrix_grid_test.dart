import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/features/matrix/models/check_in_block.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_effects_painter.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_grid_painter.dart';
import 'package:pixel_quest/features/matrix/widgets/pixel_matrix_grid.dart';

import '../../support/localized_test_app.dart';

final today = DateTime(2026, 10, 10, 12);

CheckInBlock block(String id, int stack) => CheckInBlock(
  id: id,
  habitId: 'h-$id',
  dateKey: '2026-10-10',
  stackIndex: stack,
  color: const Color(0xFF00FF66),
);

Widget host(List<CheckInBlock> blocks, {Locale locale = const Locale('en')}) =>
    localizedTestApp(
      locale: locale,
      home: Scaffold(
        body: SizedBox(
          width: 370,
          child: PixelMatrixGrid(blocks: blocks, today: today),
        ),
      ),
    );

MatrixEffectsPainter effectsPainter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is MatrixEffectsPainter,
    ),
  );
  return paint.painter! as MatrixEffectsPainter;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('initial bricks render without animating', (tester) async {
    await tester.pumpWidget(host([block('a', 0)]));
    expect(effectsPainter(tester).effects, isEmpty);
    expect(find.text('NOW'), findsOneWidget);
    expect(find.text('-9D'), findsOneWidget);
    expect(find.text('YST'), findsOneWidget);
  });

  testWidgets('day labels render in Vietnamese', (tester) async {
    await tester.pumpWidget(host([], locale: const Locale('vi')));
    expect(find.text('NAY'), findsOneWidget);
    expect(find.text('HQ'), findsOneWidget);
    expect(find.text('-9N'), findsOneWidget);
  });

  testWidgets('a new brick drops in, then settles into the static layer', (
    tester,
  ) async {
    await tester.pumpWidget(host([block('a', 0)]));
    await tester.pumpWidget(host([block('a', 0), block('b', 1)]));

    expect(effectsPainter(tester).effects.single.id, 'b');
    await tester.pump(const Duration(milliseconds: 300)); // mid-fall
    await tester.pump(const Duration(milliseconds: 400)); // sparkles
    await tester.pumpAndSettle();

    expect(effectsPainter(tester).effects, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing a falling brick cancels its effect', (tester) async {
    await tester.pumpWidget(host([]));
    await tester.pumpWidget(host([block('a', 0), block('b', 1)]));
    expect(effectsPainter(tester).effects.length, 2);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(host([block('a', 0)]));
    expect(effectsPainter(tester).effects.single.id, 'a');

    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox()); // dispose with no live tickers
    expect(tester.takeException(), isNull);
  });

  testWidgets('drop animation does not repaint the static layer', (
    tester,
  ) async {
    await tester.pumpWidget(host([block('a', 0)]));
    await tester.pumpWidget(host([block('a', 0), block('b', 1)]));
    await tester.pump(const Duration(milliseconds: 50));
    final before = MatrixGridPainter.paintCount;

    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50)); // fall + settle
    }
    expect(effectsPainter(tester).effects, isNotEmpty);
    expect(MatrixGridPainter.paintCount, before);
    await tester.pumpAndSettle();
  });

  testWidgets('growing rows keeps the grid State and its drop effects', (
    tester,
  ) async {
    Widget rowsHost(int rows, List<CheckInBlock> blocks) => localizedTestApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 370,
            child: PixelMatrixGrid(blocks: blocks, rows: rows, today: today),
          ),
        ),
      ),
    );

    await tester.pumpWidget(rowsHost(10, [block('a', 0)]));
    final state = tester.state(find.byType(PixelMatrixGrid));
    final before = tester.getSize(find.byType(PixelMatrixGrid)).height;

    await tester.pumpWidget(rowsHost(12, [block('a', 0), block('b', 1)]));
    expect(tester.state(find.byType(PixelMatrixGrid)), same(state));
    expect(
      tester.getSize(find.byType(PixelMatrixGrid)).height,
      greaterThan(before),
    );
    expect(effectsPainter(tester).effects.single.id, 'b');
    await tester.pumpAndSettle();
  });
}
