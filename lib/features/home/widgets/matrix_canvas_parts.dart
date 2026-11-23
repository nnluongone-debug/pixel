import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../matrix/models/matrix_summary.dart';
import 'pulse_dot.dart';

/// Title bar of the matrix card: grid size, cleared %, live dot and share.
class MatrixCanvasHeader extends StatelessWidget {
  const MatrixCanvasHeader({
    super.key,
    required this.rows,
    required this.clearedPercent,
    required this.onShare,
  });

  final int rows;
  final int clearedPercent;

  /// Null while a share is being prepared.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 4, 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videogame_asset_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.gridMatrixTitle(rows),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Text(
            context.l10n.gridMatrixCleared(clearedPercent),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.cyan),
          ),
          const SizedBox(width: 8),
          const PulseDot(size: 6),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onShare,
            tooltip: context.l10n.shareMatrixTooltip,
            icon: const Icon(Icons.ios_share_rounded, size: 16),
            color: AppColors.primary,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          ),
        ],
      ),
    );
  }
}

/// Base row, tallest column and cap % under the grid.
class MatrixCanvasFooter extends StatelessWidget {
  const MatrixCanvasFooter({super.key, required this.summary});

  final MatrixSummary summary;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.labelSm.copyWith(
      fontSize: 8,
      color: AppColors.textMuted.withValues(alpha: 0.7),
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(context.l10n.gridMatrixBase(summary.rows), style: muted),
          const Spacer(),
          Text('${summary.tallest}/${summary.rows}', style: muted),
          const SizedBox(width: 8),
          Text(
            context.l10n.gridMatrixCap(summary.capPercent),
            style: muted.copyWith(
              color: AppColors.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 6px neon pixel pinned to a card corner.
class MatrixCanvasCorner extends StatelessWidget {
  const MatrixCanvasCorner({
    super.key,
    required this.top,
    required this.left,
    required this.color,
  });

  final bool top;
  final bool left;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 6 : null,
      bottom: top ? null : 6,
      left: left ? 6 : null,
      right: left ? null : 6,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
          boxShadow: AppGlow.soft(color),
        ),
      ),
    );
  }
}
