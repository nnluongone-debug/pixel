import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reminder_service.dart';
import 'habit_providers.dart';
import 'locale_providers.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService.instance,
);

/// Reschedules notifications whenever habits or the app language change.
/// Watch it from a long-lived widget (the app shell) to keep it alive.
final reminderSyncProvider = Provider<void>((ref) {
  final service = ref.watch(reminderServiceProvider);
  void sync() {
    final habits = ref.read(habitsControllerProvider);
    final list = habits.value;
    if (habits.isLoading || list == null) return;
    unawaited(service.reschedule(list, ref.read(appStringsProvider)));
  }

  ref.listen(habitsControllerProvider, (_, _) => sync());
  ref.listen(appStringsProvider, (_, _) => sync());
  sync();
});

/// Whether the OS allows notifications; invalidate after requesting.
final notificationsEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(reminderServiceProvider).areNotificationsEnabled(),
);

/// Real pending-prompt data for Config; refreshes when habits or the
/// language (which triggers a reschedule) change.
final reminderSummaryProvider = FutureProvider<ReminderSummary>((ref) {
  ref.watch(habitsControllerProvider);
  ref.watch(appStringsProvider);
  return ref.watch(reminderServiceProvider).summary();
});
