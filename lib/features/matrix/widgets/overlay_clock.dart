import 'dart:async';

import 'package:flutter/foundation.dart';

import '../skins/brick_skin.dart';

/// Drives an animated skin's overlay without a per-vsync ticker. It advances a
/// virtual clock by the delay the skin asks for, so a repaint (and thus a
/// frame) is only requested when something visible can change.
class OverlayClock {
  /// Seconds on the virtual clock; the overlay painter listens to it.
  final ValueNotifier<double> time = ValueNotifier(0);
  Timer? _timer;
  BrickSkin? _skin;

  bool get running => _timer != null;

  /// Starts (or restarts) the clock for [skin]. No-op if already running it.
  void start(BrickSkin skin) {
    if (_skin == skin && running) return;
    stop();
    _skin = skin;
    _schedule();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _skin = null;
  }

  void _schedule() {
    final skin = _skin;
    if (skin == null) return;
    final delay = skin.overlayFrameDelay(time.value);
    _timer = Timer(delay, () {
      time.value += delay.inMicroseconds / 1e6;
      _schedule();
    });
  }

  void dispose() {
    stop();
    time.dispose();
  }
}
