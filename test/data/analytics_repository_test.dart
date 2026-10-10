import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/analytics_repository.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late HabitRepository habits;
  late AnalyticsRepository analytics;
  var now = DateTime(2026, 10, 10, 9);

  setUp(() async {
    now = DateTime(2026, 10, 10, 9);
    db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    DateTime clock() => now;
    habits = HabitRepository(
      db,
      checkIns: CheckInRepository(db, clock: clock),
      stats: UserStatsRepository(db, clock: clock),
      clock: clock,
    );
    analytics = AnalyticsRepository(db);
  });

  tearDown(() => db.close());

  Future<Habit> create(String name) => habits.createHabit(
    name: name,
    type: HabitType.checklist,
    target: 1,
    colorHex: '#2DE38E',
    iconName: 'target',
  );

  test('is empty on a fresh database', () async {
    expect(await analytics.getCheckInRecords(), isEmpty);
  });

  test('returns check-ins oldest first with epoch day and xp', () async {
    final a = await create('A');
    final b = await create('B');
    now = DateTime(2026, 10, 9, 20);
    await habits.setCompleted(a.id, completed: true);
    now = DateTime(2026, 10, 8, 8);
    await habits.setCompleted(b.id, completed: true);
    now = DateTime(2026, 10, 10, 9);
    await habits.setCompleted(b.id, completed: true);

    final records = await analytics.getCheckInRecords();
    expect(records.map((r) => r.habitId), [b.id, a.id, b.id]);
    expect(records.map((r) => r.epochDay), [
      DateKeys.epochDay(DateTime(2026, 10, 8)),
      DateKeys.epochDay(DateTime(2026, 10, 9)),
      DateKeys.epochDay(DateTime(2026, 10, 10)),
    ]);
    expect(records.every((r) => r.xp > 0), isTrue);
  });

  test('undoing a check-in removes it and deleting a habit cascades', () async {
    final a = await create('A');
    final b = await create('B');
    await habits.setCompleted(a.id, completed: true);
    await habits.setCompleted(b.id, completed: true);
    await habits.setCompleted(a.id, completed: false);
    expect((await analytics.getCheckInRecords()).single.habitId, b.id);

    await habits.deleteHabit(b.id);
    expect(await analytics.getCheckInRecords(), isEmpty);
  });
}
