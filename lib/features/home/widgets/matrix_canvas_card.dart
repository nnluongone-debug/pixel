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
import '../share/matrix_share_action.dart';
import 'matrix_rows_panel.dart';
import 'matrix_canvas_parts.dart';

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
    final frozenDays =
        ref.watch(streakFreezeProvider).value?.frozenDays ?? const <int>{};

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
                frozenDays: frozenDays,
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
          const MatrixCanvasCorner(
            top: true,
            left: true,
            color: AppColors.mint,
          ),
          const MatrixCanvasCorner(
            top: true,
            left: false,
            color: AppColors.cyan,
          ),
          const MatrixCanvasCorner(
            top: false,
            left: true,
            color: AppColors.lavender,
          ),
          const MatrixCanvasCorner(
            top: false,
            left: false,
            color: AppColors.mint,
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({
    required this.blocks,
    required this.skin,
    required this.rows,
    required this.frozenDays,
  });

  final List<CheckInBlock> blocks;
  final Set<int> frozenDays;
  final int rows;
  final BrickSkin skin;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  /// Wraps grid + footer: the part captured for the share image.
  final _shareKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share(int clearedPercent) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await MatrixShareAction.share(
        context: context,
        ref: ref,
        boundaryKey: _shareKey,
        clearedPercent: clearedPercent,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.rows;
    final summary = MatrixSummary.of(widget.blocks, DateTime.now(), rows: rows);
    return Column(
      children: [
        MatrixCanvasHeader(
          rows: rows,
          clearedPercent: summary.clearedPercent,
          onShare: _sharing ? null : () => _share(summary.clearedPercent),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          key: _shareKey,
          child: Column(
            children: [
              PixelMatrixGrid(
                blocks: widget.blocks,
                frozenDays: widget.frozenDays,
                skin: widget.skin,
                rows: rows,
              ),
              MatrixCanvasFooter(summary: summary),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const MatrixRowsPanel(),
      ],
    );
  }
}
