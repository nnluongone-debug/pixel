import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/features/home/share/matrix_share_poster.dart';

void main() {
  testWidgets('frames the grid into a larger PNG poster', (tester) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 400, 300),
        Paint()..color = Colors.green,
      );
      final grid = await recorder.endRecording().toImage(400, 300);

      final png = await composeMatrixPoster(
        grid: grid,
        texts: const MatrixPosterTexts(
          title: 'MY HABIT MATRIX',
          subtitle: '42% cleared · Nov 22, 2026',
          brand: 'Habit Tracker - Pixel',
          tagline: 'Free on Google Play',
        ),
      );

      // PNG signature.
      expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      final codec = await ui.instantiateImageCodec(png);
      final poster = (await codec.getNextFrame()).image;
      expect(poster.width, greaterThan(grid.width));
      expect(poster.height, greaterThan(grid.height));
    });
  });
}
