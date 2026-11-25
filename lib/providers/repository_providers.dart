import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../data/repositories/check_in_repository.dart';
import '../data/repositories/habit_backfill_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/user_stats_repository.dart';

/// Opened once in `main()` and injected via `ProviderScope.overrides`, so the
/// rest of the graph can stay synchronous.
final databaseProvider = Provider<Database>(
  (ref) => throw StateError('databaseProvider must be overridden in main()'),
);

final userStatsRepositoryProvider = Provider<UserStatsRepository>(
  (ref) => UserStatsRepository(ref.watch(databaseProvider)),
);

final checkInRepositoryProvider = Provider<CheckInRepository>(
  (ref) => CheckInRepository(ref.watch(databaseProvider)),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(
    ref.watch(databaseProvider),
    checkIns: ref.watch(checkInRepositoryProvider),
    stats: ref.watch(userStatsRepositoryProvider),
  ),
);

final habitBackfillRepositoryProvider = Provider<HabitBackfillRepository>(
  (ref) => HabitBackfillRepository(
    ref.watch(databaseProvider),
    checkIns: ref.watch(checkInRepositoryProvider),
    stats: ref.watch(userStatsRepositoryProvider),
  ),
);
