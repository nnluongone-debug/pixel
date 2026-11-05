import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/features/habits/widgets/habit_card.dart';
import 'package:pixel_quest/features/home/home_screen.dart';
import 'package:pixel_quest/features/home/widgets/matrix_canvas_card.dart';
import 'package:pixel_quest/features/matrix/models/check_in_block.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_effects_painter.dart';
import 'package:pixel_quest/features/matrix/widgets/pixel_matrix_grid.dart';
import 'package:pixel_quest/providers/matrix_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/localized_test_app.dart';
import '../../support/silent_sound_service.dart';

/// Stands in for "a dependency changed" (what a habit mutation does), which
/// puts the provider in a reloading state while its new query runs.
final _reloadTrigger = NotifierProvider<_Trigger, int>(_Trigger.new);

class _Trigger extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

void main() {
  sqfliteFfiInit();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    '+1 keeps the page in place: no spinner, same grid, brick drops in',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (_) async => null,
      );
      late Database db;
      late ProviderContainer container;
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.runAsync(() async {
        db = await AppDatabase.open(
          factory: databaseFactoryFfiNoIsolate,
          path: inMemoryDatabasePath,
        );
        container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
            silentSoundOverride,
          ],
        );
        await container
            .read(habitRepositoryProvider)
            .createHabit(
              name: 'Drink Water',
              type: HabitType.counter,
              target: 2,
              colorHex: '#00D2FF',
              iconName: 'water_drop',
              unit: 'GL',
            );
      });
      addTearDown(() async {
        container.dispose();
        await tester.runAsync(db.close);
      });

      // DB work needs real async; PulseDot repeats, so never pumpAndSettle.
      Future<void> pumpDb({bool expectNoSpinner = false}) async {
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(
            () => Future.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 16));
          if (expectNoSpinner) {
            expect(find.byType(CircularProgressIndicator), findsNothing);
          }
        }
      }

      await tester.binding.setSurfaceSize(const Size(390, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedTestApp(home: const Scaffold(body: HomeScreen())),
        ),
      );
      await pumpDb();
      final grid = tester.state(find.byType(PixelMatrixGrid));
      final plusOne = find.text('+1');
      // The button itself bounces when tapped, so track the whole card.
      final card = find.byType(HabitCard);
      final cardTop = tester.getTopLeft(card).dy;

      // 1/2: below target, so no completion jolt — the card must not move.
      await tester.tap(plusOne);
      await pumpDb(expectNoSpinner: true);
      expect(tester.getTopLeft(card).dy, cardTop);

      // 2/2: target reached (the card's jolt animation is expected here).
      await tester.tap(plusOne);
      await pumpDb(expectNoSpinner: true);

      // Same State object: the grid was never swapped for a spinner.
      expect(tester.state(find.byType(PixelMatrixGrid)), same(grid));
      final effects = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(PixelMatrixGrid),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is MatrixEffectsPainter,
          ),
        ),
      );
      expect(
        (effects.painter! as MatrixEffectsPainter).effects,
        isNotEmpty,
        reason: 'reaching the target should drop a brick with animation',
      );
    },
  );

  testWidgets('matrix keeps the last grid while its data reloads', (
    tester,
  ) async {
    late Database db;
    await tester.runAsync(() async {
      db = await AppDatabase.open(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
    });
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var pending = Completer<List<CheckInBlock>>();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        silentSoundOverride,
        matrixBlocksProvider.overrideWith((ref) {
          ref.watch(_reloadTrigger);
          return pending.future;
        }),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await tester.runAsync(db.close);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          home: const Scaffold(
            body: SingleChildScrollView(child: MatrixCanvasCard()),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(const []);
    await tester.pump();
    final grid = tester.state(find.byType(PixelMatrixGrid));

    // A reload that hasn't finished yet must not replace the grid.
    pending = Completer();
    container.read(_reloadTrigger.notifier).bump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.state(find.byType(PixelMatrixGrid)), same(grid));
  });
}
