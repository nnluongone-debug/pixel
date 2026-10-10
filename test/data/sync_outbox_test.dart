import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/data/sync/sync_outbox.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late HabitRepository habits;
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
  });

  tearDown(() => db.close());

  Future<Habit> habit(String name, {int target = 1}) => habits.createHabit(
    name: name,
    type: HabitType.counter,
    target: target,
    colorHex: '#00E5FF',
    iconName: 'water_drop',
  );

  Future<Map<String, (SyncOp, int)>> outbox() async => {
    for (final e in await SyncOutbox.read(db, limit: 100))
      '${e.entity.key}:${e.id}': (e.op, e.updatedAt),
  };

  Future<void> drain() => db.delete('sync_outbox');

  final stamp = DateTime(2026, 10, 10, 9).millisecondsSinceEpoch;

  test('create queues a habit upsert and stamps updated_at', () async {
    final h = await habit('Water');
    expect(await outbox(), {'habit:${h.id}': (SyncOp.upsert, stamp)});
    final row = (await db.query('habits')).single;
    expect(row['updated_at'], stamp);
  });

  test('update and progress changes queue the habit again', () async {
    final h = await habit('Water', target: 5);
    await drain();
    now = now.add(const Duration(minutes: 1));
    await habits.updateHabit(h.copyWith(name: 'Hydrate'));
    final later = now.millisecondsSinceEpoch;
    expect(await outbox(), {'habit:${h.id}': (SyncOp.upsert, later)});

    await drain();
    now = now.add(const Duration(minutes: 1));
    await habits.incrementProgress(h.id);
    expect(await outbox(), {
      'habit:${h.id}': (SyncOp.upsert, now.millisecondsSinceEpoch),
    });
  });

  test(
    'completing queues a check-in upsert; undoing queues a tombstone',
    () async {
      final h = await habit('Water');
      await drain();
      await habits.setCompleted(h.id, completed: true);
      final checkIn = (await db.query('check_ins')).single;
      final id = checkIn['id']! as String;
      expect(checkIn['updated_at'], stamp);
      expect(await outbox(), {
        'habit:${h.id}': (SyncOp.upsert, stamp),
        'checkIn:$id': (SyncOp.upsert, stamp),
      });

      await habits.setCompleted(h.id, completed: false);
      final entries = await outbox();
      expect(entries['checkIn:$id'], (SyncOp.delete, stamp));
      expect(await db.query('check_ins'), isEmpty);
    },
  );

  test('compaction queues the blocks that moved down', () async {
    final a = await habit('A');
    final b = await habit('B');
    await habits.setCompleted(a.id, completed: true);
    await habits.setCompleted(b.id, completed: true);
    final bId =
        (await db.query(
              'check_ins',
              where: 'habit_id = ?',
              whereArgs: [b.id],
            )).single['id']!
            as String;
    await drain();
    now = now.add(const Duration(minutes: 5));
    await habits.setCompleted(a.id, completed: false);

    final moved = (await db.query('check_ins')).single;
    expect(moved['grid_y'], 0);
    expect(moved['updated_at'], now.millisecondsSinceEpoch);
    expect((await outbox())['checkIn:$bId'], (
      SyncOp.upsert,
      now.millisecondsSinceEpoch,
    ));
  });

  test('deleting a habit queues tombstones for it and its check-ins', () async {
    final h = await habit('Water');
    await habits.setCompleted(h.id, completed: true);
    final id = (await db.query('check_ins')).single['id']! as String;
    await drain();
    now = now.add(const Duration(minutes: 1));
    await habits.deleteHabit(h.id);
    final later = now.millisecondsSinceEpoch;
    expect(await outbox(), {
      'habit:${h.id}': (SyncOp.delete, later),
      'checkIn:$id': (SyncOp.delete, later),
    });
  });

  test('the daily stale-progress reset queues nothing', () async {
    final h = await habit('Water', target: 3);
    await habits.incrementProgress(h.id);
    await drain();
    now = now.add(const Duration(days: 1));
    expect((await habits.getHabits()).single.currentProgress, 0);
    expect(await outbox(), isEmpty);
  });
}
