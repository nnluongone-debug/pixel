import 'dart:math' show max;

import 'package:flutter/material.dart';

import '../../../providers/sound_providers.dart';
import '../../../services/sound/sound_slot.dart';
import '../models/check_in_block.dart';
import '../skins/brick_skin.dart';
import '../skins/neon_glow_skin.dart';
import 'drop_effect.dart';
import 'frozen_day_painter.dart';
import 'matrix_axis_labels.dart';
import 'matrix_effects_painter.dart';
import 'matrix_grid_painter.dart';
import 'matrix_layout.dart';
import 'matrix_overlay_painter.dart';
import 'overlay_clock.dart';

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
    this.rows = minRows,
    this.today,
    this.frozenDays = const {},
    this.skin = const NeonGlowSkin(),
  });

  /// Shortest grid. It only grows once a day actually holds more bricks.
  static const int minRows = 10;

  /// Rows needed to show [blocks]: the tallest day's brick count, at least
  /// [minRows]. Habits that exist but aren't checked off don't add rows.
  static int rowsFor(Iterable<CheckInBlock> blocks) {
    final perDay = <String, int>{};
    for (final b in blocks) {
      perDay[b.dateKey] = (perDay[b.dateKey] ?? 0) + 1;
    }
    return max(minRows, perDay.values.fold(0, max));
  }

  final List<CheckInBlock> blocks;
  final int columns;
  final int rows;

  /// Overrides "now" (tests, previews). Defaults to the device clock.
  final DateTime? today;

  /// Epoch days saved by a streak freeze; shown as ice tiles when empty.
  final Set<int> frozenDays;

  /// Brick style. Changing it restyles in place; the grid keeps its state, so
  /// running drop animations survive.
  final BrickSkin skin;

  @override
  State<PixelMatrixGrid> createState() => _PixelMatrixGridState();
}

class _PixelMatrixGridState extends State<PixelMatrixGrid>
    with TickerProviderStateMixin {
  static const Duration _stagger = Duration(milliseconds: 140);
  static const int _maxBatchMs = 4000;
  static const double _padding = 6;
  static final double _fallMs = DropEffect.fall.inMilliseconds.toDouble();

  late MatrixCalendar _calendar;
  late MatrixPlacement _placement;
  List<DropEffect> _effects = const [];
  Set<String> _hiddenIds = const {};

  /// Drives animated skins; stopped for static skins, reduce-motion and
  /// while the grid is offstage (TickerMode disabled).
  final OverlayClock _overlayClock = OverlayClock();

  @override
  void initState() {
    super.initState();
    _rebuildPlacement();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncOverlayClock();
  }

  void _syncOverlayClock() {
    final run =
        widget.skin.animated &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (run) {
      _overlayClock.start(widget.skin);
    } else {
      _overlayClock.stop();
    }
  }

  @override
  void didUpdateWidget(PixelMatrixGrid old) {
    super.didUpdateWidget(old);
    if (old.skin != widget.skin) _syncOverlayClock();
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
    // Land sound at the end of the fall. Only drops create effects, so the
    // initial build is silent.
    var landed = false;
    controller.addListener(() {
      if (landed || !mounted || effect.elapsedMs < _fallMs) return;
      landed = true;
      SoundFx.play(context, SoundSlot.brickLand);
    });
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
    _overlayClock.dispose();
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
                color: widget.skin.panelColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.skin.panelBorderColor),
              ),
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(geometry.width, geometry.height),
                      painter: MatrixGridPainter(
                        skin: widget.skin,
                        geometry: geometry,
                        calendar: _calendar,
                        placement: _placement,
                        hiddenIds: _hiddenIds,
                      ),
                    ),
                  ),
                  if (widget.frozenDays.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: FrozenDayPainter(
                              geometry: geometry,
                              calendar: _calendar,
                              placement: _placement,
                              frozenDays: widget.frozenDays,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Own layer: drop animations repaint only this, never the
                  // cached static layer.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: MatrixEffectsPainter(
                            skin: widget.skin,
                            geometry: geometry,
                            effects: _effects,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_overlayClock.running)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: MatrixOverlayPainter(
                              skin: widget.skin,
                              geometry: geometry,
                              placement: _placement,
                              hiddenIds: _hiddenIds,
                              time: _overlayClock.time,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
