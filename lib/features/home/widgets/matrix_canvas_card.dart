import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/matrix_providers.dart';
import '../../../providers/cosmetics_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/sound_providers.dart';
import '../../../services/sound/sound_slot.dart';
import '../../matrix/models/check_in_block.dart';
import '../../matrix/models/matrix_summary.dart';
import '../../matrix/skins/brick_skin.dart';
import '../../matrix/widgets/pixel_matrix_grid.dart';
import 'matrix_rows_panel.dart';
import 'pulse_dot.dart';

/// The centerpiece card: HUD header, the 10x18 brick grid, base/cap footer
/// and the rows/legend panel, framed with four neon corner pixels.
class MatrixCanvasCard extends ConsumerWidget {
  const MatrixCanvasCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(matrixBlocksProvider);
    // Chime when the cleared-row count grows; the first load stays silent.
    ref.listen(completedRowsProvider, (prev, next) {
      final before = prev?.value;
      final after = next.value;
      if (before != null && after != null && after > before) {
        SoundFx.play(context, SoundSlot.rowClear);
      }
    });
    final skin = BrickSkin.of(ref.watch(equippedThemeProvider));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: const [BoxShadow(color: Color(0xB3000000), blurRadius: 36)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            // Keep the last grid while reloading after a mutation: swapping in
            // a spinner would shift the page and remount the grid, losing the
            // brick drop animation.
            child: blocks.when(
              skipLoadingOnReload: true,
              data: (list) => _Body(
                blocks: list,
                skin: skin,
                rows: PixelMatrixGrid.rowsFor(list),
              ),
              loading: () => const SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                context.l10n.gridMatrixError('$e'),
                style: AppTextStyles.bodySm,
              ),
            ),
          ),
          const _Corner(top: true, left: true, color: AppColors.mint),
          const _Corner(top: true, left: false, color: AppColors.cyan),
          const _Corner(top: false, left: true, color: AppColors.lavender),
          const _Corner(top: false, left: false, color: AppColors.mint),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.blocks, required this.skin, required this.rows});

  final List<CheckInBlock> blocks;
  final int rows;
  final BrickSkin skin;

  @override
  Widget build(BuildContext context) {
    final summary = MatrixSummary.of(blocks, DateTime.now(), rows: rows);
    return Column(
      children: [
        _Header(rows: rows, clearedPercent: summary.clearedPercent),
        const SizedBox(height: 8),
        PixelMatrixGrid(blocks: blocks, skin: skin, rows: rows),
        _Footer(summary: summary),
        const SizedBox(height: 4),
        const MatrixRowsPanel(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.rows, required this.clearedPercent});

  final int rows;
  final int clearedPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.summary});

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
class _Corner extends StatelessWidget {
  const _Corner({required this.top, required this.left, required this.color});

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
