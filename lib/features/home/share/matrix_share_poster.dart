import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../core/theme/app_theme.dart';

/// Texts printed around the matrix on the shared image.
class MatrixPosterTexts {
  const MatrixPosterTexts({
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.tagline,
  });

  final String title;
  final String subtitle;
  final String brand;
  final String tagline;
}

/// Frames a captured matrix [grid] into a branded PNG: title on top, the
/// grid in the middle, app name and tagline at the bottom. Sizes scale with
/// the grid width so the poster looks the same at any capture resolution.
Future<Uint8List> composeMatrixPoster({
  required ui.Image grid,
  required MatrixPosterTexts texts,
}) async {
  final w = grid.width.toDouble();
  final pad = w * 0.07;
  final gap = w * 0.03;
  final width = w + pad * 2;
  final fontFamily = AppTextStyles.headlineSm.fontFamily;

  ui.Paragraph text(String value, double size, Color color, FontWeight wt) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontFamily: fontFamily,
              fontSize: size,
              fontWeight: wt,
              maxLines: 2,
              ellipsis: '…',
            ),
          )
          ..pushStyle(ui.TextStyle(color: color, letterSpacing: size * 0.04))
          ..addText(value);
    return builder.build()..layout(ui.ParagraphConstraints(width: w));
  }

  final title = text(texts.title, w * 0.06, AppColors.primary, FontWeight.w800);
  final subtitle = text(
    texts.subtitle,
    w * 0.036,
    AppColors.cyan,
    FontWeight.w600,
  );
  final brand = text(
    texts.brand,
    w * 0.042,
    AppColors.textPrimary,
    FontWeight.w800,
  );
  final tagline = text(
    texts.tagline,
    w * 0.03,
    AppColors.textMuted,
    FontWeight.w500,
  );

  final height =
      pad +
      title.height +
      gap * 0.4 +
      subtitle.height +
      gap * 1.5 +
      grid.height +
      gap * 1.5 +
      brand.height +
      gap * 0.3 +
      tagline.height +
      pad;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = AppColors.surfaceLowest,
  );
  _drawCornerPixels(canvas, Size(width, height), pad * 0.35, w * 0.014);

  var y = pad;
  canvas.drawParagraph(title, Offset(pad, y));
  y += title.height + gap * 0.4;
  canvas.drawParagraph(subtitle, Offset(pad, y));
  y += subtitle.height + gap * 1.5;
  canvas.drawImage(grid, Offset(pad, y), Paint());
  y += grid.height + gap * 1.5;
  canvas.drawParagraph(brand, Offset(pad, y));
  y += brand.height + gap * 0.3;
  canvas.drawParagraph(tagline, Offset(pad, y));

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.round(), height.round());
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('PNG encoding returned no data');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
    for (final p in [title, subtitle, brand, tagline]) {
      p.dispose();
    }
  }
}

/// The card's signature neon pixels, one per corner.
void _drawCornerPixels(Canvas canvas, Size size, double inset, double side) {
  const colors = [
    AppColors.mint,
    AppColors.cyan,
    AppColors.lavender,
    AppColors.mint,
  ];
  final spots = [
    Offset(inset, inset),
    Offset(size.width - inset - side, inset),
    Offset(inset, size.height - inset - side),
    Offset(size.width - inset - side, size.height - inset - side),
  ];
  for (var i = 0; i < spots.length; i++) {
    final rect = spots[i] & Size(side, side);
    canvas.drawRect(
      rect.inflate(side * 0.6),
      Paint()
        ..color = colors[i].withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side),
    );
    canvas.drawRect(rect, Paint()..color = colors[i]);
  }
}
