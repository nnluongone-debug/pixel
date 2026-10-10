import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/repositories/check_in_repository.dart';
import 'package:pixel_quest/data/repositories/habit_repository.dart';
import 'package:pixel_quest/data/repositories/user_stats_repository.dart';
import 'package:pixel_quest/data/sync/sync_outbox.dart';
import 'package:pixel_quest/services/sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  final clockTime = DateTime(2026, 10, 10, 9);
  final base = clockTime.millisecondsSinceEpoch;
  const uid = 'user-1';

  late FakeFirebaseFirestore firestore;
  late Database db;
  late HabitRepository habits;
  late SharedPreferences prefs;
  late SyncService sync;

  SyncService serviceFor(String id) => SyncService(
    firestore: firestore,
    db: db,
    prefs: prefs,
    uid: id,
    clock: () => clockTime,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    firestore = FakeFirebaseFirestore();
    db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    DateTime clock() => clockTime;
    habits = HabitRepository(
      db,
      checkIns: CheckInRepository(db, clock: clock),
      stats: UserStatsRepository(db, clock: clock),
      clock: clock,
    );
    sync = serviceFor(uid);
  });

  tearDown(() => db.close());

  CollectionReference<Map<String, dynamic>> remote(String name) =>
      firestore.collection('users').doc(uid).collection(name);

  Future<Habit> habit(String name) => habits.createHabit(
    name: name,
    type: HabitType.checklist,
    target: 1,
    colorHex: '#00FF66',
    iconName: 'fitness',
  );

  Map<String, Object?> habitDoc(String id, int updatedAt, {String? name}) => {
    'id': id,
    'name': name ?? 'Remote',
    'type': 'counter',
    'target': 4,
    'currentProgress': 0,
    'colorHex': '#00E5FF',
    'iconName': 'water_drop',
    'unit': '',
    'scheduleDays': 127,
    'reminderMinutes': null,
    'createdAt': '2026-10-01T00:00:00.000Z',
    'progressDate': '2026-10-10',
    'updatedAt': updatedAt,
    'deleted': false,
    'syncedAt': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> checkInDoc(
    String id,
    String habitId,
    int updatedAt, {
    String date = '2026-10-09',
    int gridY = 0,
  }) => {
    'id': id,
    'habitId': habitId,
    'date': date,
    'xpEarned': 10,
    'gridX': 20000,
    'gridY': gridY,
    'updatedAt': updatedAt,
    'deleted': false,
    'syncedAt': FieldValue.serverTimestamp(),
  };

  Future<int> outboxCount() => SyncOutbox.count(db);

  group('push', () {
    test('writes docs and tombstones, then clears the outbox', () async {
      final a = await habit('A');
      final b = await habit('B');
      await habits.setCompleted(a.id, completed: true);
      await habits.deleteHabit(b.id);

      await sync.push();

      final doc = (await remote('habits').doc(a.id).get()).data()!;
      expect(doc['name'], 'A');
      expect(doc['deleted'], false);
      expect(doc['updatedAt'], base);
      expect(doc.containsKey('colorHex'), isTrue);
      expect(await remote('checkIns').get().then((s) => s.size), 1);
      final tomb = (await remote('habits').doc(b.id).get()).data()!;
      expect(tomb['deleted'], true);
      expect(tomb['updatedAt'], base);
      expect(tomb['syncedAt'], isA<Timestamp>());
      expect(doc['syncedAt'], isA<Timestamp>());
      expect(await outboxCount(), 0);
      expect(
        await firestore
            .collection('users')
            .doc(uid)
            .collection('user_stats')
            .get()
            .then((s) => s.size),
        0,
      );
    });

    test('an edit made during the upload stays queued', () async {
      final h = await habit('A');
      final uploaded = await SyncOutbox.read(db, limit: 10);
      await db.update(
        'habits',
        {'updated_at': base + 5},
        where: 'id = ?',
        whereArgs: [h.id],
      );
      await SyncOutbox.enqueue(
        db,
        SyncEntity.habit,
        h.id,
        SyncOp.upsert,
        base + 5,
      );

      await SyncOutbox.clearUnchanged(db, uploaded);

      final left = await SyncOutbox.read(db, limit: 10);
      expect(left.single.updatedAt, base + 5);
    });
  });

  group('pull', () {
    test('applies newer remote, ignores older, never enqueues', () async {
      final newer = await habit('Local newer');
      final older = await habit('Local older');
      await db.delete('sync_outbox');
      await db.update(
        'habits',
        {'updated_at': base},
        where: 'id = ?',
        whereArgs: [newer.id],
      );
      await db.update(
        'habits',
        {'updated_at': base},
        where: 'id = ?',
        whereArgs: [older.id],
      );
      await remote(
        'habits',
      ).doc(newer.id).set(habitDoc(newer.id, base + 10, name: 'Remote wins'));
      await remote(
        'habits',
      ).doc(older.id).set(habitDoc(older.id, base - 10, name: 'Remote loses'));
      await remote('habits').doc('new').set(habitDoc('new', base + 1));

      expect(await sync.pull(), isTrue);

      final names = {
        for (final r in await db.query('habits')) r['id']: r['name'],
      };
      expect(names[newer.id], 'Remote wins');
      expect(names[older.id], 'Local older');
      expect(names['new'], 'Remote');
      expect(await outboxCount(), 0);
      expect(await sync.pull(), isFalse);
    });

    test('tombstones delete locally and compact columns and stats', () async {
      final a = await habit('A');
      final b = await habit('B');
      await habits.setCompleted(a.id, completed: true);
      await habits.setCompleted(b.id, completed: true);
      await db.delete('sync_outbox');
      final aBlock = (await db.query(
        'check_ins',
        where: 'habit_id = ?',
        whereArgs: [a.id],
      )).single;
      final xpBefore =
          (await db.query('user_stats')).single['current_xp']! as int;
      await remote('checkIns').doc(aBlock['id']! as String).set({
        'id': aBlock['id'],
        'updatedAt': base + 100,
        'deleted': true,
        'syncedAt': FieldValue.serverTimestamp(),
      });

      expect(await sync.pull(), isTrue);

      final left = (await db.query('check_ins')).single;
      expect(left['habit_id'], b.id);
      expect(left['grid_y'], 0);
      final xpAfter =
          (await db.query('user_stats')).single['current_xp']! as int;
      expect(xpAfter, lessThan(xpBefore));
      expect(await outboxCount(), 0);
    });

    test('a habit tombstone cascades to its check-ins', () async {
      final a = await habit('A');
      await habits.setCompleted(a.id, completed: true);
      await db.delete('sync_outbox');
      await remote('habits').doc(a.id).set({
        'id': a.id,
        'updatedAt': base + 1,
        'deleted': true,
        'syncedAt': FieldValue.serverTimestamp(),
      });

      await sync.pull();

      expect(await db.query('habits'), isEmpty);
      expect(await db.query('check_ins'), isEmpty);
    });

    test('UNIQUE(habit_id, date) clash: newer block wins', () async {
      final a = await habit('A');
      await db.insert('check_ins', {
        'id': 'local',
        'habit_id': a.id,
        'date': '2026-10-09',
        'xp_earned': 10,
        'grid_x': 20000,
        'grid_y': 0,
        'updated_at': base,
      });
      await remote(
        'checkIns',
      ).doc('older').set(checkInDoc('older', a.id, base - 1));
      await sync.pull();
      expect((await db.query('check_ins')).single['id'], 'local');

      await remote(
        'checkIns',
      ).doc('newer').set(checkInDoc('newer', a.id, base + 1));
      await sync.pull();
      expect((await db.query('check_ins')).single['id'], 'newer');
    });

    test('skips malformed documents and keeps applying the rest', () async {
      await remote('habits').doc('bad').set({
        'id': 'bad',
        'updatedAt': base,
        'deleted': false,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      await remote(
        'checkIns',
      ).doc('orphan').set(checkInDoc('orphan', 'missing', base));
      await remote('habits').doc('ok').set(habitDoc('ok', base + 1));

      await sync.pull();

      expect((await db.query('habits')).single['id'], 'ok');
      expect(await db.query('check_ins'), isEmpty);
    });

    test('first pull fetches documents that predate syncedAt', () async {
      final legacy = habitDoc('legacy', base)..remove('syncedAt');
      await remote('habits').doc('legacy').set(legacy);
      await sync.pull();
      expect((await db.query('habits')).single['id'], 'legacy');
      expect(prefs.getInt('sync.habitSyncedAt.$uid'), 0);
    });

    test('a doc with an older updatedAt but synced later is pulled', () async {
      await remote('habits').doc('first').set(habitDoc('first', base + 50));
      await sync.pull();
      final mark = prefs.getInt('sync.habitSyncedAt.$uid')!;
      expect(mark, greaterThan(0));

      // Written by a device with a slow clock, synced well after the mark.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await remote('habits').doc('late').set(habitDoc('late', base - 100000));
      expect(await sync.pull(), isTrue);

      final ids = {for (final r in await db.query('habits')) r['id']};
      expect(ids, {'first', 'late'});
      expect(
        prefs.getInt('sync.habitSyncedAt.$uid')!,
        greaterThanOrEqualTo(mark),
      );
    });

    test('documents synced before the watermark are not refetched', () async {
      await remote('habits').doc('h').set(habitDoc('h', base + 1));
      await sync.pull();
      await db.delete('habits');
      // Far older than the margin: only a full fetch would bring it back.
      await prefs.setInt(
        'sync.habitSyncedAt.$uid',
        DateTime.now().add(const Duration(days: 1)).microsecondsSinceEpoch,
      );
      expect(await sync.pull(), isFalse);
      expect(await db.query('habits'), isEmpty);
    });

    test('a wipe during a pull cancels it', () async {
      await remote('habits').doc('h').set(habitDoc('h', base + 1));
      final pulling = sync.pull();
      await sync.wipeLocal();
      expect(await pulling, isFalse);
      expect(await db.query('habits'), isEmpty);
      expect(prefs.getKeys().where((k) => k.startsWith('sync.')), isEmpty);
    });
  });

  group('poison batch', () {
    test('rejected docs are quarantined; the rest still sync', () async {
      final good = await habit('Good');
      final bad = await habit('Bad');
      final rejecting = _RejectingFirestore(firestore, {bad.id});
      final svc = SyncService(
        firestore: rejecting,
        db: db,
        prefs: prefs,
        uid: uid,
        clock: () => clockTime,
      );

      await svc.push();

      expect((await remote('habits').doc(good.id).get()).exists, isTrue);
      expect((await remote('habits').doc(bad.id).get()).exists, isFalse);
      expect(await svc.pendingCount(), 0);
      expect(await db.query('sync_outbox'), hasLength(1));

      // A fresh edit re-queues the row for another attempt.
      await habits.updateHabit(bad.copyWith(name: 'Fixed'));
      expect(await svc.pendingCount(), 1);
    });
  });

  group('attach and wipe', () {
    test('first link uploads guest data', () async {
      final h = await habit('Guest habit');
      await habits.setCompleted(h.id, completed: true);
      await db.delete('sync_outbox');
      await db.update('habits', {'updated_at': 0});

      await sync.attach();

      expect((await remote('habits').get()).size, 1);
      expect((await remote('checkIns').get()).size, 1);
      expect(await outboxCount(), 0);
      expect(prefs.getString('sync.linkedUid'), uid);
    });

    test('the same account does not re-enqueue everything', () async {
      await habit('A');
      await sync.attach();
      await db.update('habits', {'name': 'Changed remotely'});
      await sync.attach();
      expect(await outboxCount(), 0);
    });

    test('a different account wipes local data first', () async {
      await habit('Old account habit');
      await sync.attach();

      final other = serviceFor('user-2');
      await other.attach();

      expect(await db.query('habits'), isEmpty);
      expect(prefs.getString('sync.linkedUid'), 'user-2');
    });

    test('wipeLocal empties data, outbox, stats and sync state', () async {
      final h = await habit('A');
      await habits.setCompleted(h.id, completed: true);
      await sync.attach();
      await habit('B');

      await sync.wipeLocal();

      expect(await db.query('habits'), isEmpty);
      expect(await db.query('check_ins'), isEmpty);
      expect(await db.query('sync_outbox'), isEmpty);
      expect((await db.query('user_stats')).single['current_xp'], 0);
      expect(prefs.getKeys().where((k) => k.startsWith('sync.')), isEmpty);
    });
  });
}

/// Rejects any batch containing a habit id from [bad] with permission-denied.
class _RejectingFirestore extends FakeFirebaseFirestore {
  _RejectingFirestore(this._inner, this.bad);

  final FakeFirebaseFirestore _inner;
  final Set<String> bad;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _inner.collection(path);

  @override
  WriteBatch batch() => _RejectingBatch(_inner.batch(), bad);
}

class _RejectingBatch implements WriteBatch {
  _RejectingBatch(this._inner, this._bad);

  final WriteBatch _inner;
  final Set<String> _bad;
  var _poisoned = false;

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    if (_bad.contains(document.id)) _poisoned = true;
    _inner.set(document, data, options);
  }

  @override
  Future<void> commit() {
    if (_poisoned) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
    }
    return _inner.commit();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
