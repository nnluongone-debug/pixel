import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/habit_providers.dart';

/// A running focus session for one timer habit.
class FocusSession {
  const FocusSession({
    required this.habitId,
    required this.startedAt,
    this.elapsed = Duration.zero,
    this.committedMinutes = 0,
  });

  final String habitId;

  /// Also the session's identity: a restarted session gets a new value.
  final DateTime startedAt;
  final Duration elapsed;

  /// Whole minutes already written to the habit's progress.
  final int committedMinutes;

  FocusSession copyWith({Duration? elapsed, int? committedMinutes}) =>
      FocusSession(
        habitId: habitId,
        startedAt: startedAt,
        elapsed: elapsed ?? this.elapsed,
        committedMinutes: committedMinutes ?? this.committedMinutes,
      );
}

final focusTimerProvider =
    NotifierProvider<FocusTimerController, FocusSession?>(
      FocusTimerController.new,
    );

/// One focus session at a time. Elapsed time comes from the wall clock, so
/// it stays right after the app was backgrounded. Each finished minute is
/// committed immediately: progress survives a crash, and the brick drops
/// the moment the target is reached mid-session.
///
/// Progress only exists for "today", so a session that crosses midnight
/// restarts at 00:00; minutes before midnight that were not committed yet
/// (app backgrounded) are dropped rather than credited to the wrong day.
class FocusTimerController extends Notifier<FocusSession?> {
  /// Sessions left running (e.g. app suspended overnight) stop here.
  static const Duration maxSession = Duration(hours: 6);

  Timer? _ticker;
  Future<void>? _inFlight;
  Future<void> _queue = Future.value();

  @override
  FocusSession? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  /// Starts [habitId], stopping (and committing) any other running session.
  Future<void> start(String habitId) => _serial(() async {
    if (state != null) await _stop();
    _ticker?.cancel();
    state = FocusSession(habitId: habitId, startedAt: DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  });

  /// Ends the session and commits remaining whole minutes.
  Future<void> stop() => _serial(_stop);

  /// Ends [habitId]'s session without committing, e.g. the habit was deleted.
  void cancelFor(String habitId) {
    if (state?.habitId != habitId) return;
    _ticker?.cancel();
    _ticker = null;
    state = null;
  }

  /// Runs start/stop one after another so taps can't interleave sessions.
  Future<void> _serial(Future<void> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      await _inFlight?.catchError((Object _) {});
      await _commit();
    } finally {
      state = null;
    }
  }

  void _tick() {
    final session = _rollOverMidnight(state);
    if (session == null) return;
    final elapsed = DateTime.now().difference(session.startedAt);
    state = session.copyWith(elapsed: elapsed);
    if (elapsed >= maxSession) {
      stop().catchError((Object e) => debugPrint('Focus stop failed: $e'));
    } else if (elapsed.inMinutes > session.committedMinutes &&
        _inFlight == null) {
      _inFlight = _commit()
          .catchError((Object e) => debugPrint('Focus commit failed: $e'))
          .whenComplete(() => _inFlight = null);
    }
  }

  /// Restarts the session at local midnight once the day has changed.
  FocusSession? _rollOverMidnight(FocusSession? session) {
    if (session == null) return null;
    final now = DateTime.now();
    final start = session.startedAt;
    if (start.year == now.year &&
        start.month == now.month &&
        start.day == now.day) {
      return session;
    }
    return state = FocusSession(
      habitId: session.habitId,
      startedAt: DateTime(now.year, now.month, now.day),
    );
  }

  Future<void> _commit() async {
    final session = _rollOverMidnight(state);
    if (session == null) return;
    final elapsed = DateTime.now().difference(session.startedAt);
    final minutes = (elapsed > maxSession ? maxSession : elapsed).inMinutes;
    final pending = minutes - session.committedMinutes;
    if (pending <= 0) return;

    // Claim the minutes before the await so a tick can't commit them twice.
    state = session.copyWith(committedMinutes: minutes);
    try {
      await ref
          .read(habitsControllerProvider.notifier)
          .increment(session.habitId, amount: pending);
    } on StateError {
      // Habit no longer exists; end the session instead of retrying forever.
      cancelFor(session.habitId);
      rethrow;
    } catch (_) {
      final current = state;
      if (current != null && current.startedAt == session.startedAt) {
        state = current.copyWith(committedMinutes: session.committedMinutes);
      }
      rethrow;
    }
  }
}
