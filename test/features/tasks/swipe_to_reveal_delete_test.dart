import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/features/tasks/swipe_to_reveal_delete.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<List<String>> pump(WidgetTester tester) async {
    final log = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: SwipeToRevealDelete(
              label: 'Delete',
              onDelete: () async => log.add('delete'),
              child: ListTile(
                title: const Text('Row'),
                onTap: () => log.add('tap'),
              ),
            ),
          ),
        ),
      ),
    );
    return log;
  }

  double rowLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byType(ListTile)).dx;

  testWidgets('short swipe reveals the button; tapping it deletes', (
    tester,
  ) async {
    final log = await pump(tester);
    await tester.drag(find.text('Row'), const Offset(-70, 0));
    await tester.pumpAndSettle();
    expect(rowLeft(tester), closeTo(-88, 0.5));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(log, ['delete']);
    expect(rowLeft(tester), 0);
  });

  testWidgets('tapping the open row closes it without its action', (
    tester,
  ) async {
    final log = await pump(tester);
    await tester.drag(find.text('Row'), const Offset(-70, 0));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(40, 28));
    await tester.pumpAndSettle();
    expect(log, isEmpty);
    expect(rowLeft(tester), 0);

    await tester.tap(find.text('Row'));
    expect(log, ['tap']);
  });

  testWidgets('tiny swipe snaps back closed', (tester) async {
    await pump(tester);
    await tester.drag(find.text('Row'), const Offset(-20, 0));
    await tester.pumpAndSettle();
    expect(rowLeft(tester), 0);
  });

  testWidgets('full swipe deletes straight away', (tester) async {
    final log = await pump(tester);
    await tester.drag(find.text('Row'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(log, ['delete']);
    expect(rowLeft(tester), 0);
  });
}
