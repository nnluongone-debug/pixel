import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_key_utils.dart';
import '../data/models/check_in.dart';
import '../data/models/habit.dart';
import '../data/models/progress_update.dart';
import '../data/models/user_stats.dart';
import '../data/repositories/habit_repository.dart';
import '../features/habits/focus_timer_controller.dart';
import 'growth_providers.dart';
import 'repository_providers.dart';

final userStatsProvider = FutureProvider<UserStats>(
  (ref) => ref.watch(userStatsRepositoryProvider).getStats(),
);

/// Blocks for the visible 10-day matrix.
final matrixProvider = FutureProvider<List<CheckIn>>(
  (ref) => ref.watch(checkInRepositoryProvider).getMatrix(),
);

final completedRowsProvider = FutureProvider<int>(
  (ref) => ref.watch(checkInRepositoryProvider).getCompletedRows(),
);

/// Every progress change from any source (button tap, focus timer), so
/// cards can play completion feedback no matter who triggered it.
final progressEventsProvider = Provider<StreamController<ProgressUpdate>>((
  ref,
) {
  final controller = StreamController<ProgressUpdate>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

/// Current streak of one habit, for the "15D STREAK" badge.
final habitStreakProvider = FutureProvider.family<int, String>(
  (ref, habitId) =>
      ref.watch(checkInRepositoryProvider).getHabitStreak(habitId),
);

/// Today's `YYYY-MM-DD`. Bumped by [HabitsController.refreshAll] (app resume,
/// local midnight) so day-scoped UI such as the heatmap month moves on.
final currentDayProvider = NotifierProvider<CurrentDayNotifier, String>(
  CurrentDayNotifier.new,
);

class CurrentDayNotifier extends Notifier<String> {
  @override
  String build() => DateKeys.fromDate(DateTime.now());

  void sync() {
    final today = DateKeys.fromDate(DateTime.now());
    if (today != state) state = today;
  }
}

final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, List<Habit>>(HabitsController.new);

/// Active habits plus every mutation the UI can trigger. Each mutation
/// refreshes habits, matrix and stats so all screens stay in sync.
class HabitsController extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() => ref.watch(habitRepositoryProvider).getHabits();

  Future<Habit> create({
    required String name,
    required HabitType type,
    required int target,
    required String colorHex,
    required String iconName,
    String unit = '',
    HabitSchedule schedule = HabitSchedule.daily,
    List<int>? reminderTimes,
    int? reminderEvery,
    int reminderFrom = Habit.defaultReminderFrom,
    int reminderTo = Habit.defaultReminderTo,
  }) async {
    final habit = await _mutate(
      (repo) => repo.createHabit(
        name: name,
        type: type,
        target: target,
        colorHex: colorHex,
        iconName: iconName,
        unit: unit,
        schedule: schedule,
        reminderTimes: reminderTimes ?? const [],
        reminderEvery: reminderEvery,
        reminderFrom: reminderFrom,
        reminderTo: reminderTo,
      ),
    );
    unawaited(
      ref
          .read(usageAnalyticsProvider)
          .habitCreated(
            type: habit.type.name,
            schedule: _scheduleTag(habit.schedule),
            hasReminder: habit.hasReminder,
          ),
    );
    return habit;
  }

  static String _scheduleTag(HabitSchedule schedule) {
    if (schedule == HabitSchedule.daily) return 'daily';
    if (schedule == HabitSchedule.weekdays) return 'weekdays';
    return 'custom';
  }

  Future<ProgressUpdate> edit(Habit habit) =>
      _mutate((repo) => repo.updateHabit(habit));

  Future<ProgressUpdate> increment(String id, {int amount = 1}) =>
      _mutate((repo) => repo.incrementProgress(id, amount: amount));

  Future<ProgressUpdate> setProgress(String id, int value) =>
      _mutate((repo) => repo.setProgress(id, value));

  Future<ProgressUpdate> setCompleted(String id, {required bool completed}) =>
      _mutate((repo) => repo.setCompleted(id, completed: completed));

  Future<void> delete(String id) {
    ref.read(focusTimerProvider.notifier).cancelFor(id);
    return _mutate((repo) => repo.deleteHabit(id));
  }

  Future<T> _mutate<T>(Future<T> Function(HabitRepository repo) action) async {
    final result = await action(ref.read(habitRepositoryProvider));
    _refreshAll();
    if (result is ProgressUpdate) {
      ref.read(progressEventsProvider).add(result);
      _logProgress(result);
    }
    return result;
  }

  void _logProgress(ProgressUpdate update) {
    final analytics = ref.read(usageAnalyticsProvider);
    if (update.placedCheckIn != null) {
      unawaited(
        analytics.habitCompleted(
          habitId: update.habit.id,
          type: update.habit.type.name,
          dayKey: DateKeys.fromDate(DateTime.now()),
        ),
      );
    }
    if (update.leveledUp) {
      unawaited(analytics.levelUp(update.stats.currentLevel));
    }
  }

  /// Re-reads everything; call on app resume and at local midnight.
  void refreshAll() => _refreshAll();

  void _refreshAll() {
    ref.read(currentDayProvider.notifier).sync();
    ref.invalidateSelf();
    ref.invalidate(userStatsProvider);
    ref.invalidate(matrixProvider);
    ref.invalidate(completedRowsProvider);
    ref.invalidate(habitStreakProvider);
  }
}
