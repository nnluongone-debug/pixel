import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_links.dart';
import '../../../core/l10n/l10n.dart';
import '../../../providers/growth_providers.dart';
import 'matrix_share_poster.dart';

/// Captures the matrix behind [boundaryKey], frames it as a poster and
/// opens the system share sheet with a Play Store link.
abstract final class MatrixShareAction {
  /// Target width of the captured grid in pixels (story-friendly).
  static const _targetWidth = 1080.0;

  static Future<void> share({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey boundaryKey,
    required int clearedPercent,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final analytics = ref.read(usageAnalyticsProvider);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final date = DateFormat.yMMMd(context.localeTag).format(DateTime.now());
    try {
      // Capture after the current frame so an in-flight repaint (brick
      // drop) can't trip the "needs paint" check.
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) {
        throw StateError('Matrix is not laid out');
      }
      final ratio = (_targetWidth / boundary.size.width).clamp(1.0, 4.0);
      final grid = await boundary.toImage(pixelRatio: ratio);
      final png = await () async {
        try {
          return await composeMatrixPoster(
            grid: grid,
            texts: MatrixPosterTexts(
              title: l10n.shareMatrixTitle,
              subtitle: l10n.shareMatrixSubtitle(clearedPercent, date),
              brand: l10n.appTitle,
              tagline: l10n.shareMatrixTagline,
            ),
          );
        } finally {
          grid.dispose();
        }
      }();
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              png,
              mimeType: 'image/png',
              name: 'pixel-habit-matrix.png',
            ),
          ],
          text: l10n.shareMatrixText(AppLinks.playStoreShareUrl),
          sharePositionOrigin: origin,
        ),
      );
      if (result.status != ShareResultStatus.dismissed) {
        await analytics.matrixShared();
      }
    } catch (e) {
      debugPrint('Sharing matrix failed: $e');
      messenger?.showSnackBar(SnackBar(content: Text(l10n.shareMatrixError)));
    }
  }
}
