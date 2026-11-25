import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/core/utils/date_key_utils.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_backfill_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late HabitRepository habits;
  late CheckInRepository checkIns;
  late UserStatsRepository stats;
  late HabitBackfillRepository backfill;
  var now = DateTime(2026, 10, 1, 9);

  setUp(() async {
    now = DateTime(2026, 10, 1, 9);
    db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    DateTime clock() => now;
    stats = UserStatsRepository(db, clock: clock);
    checkIns = CheckInRepository(db, clock: clock);
    habits = HabitRepository(
      db,
      checkIns: checkIns,
      stats: stats,
      clock: clock,
    );
    backfill = HabitBackfillRepository(
      db,
      checkIns: checkIns,
      stats: stats,
      clock: clock,
    );
  });

  tearDown(() => db.close());

  Future<Habit> create(HabitType type, int target) => habits.createHabit(
    name: 'Habit',
    type: type,
    target: target,
    colorHex: '#00FF66',
    iconName: 'fitness',
  );

  Future<int> outbox(String op, String id) async => (await db.query(
    'sync_outbox',
    where: 'entity_id = ? AND op = ?',
    whereArgs: [id, op],
  )).length;

  test('marking yesterday adds a base-XP block on top of the column', () async {
    final h = await create(HabitType.checklist, 1);
    final other = await create(HabitType.checklist, 1);
    now = DateTime(2026, 10, 5, 9);
    await backfill.setDone(other.id, '2026-10-04', done: true);
    final update = await backfill.setDone(h.id, '2026-10-04', done: true);

    final block = update.placedCheckIn!;
    expect(block.xpEarned, 25);
    expect(block.gridX, DateKeys.epochDayOfKey('2026-10-04'));
    expect(block.gridY, 1);
    expect(update.stats.currentXp, 50);
    expect(await outbox('upsert', block.id), 1);
  });

  test('unmarking removes it, compacts and restores XP', () async {
    final h = await create(HabitType.checklist, 1);
    final other = await create(HabitType.checklist, 1);
    now = DateTime(2026, 10, 5, 9);
    final first = await backfill.setDone(h.id, '2026-10-04', done: true);
    await backfill.setDone(other.id, '2026-10-04', done: true);
    final xpBefore = (await stats.getStats()).currentXp;

    final undo = await backfill.setDone(h.id, '2026-10-04', done: false);

    expect(undo.removedCheckIn, isTrue);
    expect(undo.stats.currentXp, xpBefore - 25);
    expect(await outbox('delete', first.placedCheckIn!.id), 1);
    final left = await checkIns.getBetween('2026-10-04', '2026-10-04');
    expect(left.single.habitId, other.id);
    expect(left.single.gridY, 0);
  });

  test('rejects today, older than 7 days, future and pre-creation', () async {
    final h = await create(HabitType.checklist, 1);
    now = DateTime(2026, 10, 20, 9);
    final late = await create(HabitType.checklist, 1);
    for (final key in ['2026-10-20', '2026-10-12', '2026-10-21']) {
      expect(
        () => backfill.setDone(h.id, key, done: true),
        throwsArgumentError,
        reason: key,
      );
    }
    // Inside the window but before the habit existed.
    expect(
      () => backfill.setDone(late.id, '2026-10-19', done: true),
      throwsArgumentError,
    );
    // Creation day itself is allowed once it is no longer today.
    now = DateTime(2026, 10, 21, 9);
    await backfill.setDone(late.id, '2026-10-20', done: true);
    expect(
      () => backfill.setDone('missing', '2026-10-24', done: true),
      throwsArgumentError,
    );
    // Oldest allowed day.
    now = DateTime(2026, 10, 8, 9);
    await backfill.setDone(h.id, '2026-10-01', done: true);
  });

  test('filling a gap revives the streak and best streak', () async {
    final h = await create(HabitType.checklist, 1);
    for (var d = 1; d <= 7; d++) {
      now = DateTime(2026, 10, d, 9);
      await habits.setCompleted(h.id, completed: true);
    }
    now = DateTime(2026, 10, 9, 9);
    await habits.setCompleted(h.id, completed: true);
    now = DateTime(2026, 10, 10, 9);
    expect((await stats.getStats()).streakDays, 1);
    expect(await checkIns.getHabitBestStreak(h.id), 7);

    final update = await backfill.setDone(h.id, '2026-10-08', done: true);

    expect(update.stats.streakDays, 9);
    expect(await checkIns.getHabitBestStreak(h.id), 9);
  });

  test('double mark and double unmark are no-ops', () async {
    final h = await create(HabitType.checklist, 1);
    now = DateTime(2026, 10, 3, 9);
    await backfill.setDone(h.id, '2026-10-02', done: true);
    final again = await backfill.setDone(h.id, '2026-10-02', done: true);
    expect(again.placedCheckIn, isNull);
    expect(again.stats.currentXp, 25);
    await backfill.setDone(h.id, '2026-10-02', done: false);
    final twice = await backfill.setDone(h.id, '2026-10-02', done: false);
    expect(twice.removedCheckIn, isFalse);
    expect(twice.stats.currentXp, 0);
  });

  test('counter progress and progressDate stay untouched', () async {
    final h = await create(HabitType.counter, 5);
    now = DateTime(2026, 10, 3, 9);
    await habits.setProgress(h.id, 2);
    await backfill.setDone(h.id, '2026-10-02', done: true);
    final after = (await habits.getHabit(h.id))!;
    expect(after.currentProgress, 2);
    expect(after.progressDate, '2026-10-03');
    expect(await backfill.doneDays(h.id, '2026-09-26', '2026-10-02'), {
      '2026-10-02',
    });
  });
}
