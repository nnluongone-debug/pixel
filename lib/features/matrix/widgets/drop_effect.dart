import 'dart:math';

import 'package:flutter/animation.dart';

import 'matrix_layout.dart';

/// One falling brick plus its landing sparkle burst. Driven by its own
/// [AnimationController] whose span covers [delay] + fall + settle, so a
/// batch of new bricks can drop one after another without timers.
class DropEffect {
  DropEffect({
    required this.placed,
    required this.controller,
    required this.delay,
  }) : sparkles = Sparkle.burst(placed.block.id.hashCode);

  static const Duration fall = Duration(milliseconds: 420);
  static const Duration settle = Duration(milliseconds: 700);

  static Duration totalFor(Duration delay) => delay + fall + settle;

  /// Updated when the tower re-stacks mid-animation (e.g. an undo below).
  PlacedBlock placed;
  final AnimationController controller;
  final Duration delay;
  final List<Sparkle> sparkles;

  String get id => placed.block.id;

  /// Milliseconds since this brick started falling; negative while waiting.
  double get elapsedMs =>
      controller.value * totalFor(delay).inMilliseconds - delay.inMilliseconds;
}

/// A square pixel spark thrown upward when a brick lands.
class Sparkle {
  const Sparkle({
    required this.x,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
  });

  /// Spawn point across the brick's top edge, 0..1.
  final double x;

  /// Velocity in logical px per second (negative vy = upward).
  final double vx;
  final double vy;
  final double size;

  /// Lifetime in seconds.
  final double life;

  static const double gravity = 160;
  static const int count = 12;

  /// Deterministic burst per brick so a repaint never reshuffles sparks.
  static List<Sparkle> burst(int seed) {
    final random = Random(seed);
    return List.generate(
      count,
      (_) => Sparkle(
        x: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 80,
        vy: -(70 + random.nextDouble() * 120),
        size: 1.5 + random.nextDouble() * 2,
        life: 0.35 + random.nextDouble() * 0.35,
      ),
    );
  }
}
