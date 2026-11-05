import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'habit_providers.dart';

/// When the player last changed progress on this device in this session.
/// Unlock popups only celebrate unlocks that follow such an action; unlocks
/// that arrive by sync, reinstall or the demo are recorded silently.
final lastLocalProgressProvider =
    NotifierProvider<LastLocalProgress, DateTime?>(LastLocalProgress.new);

class LastLocalProgress extends Notifier<DateTime?> {
  /// How long after a tap an unlock still counts as earned by it.
  static const window = Duration(seconds: 20);

  @override
  DateTime? build() {
    final sub = ref
        .watch(progressEventsProvider)
        .stream
        .listen((_) => state = DateTime.now());
    ref.onDispose(sub.cancel);
    return null;
  }

  bool get isRecent {
    final at = state;
    return at != null && DateTime.now().difference(at) <= window;
  }
}

final celebrationQueueProvider = Provider<CelebrationQueue>(
  (ref) => CelebrationQueue(),
);

/// Runs celebration dialogs one after another app-wide, so a level-up that
/// unlocks a badge and a skin doesn't stack two dialogs.
class CelebrationQueue {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() show) {
    final result = _tail.then((_) => show());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
