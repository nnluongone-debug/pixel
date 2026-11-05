import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils/date_key_utils.dart';
import '../data/models/habit.dart';
import '../services/home_widget_snapshot.dart';
import '../services/home_widget_sync_service.dart';
import '../core/l10n/l10n_labels.dart';
import 'cosmetics_providers.dart';
import 'habit_providers.dart';
import 'locale_providers.dart';
import 'repository_providers.dart';

const _syncDebounce = Duration(milliseconds: 400);

/// Call once in `main()` before `runApp`.
Future<void> initializeHomeWidget() =>
    const HomeWidgetSyncService().initialize();

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>(
  (ref) => const HomeWidgetSyncService(),
);

/// Keeps the iOS widget snapshot fresh and handles widget deep links.
/// Watch it once from the app shell; it has no value of its own.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (!HomeWidgetSyncService.isSupported) return;
  Timer? debounce;
  void schedule() {
    debounce?.cancel();
    debounce = Timer(_syncDebounce, () => _pushSnapshot(ref));
  }

  ref.listen(habitsControllerProvider, (_, next) {
    if (next.hasValue) schedule();
  });
  ref.listen(userStatsProvider, (_, next) {
    if (next.hasValue) schedule();
  });
  ref.listen(effectiveLocaleProvider, (_, _) => schedule());
  ref.listen(equippedThemeProvider, (_, _) => schedule());
  schedule();

  final clicks = HomeWidget.widgetClicked.listen(
    (uri) => _handleUri(ref, uri),
    onError: (Object e) => debugPrint('HomeWidget click error: $e'),
  );
  HomeWidget.initiallyLaunchedFromHomeWidget().then(
    (uri) => _handleUri(ref, uri),
    onError: (Object e) => debugPrint('HomeWidget launch uri error: $e'),
  );

  ref.onDispose(() {
    debounce?.cancel();
    clicks.cancel();
  });
});

Future<void> _pushSnapshot(Ref ref) async {
  try {
    final habits = await ref.read(habitsControllerProvider.future);
    final stats = await ref.read(userStatsProvider.future);
    final checkIns = ref.read(checkInRepositoryProvider);
    final now = DateTime.now();
    final today = DateKeys.fromDate(now);
    final blocks = await checkIns.getBetween(
      DateKeys.shift(today, -(HomeWidgetSnapshot.towerDays - 1)),
      today,
    );
    final streaks = {
      for (final h in habits) h.id: await checkIns.getHabitStreak(h.id),
    };
    await ref
        .read(homeWidgetSyncServiceProvider)
        .sync(
          HomeWidgetSnapshot.build(
            now: now,
            habits: habits,
            checkIns: blocks,
            stats: stats,
            habitStreaks: streaks,
            lang: ref.read(effectiveLocaleProvider).languageCode,
            skin: ref.read(equippedThemeProvider).name,
            unitLabel: ref.read(appStringsProvider).unitLabel,
          ),
        );
  } catch (e, st) {
    debugPrint('HomeWidget snapshot failed: $e\n$st');
  }
}

/// `pixelquest://checkin?habit=<id>` completes/increments a habit;
/// `pixelquest://open` only opens the app.
Future<void> _handleUri(Ref ref, Uri? uri) async {
  if (uri == null || uri.scheme != 'pixelquest' || uri.host != 'checkin') {
    return;
  }
  final id = uri.queryParameters['habit'];
  if (id == null || id.isEmpty) return;
  try {
    final habits = await ref.read(habitsControllerProvider.future);
    final habit = habits.where((h) => h.id == id).firstOrNull;
    if (habit == null) return;
    final controller = ref.read(habitsControllerProvider.notifier);
    switch (habit.type) {
      case HabitType.counter:
        final doneToday =
            habit.progressDate == DateKeys.fromDate(DateTime.now()) &&
            habit.isCompleted;
        if (!doneToday) await controller.increment(id);
      case HabitType.checklist:
        await controller.setCompleted(id, completed: true);
      case HabitType.timer:
        break;
    }
  } catch (e, st) {
    debugPrint('HomeWidget deep link failed: $e\n$st');
  }
}
