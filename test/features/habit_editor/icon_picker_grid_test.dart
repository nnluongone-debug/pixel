import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/core/utils/habit_icons.dart';
import 'package:pixel_quest/features/habit_editor/icon_picker_grid.dart';

import '../../support/localized_test_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, String selected) => tester.pumpWidget(
    localizedTestApp(
      home: Scaffold(
        body: SizedBox(
          width: 328, // fits 6 tiles of at least 44 + 8 gaps
          child: IconPickerGrid(
            selected: selected,
            color: Colors.green,
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );

  int tiles(WidgetTester tester) => HabitIcons.all.values
      .where((i) => find.byIcon(i).evaluate().isNotEmpty)
      .length;

  testWidgets('collapsed shows one row plus a toggle, expands to all', (
    tester,
  ) async {
    await pump(tester, 'water_drop');
    expect(tiles(tester), 5);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);

    await tester.tap(find.byTooltip('More icons'));
    await tester.pumpAndSettle();
    expect(tiles(tester), HabitIcons.all.length);

    await tester.tap(find.byTooltip('Fewer icons'));
    await tester.pumpAndSettle();
    expect(tiles(tester), 5);
  });

  testWidgets('a selected icon from later in the set stays visible', (
    tester,
  ) async {
    await pump(tester, 'phone_off');
    expect(find.byIcon(HabitIcons.of('phone_off')), findsOneWidget);
    expect(tiles(tester), 5);
  });
}
