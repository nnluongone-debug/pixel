import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/core/theme/app_theme.dart';
import 'package:pixel_quest/domain/cosmetics/theme_catalog.dart';
import 'package:pixel_quest/features/matrix/models/check_in_block.dart';
import 'package:pixel_quest/features/matrix/skins/brick_skin.dart';
import 'package:pixel_quest/features/matrix/skins/cyberpunk_glitch_skin.dart';
import 'package:pixel_quest/features/matrix/skins/game_boy_skin.dart';
import 'package:pixel_quest/features/matrix/skins/gemstone_skin.dart';
import 'package:pixel_quest/features/matrix/skins/nebula_skin.dart';
import 'package:pixel_quest/features/matrix/skins/neon_glow_skin.dart';
import 'package:pixel_quest/features/matrix/skins/pure_gold_skin.dart';
import 'package:pixel_quest/features/matrix/widgets/matrix_overlay_painter.dart';
import 'package:pixel_quest/features/matrix/widgets/pixel_matrix_grid.dart';

import '../../support/localized_test_app.dart';

/// The pre-skin `BrickPainter` logic, frozen as the reference Neon must match.
class _LegacyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(10, 10, 30, 19);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    final slot = RRect.fromRectAndRadius(
      rect.shift(const Offset(40, 0)).deflate(0.5),
      const Radius.circular(2),
    );
    canvas.drawRRect(slot, Paint()..color = AppColors.matrixSlotFill);
    canvas.drawRRect(
      slot,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.matrixSlotBorder,
    );
    for (final glow in [1.0, 0.0, 2.2]) {
      final r = rrect.shift(Offset(0, 25.0 * (1 + glow.floor())));
      if (glow > 0) {
        canvas.drawRRect(
          r,
          Paint()
            ..color = AppColors.mint.withValues(
              alpha: (0.7 * glow).clamp(0.0, 1.0),
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 2 * glow),
        );
      }
      canvas.drawRRect(r, Paint()..color = AppColors.mint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SkinPainter extends CustomPainter {
  _SkinPainter(this.skin);
  final BrickSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(10, 10, 30, 19);
    skin.paintSlot(canvas, rect.shift(const Offset(40, 0)));
    for (final glow in [1.0, 0.0, 2.2]) {
      skin.paintBrick(
        canvas,
        rect.shift(Offset(0, 25.0 * (1 + glow.floor()))),
        AppColors.mint,
        glow: glow,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

Future<List<int>> _render(WidgetTester tester, CustomPainter painter) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: CustomPaint(size: const Size(100, 120), painter: painter),
        ),
      ),
    ),
  );
  return (await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List().toList();
  }))!;
}

