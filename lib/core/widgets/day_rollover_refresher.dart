import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/habit_providers.dart';

/// Re-reads habits, matrix and stats when the app returns to the foreground
/// and at local midnight, so the UI never acts on yesterday's state.
class DayRolloverRefresher extends ConsumerStatefulWidget {
  const DayRolloverRefresher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayRolloverRefresher> createState() =>
      _DayRolloverRefresherState();
}

class _DayRolloverRefresherState extends ConsumerState<DayRolloverRefresher> {
  late final AppLifecycleListener _lifecycle;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // Small margin so the refresh lands safely inside the new day.
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      _refresh,
    );
  }

  void _refresh() {
    if (!mounted) return;
    ref.read(habitsControllerProvider.notifier).refreshAll();
    // A suspended timer may be stale after resume; re-arm it.
    _scheduleMidnight();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
