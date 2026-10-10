import 'dart:async';

import 'package:flutter/foundation.dart';

/// Counts whole seconds down to zero; listeners rebuild on every tick.
class ResendTimer extends ValueNotifier<int> {
  ResendTimer() : super(0);

  Timer? _ticker;

  /// Restarts the countdown from [delay], rounded up to whole seconds.
  void start(Duration delay) {
    _ticker?.cancel();
    value = (delay.inMilliseconds / 1000).ceil();
    if (value <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      value = value - 1;
      if (value <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
