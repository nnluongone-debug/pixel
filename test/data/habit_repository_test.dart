import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late HabitRepository habits;
  late CheckInRepository checkIns;
  late UserStatsRepository stats;
  var now = DateTime(2026, 10, 10, 9);

  setUp(() async {
    now = DateTime(2026, 10, 10, 9);
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
  });

  tearDown(() => db.close());

  Future<Habit> water() => habits.createHabit(
    name: 'Drink Water',
    type: HabitType.counter,
    target: 3,
    colorHex: '#00E5FF',
    iconName: 'water_drop',
  );

  Future<Habit> workout() => habits.createHabit(
    name: 'Daily Workout',
    type: HabitType.checklist,
    target: 1,
    colorHex: '#00FF66',
    iconName: 'fitness',
  );

  test('CRUD: create, read, update, delete', () async {
    final h = await water();
    expect((await habits.getHabits()).single.name, 'Drink Water');

    await habits.updateHabit(h.copyWith(name: 'Hydrate', target: 8));
    final updated = await habits.getHabit(h.id);
    expect((updated!.name, updated.target), ('Hydrate', 8));

    await habits.deleteHabit(h.id);
    expect(await habits.getHabits(), isEmpty);
  });

  test('rejects invalid names and targets', () async {
    expect(
      () => habits.createHabit(
        name: '  ',
        type: HabitType.counter,
        target: 1,
        colorHex: '#00E5FF',
        iconName: 'x',
      ),
      throwsArgumentError,
    );
    expect(
      () => habits.createHabit(
        name: 'Ok',
        type: HabitType.counter,
        target: 0,
        colorHex: '#00E5FF',
        iconName: 'x',
      ),
      throwsArgumentError,
    );
  });

  test('reaching target places one block and awards XP', () async {
    final h = await water();
    var update = await habits.incrementProgress(h.id);
    expect(update.placedCheckIn, isNull);

    await habits.incrementProgress(h.id);
    update = await habits.incrementProgress(h.id);
    expect(update.placedCheckIn, isNotNull);
    expect(update.xpGained, 25);
    expect(update.stats.currentXp, 25);
    expect(update.stats.streakDays, 1);

    // Going past target never double-awards.
    update = await habits.incrementProgress(h.id);
    expect(update.placedCheckIn, isNull);
    expect((await checkIns.getForHabit(h.id)).length, 1);
  });

  test('undo below target removes block and XP', () async {
    final h = await workout();
    await habits.setCompleted(h.id, completed: true);
    final undo = await habits.setCompleted(h.id, completed: false);
    expect(undo.removedCheckIn, isTrue);
    expect(undo.stats.currentXp, 0);
    expect(await checkIns.getForHabit(h.id), isEmpty);
  });

  test('blocks stack per day and fall when a lower one is removed', () async {
    final a = await workout();
    final b = await water();
    await habits.setCompleted(a.id, completed: true);
    await habits.setProgress(b.id, 3);

    var matrix = await checkIns.getMatrix();
    expect(matrix.map((c) => (c.habitId, c.gridY)), [(a.id, 0), (b.id, 1)]);

    await habits.setCompleted(a.id, completed: false);
    matrix = await checkIns.getMatrix();
    expect(matrix.single.gridY, 0);
  });

  test('progress resets on a new day; streak bonus and levels', () async {
    final h = await workout();
    for (var day = 0; day < 4; day++) {
      final update = await habits.setCompleted(h.id, completed: true);
      expect(update.xpGained, 25 + day * 5);
      now = now.add(const Duration(days: 1));
      expect((await habits.getHabit(h.id))!.currentProgress, 0);
    }
    // 25 + 30 + 35 + 40 = 130 XP -> level 2 with 30 XP.
    final s = await stats.getStats();
    expect((s.currentLevel, s.currentXp, s.targetXp), (2, 30, 150));
    expect(s.streakDays, 4); // today not done yet, yesterday still counts
    expect(await checkIns.getHabitStreak(h.id), 4);

    now = now.add(const Duration(days: 1)); // skipped a day
    expect((await stats.getStats()).streakDays, 0);
    expect(await stats.getBestStreak(), 4);
  });

  test('deleting a habit compacts columns and recomputes stats', () async {
    final a = await workout();
    final b = await water();
    await habits.setCompleted(a.id, completed: true);
    await habits.setProgress(b.id, 3);

    await habits.deleteHabit(a.id);
    final matrix = await checkIns.getMatrix();
    expect((matrix.single.habitId, matrix.single.gridY), (b.id, 0));
    expect((await stats.getStats()).currentXp, 25);
  });

  test('completed rows = shortest column across 10 days', () async {
    final h = await workout();
    for (var day = 0; day < 10; day++) {
      await habits.setCompleted(h.id, completed: true);
      if (day < 9) now = now.add(const Duration(days: 1));
    }
    expect(await checkIns.getCompletedRows(), 1);
    await habits.setCompleted(h.id, completed: false);
    expect(await checkIns.getCompletedRows(), 0);
  });

  test('double "done" is idempotent', () async {
    final h = await workout();
    await habits.setCompleted(h.id, completed: true);
    final again = await habits.setCompleted(h.id, completed: true);
    expect(again.placedCheckIn, isNull);
    expect(again.removedCheckIn, isFalse);
    expect((await checkIns.getForHabit(h.id)).length, 1);
  });

  test('an operation straddling midnight keeps yesterday\'s block', () async {
    final h = await water();
    await habits.setProgress(h.id, 4); // done for 2026-10-10

    // Clock advances 1ms per read, crossing midnight mid-operation.
    now = DateTime(2026, 10, 10, 23, 59, 59, 999);
    DateTime ticking() => now = now.add(const Duration(milliseconds: 1));
    final tickingHabits = HabitRepository(
      db,
      checkIns: CheckInRepository(db, clock: ticking),
      stats: UserStatsRepository(db, clock: ticking),
      clock: ticking,
    );
    await tickingHabits.incrementProgress(h.id);

    final blocks = await checkIns.getForHabit(h.id);
    expect(blocks.map((c) => c.date), contains('2026-10-10'));
  });

  test('stale reset restores target when today already has a block', () async {
    final h = await workout();
    await habits.setCompleted(h.id, completed: true);
    // Simulate a time-zone change: progress dated to another day.
    await db.update('habits', {'progress_date': '2026-10-09'});

    final reloaded = await habits.getHabit(h.id);
    expect(reloaded!.currentProgress, 1);
    final update = await habits.incrementProgress(h.id, amount: 0);
    expect(update.removedCheckIn, isFalse);
  });

  test('global streak survives days with nothing due', () async {
    // 2026-10-09 is a Friday; the habit runs Mon-Fri only.
    now = DateTime(2026, 10, 9, 9);
    final h = await habits.createHabit(
      name: 'Standup',
      type: HabitType.checklist,
      target: 1,
      colorHex: '#00FF66',
      iconName: 'fitness',
      schedule: HabitSchedule.weekdays,
    );
    await habits.setCompleted(h.id, completed: true);

    now = DateTime(2026, 10, 11, 20); // Sunday, nothing due Sat/Sun
    expect((await stats.getStats()).streakDays, 1);
    expect(await checkIns.getHabitStreak(h.id), 1);

    now = DateTime(2026, 10, 13, 9); // Tuesday: Monday was missed
    expect((await stats.getStats()).streakDays, 0);
  });
}
