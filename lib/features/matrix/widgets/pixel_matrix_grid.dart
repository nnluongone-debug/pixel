import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/check_in_repository.dart';
import '../models/check_in_block.dart';
import 'drop_effect.dart';
import 'matrix_axis_labels.dart';
import 'matrix_effects_painter.dart';
import 'matrix_grid_painter.dart';
import 'matrix_layout.dart';

/// Rolling pixel matrix: [columns] day columns ending today, each a tower of
/// [rows] slots; completed habits stack as bricks from the bottom up.
///
/// Bricks whose id was not in the previous [blocks] list drop in with a
/// sparkle burst. Build it only once data has loaded, otherwise the first
/// real list would animate as if every brick were new.
class PixelMatrixGrid extends StatefulWidget {
  const PixelMatrixGrid({
    super.key,
    required this.blocks,
    this.columns = MatrixCalendar.defaultColumns,
    this.rows = defaultRows,
    this.today,
  });

  static const int defaultRows = CheckInRepository.matrixRows;

  final List<CheckInBlock> blocks;
  final int columns;
  final int rows;

  /// Overrides "now" (tests, previews). Defaults to the device clock.
  final DateTime? today;

  @override
  State<PixelMatrixGrid> createState() => _PixelMatrixGridState();
}

class _PixelMatrixGridState extends State<PixelMatrixGrid>
    with TickerProviderStateMixin {
  static const Duration _stagger = Duration(milliseconds: 140);
  static const int _maxBatchMs = 4000;
  static const double _padding = 6;

  late MatrixCalendar _calendar;
  late MatrixPlacement _placement;
  List<DropEffect> _effects = const [];
  Set<String> _hiddenIds = const {};

  @override
  void initState() {
    super.initState();
    _rebuildPlacement();
  }

  @override
  void didUpdateWidget(PixelMatrixGrid old) {
    super.didUpdateWidget(old);
    _rebuildPlacement();

    final oldIds = {for (final b in old.blocks) b.id};
    final arrivals =
        _placement.visible.values
            .where((p) => !oldIds.contains(p.block.id))
            .toList()
          // Lower rows land first, left to right, so a big batch builds up
          // like a wall.
          ..sort((a, b) {
            final bySlot = a.slot.compareTo(b.slot);
            return bySlot != 0 ? bySlot : a.column.compareTo(b.column);
          });

    // Keep running effects in sync with the new stacking; drop vanished ones.
    final kept = <DropEffect>[];
    for (final effect in _effects) {
      final placed = _placement.visible[effect.id];
      if (placed == null) {
        effect.controller.dispose();
      } else {
        kept.add(effect..placed = placed);
      }
    }
    // Big batches share a fixed time budget instead of queuing for ages.
    final stagger = arrivals.length * _stagger.inMilliseconds > _maxBatchMs
        ? Duration(milliseconds: _maxBatchMs ~/ arrivals.length)
        : _stagger;
    for (var i = 0; i < arrivals.length; i++) {
      kept.add(_startDrop(arrivals[i], stagger * i));
    }
    _setEffects(kept);
  }

  void _rebuildPlacement() {
    _calendar = MatrixCalendar(
      today: widget.today ?? DateTime.now(),
      columns: widget.columns,
    );
    _placement = MatrixPlacement.build(widget.blocks, _calendar, widget.rows);
  }

  DropEffect _startDrop(PlacedBlock placed, Duration delay) {
    final controller = AnimationController(
      vsync: this,
      duration: DropEffect.totalFor(delay),
    );
    final effect = DropEffect(
      placed: placed,
      controller: controller,
      delay: delay,
    );
    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() {
        _setEffects(_effects.where((e) => e != effect).toList());
      });
      // Not inside its own status callback, and only after the rebuilt
      // painter has stopped listening to it.
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    });
    controller.forward();
    return effect;
  }

  /// New list/set instances so painters detect the change by identity.
  void _setEffects(List<DropEffect> effects) {
    _effects = List.unmodifiable(effects);
    _hiddenIds = {for (final e in effects) e.id};
  }

  @override
  void dispose() {
    for (final effect in _effects) {
      effect.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = MatrixGeometry(
          width: constraints.maxWidth - _padding * 2 - 2,
          columns: widget.columns,
          rows: widget.rows,
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _padding + 1),
              child: DayLabelRow(geometry: geometry, calendar: _calendar),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(_padding),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(geometry.width, geometry.height),
                  painter: MatrixGridPainter(
                    geometry: geometry,
                    calendar: _calendar,
                    placement: _placement,
                    hiddenIds: _hiddenIds,
                  ),
                  foregroundPainter: MatrixEffectsPainter(
                    geometry: geometry,
                    effects: _effects,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