Widget _grid(BrickSkin skin, {bool disableAnimations = false}) =>
    localizedTestApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: SizedBox(
            width: 370,
            child: PixelMatrixGrid(
              skin: skin,
              today: DateTime(2026, 10, 10, 12),
              blocks: const [
                CheckInBlock(
                  id: 'a',
                  habitId: 'h',
                  dateKey: '2026-10-10',
                  stackIndex: 0,
                  color: Color(0xFF00FF66),
                ),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('BrickSkin.of covers every skin id', () {
    expect(BrickSkin.of(ThemeId.neonGlow), isA<NeonGlowSkin>());
    expect(BrickSkin.of(ThemeId.gameBoy), isA<GameBoySkin>());
    expect(BrickSkin.of(ThemeId.cyberpunk), isA<CyberpunkGlitchSkin>());
    expect(BrickSkin.of(ThemeId.gemstone), isA<GemstoneSkin>());
    expect(BrickSkin.of(ThemeId.pureGold), isA<PureGoldSkin>());
    expect(BrickSkin.of(ThemeId.nebula), isA<NebulaSkin>());
    for (final id in ThemeId.values) {
      expect(() => BrickSkin.of(id), returnsNormally);
    }
  });

  test('only glitch, gemstone and nebula are animated', () {
    expect(const NeonGlowSkin().animated, isFalse);
    expect(const GameBoySkin().animated, isFalse);
    expect(const PureGoldSkin().animated, isFalse);
    expect(const CyberpunkGlitchSkin().animated, isTrue);
    expect(const GemstoneSkin().animated, isTrue);
    expect(const NebulaSkin().animated, isTrue);
  });

  test('Game Boy maps colors into the four LCD greens', () {
    final shades = {
      for (final c in [...AppColors.habitPalette, Colors.black, Colors.white])
        GameBoySkin.shadeFor(c),
    };
    expect(shades.length, greaterThan(2));
    expect(
      shades,
      everyElement(
        isIn(const [
          GameBoySkin.darkest,
          GameBoySkin.dark,
          GameBoySkin.light,
          GameBoySkin.lightest,
        ]),
      ),
    );
  });

  testWidgets('Neon skin renders identically to the legacy painter', (
    tester,
  ) async {
    final legacy = await _render(tester, _LegacyPainter());
    final neon = await _render(tester, _SkinPainter(const NeonGlowSkin()));
    expect(neon, legacy);
  });

  testWidgets('other skins differ from Neon', (tester) async {
    final neon = await _render(tester, _SkinPainter(const NeonGlowSkin()));
    for (final id in [
      ThemeId.gameBoy,
      ThemeId.cyberpunk,
      ThemeId.gemstone,
      ThemeId.pureGold,
      ThemeId.nebula,
    ]) {
      final out = await _render(tester, _SkinPainter(BrickSkin.of(id)));
      expect(out, isNot(neon), reason: '$id');
    }
  });

  testWidgets('grid keeps its State across a skin change', (tester) async {
    await tester.pumpWidget(_grid(const NeonGlowSkin()));
    final before = tester.state(find.byType(PixelMatrixGrid));
    await tester.pumpWidget(_grid(const GemstoneSkin()));
    expect(tester.state(find.byType(PixelMatrixGrid)), same(before));
    await tester.pumpWidget(_grid(const GameBoySkin()));
    expect(tester.state(find.byType(PixelMatrixGrid)), same(before));
  });

  testWidgets('overlay layer exists only for animated skins', (tester) async {
    Finder overlay() => find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is MatrixOverlayPainter,
    );
    await tester.pumpWidget(_grid(const NeonGlowSkin()));
    expect(overlay(), findsNothing);

    await tester.pumpWidget(_grid(const CyberpunkGlitchSkin()));
    expect(overlay(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_grid(const NeonGlowSkin()));
    expect(overlay(), findsNothing);
  });

  testWidgets('reduce motion disables the overlay ticker', (tester) async {
    await tester.pumpWidget(
      _grid(const GemstoneSkin(), disableAnimations: true),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MatrixOverlayPainter,
      ),
      findsNothing,
    );
  });

  test('glitch skin sleeps between glitches, gemstone stays at ~24 fps', () {
    const glitch = CyberpunkGlitchSkin();
    expect(glitch.overlayFrameDelay(0.01).inMilliseconds, lessThan(60));
    expect(glitch.overlayFrameDelay(0.2).inMilliseconds, greaterThan(2500));
    expect(const GemstoneSkin().overlayFrameDelay(5).inMilliseconds, 41);
  });

  testWidgets('overlay frames are not requested while the glitch sleeps', (
    tester,
  ) async {
    await tester.pumpWidget(_grid(const CyberpunkGlitchSkin()));
    // Past the first glitch window; the clock is now asleep until ~3.2 s.
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('offstage grid stops the overlay clock', (tester) async {
    Widget tabbed(bool enabled) =>
        TickerMode(enabled: enabled, child: _grid(const GemstoneSkin()));
    await tester.pumpWidget(tabbed(false));
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MatrixOverlayPainter,
      ),
      findsNothing,
    );
    await tester.pumpWidget(tabbed(true));
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MatrixOverlayPainter,
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
