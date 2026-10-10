import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/features/matrix/models/check_in_block.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_effects_painter.dart';
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
    find.descendant(
      of: find.byType(PixelMatrixGrid),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.foregroundPainter! as MatrixEffectsPainter;
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
}
