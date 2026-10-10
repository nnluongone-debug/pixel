import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_key_utils.dart';
import '../../data/models/user_stats.dart';
import '../../data/repositories/check_in_repository.dart';
import '../../data/repositories/user_stats_repository.dart';
import '../../data/sync/sync_outbox.dart';
import 'sync_pull_applier.dart';
import 'sync_pusher.dart';

/// Two-way sync between the local SQLite data and `users/{uid}` in Firestore.
/// SQLite stays the source of truth: local changes are queued in
/// `sync_outbox` and uploaded by [push]; remote ones are merged by [pull]
/// with last-write-wins on `updatedAt`. `user_stats` is derived, never synced.
class SyncService {
  SyncService({
    required FirebaseFirestore firestore,
    required this.db,
    required this.prefs,
    required this.uid,
    Clock? clock,
  }) : _fs = firestore,
       _clock = clock ?? DateTime.now;

  /// How far before the watermark a pull starts, in case a document was
  /// committed with a slightly older server timestamp than one already seen.
  static const Duration watermarkMargin = Duration(seconds: 5);

  /// Firestore queues writes and reads while offline instead of failing, so
  /// every round trip is bounded and surfaces as a [TimeoutException].
  static const Duration networkTimeout = Duration(seconds: 30);

  static const _linkedUidKey = 'sync.linkedUid';
  static const _keyPrefix = 'sync.';

  final String uid;
  final FirebaseFirestore _fs;
  final Database db;
  final SharedPreferences prefs;
  final Clock _clock;

  /// Bumped by [wipeLocal]; a pull that started earlier never applies.
  int _generation = 0;

  CollectionReference<Map<String, dynamic>> _collection(SyncEntity entity) =>
      _fs.collection('users').doc(uid).collection('${entity.key}s');

  String _watermarkKey(SyncEntity entity) =>
      '$_keyPrefix${entity.key}SyncedAt.$uid';

  Future<int> pendingCount() => SyncOutbox.count(db);

  /// Links this device to the account, then syncs. The first link uploads
  /// the existing (guest) data; a different account than last time wipes
  /// the device first. Returns whether the pull changed local data.
  Future<bool> attach() async {
    final linked = prefs.getString(_linkedUidKey);
    if (linked != null && linked != uid) await wipeLocal();
    if (linked != uid) {
      final now = _clock().millisecondsSinceEpoch;
      await db.transaction((txn) => SyncOutbox.enqueueAll(txn, now));
      await prefs.setString(_linkedUidKey, uid);
    }
    await push();
    return pull();
  }

  /// Uploads the outbox; see [SyncPusher.push].
  Future<void> push() =>
      SyncPusher(db, _fs, _collection, networkTimeout).push();

  /// Merges remote changes synced since the stored watermark. Everything
  /// lands in one transaction, followed by column compaction and a stats
  /// rebuild; the watermark moves only afterwards. Returns whether local
  /// data changed. A wipe that happens meanwhile cancels the whole pull.
  ///
  /// The watermark is the newest server-assigned `syncedAt` seen (the first
  /// pull has none and fetches everything, including documents written
  /// before `syncedAt` existed). The next fetch starts [watermarkMargin]
  /// before it, so a document committed late is not missed; re-applying
  /// documents is a no-op under last-write-wins.
  Future<bool> pull() async {
    final generation = _generation;
    final fetched = <SyncEntity, List<Map<String, Object?>>>{};
    final watermarks = <SyncEntity, int>{};
    for (final entity in SyncEntity.values) {
      final stored = prefs.getInt(_watermarkKey(entity));
      Query<Map<String, dynamic>> query = _collection(entity);
      if (stored != null) {
        final from = Timestamp.fromMicrosecondsSinceEpoch(
          stored - watermarkMargin.inMicroseconds,
        );
        query = query
            .where('syncedAt', isGreaterThanOrEqualTo: from)
            .orderBy('syncedAt');
      }
      final snap = await query
          .get(const GetOptions(source: Source.server))
          .timeout(networkTimeout);
      fetched[entity] = [for (final d in snap.docs) d.data()];
      watermarks[entity] = fetched[entity]!.fold(stored ?? 0, (max, doc) {
        final syncedAt = doc['syncedAt'];
        return syncedAt is Timestamp && syncedAt.microsecondsSinceEpoch > max
            ? syncedAt.microsecondsSinceEpoch
            : max;
      });
    }

    final now = _clock();
    final applied = await db.transaction((txn) async {
      if (generation != _generation) return 0;
      final applier = SyncPullApplier(txn);
      for (final entity in SyncEntity.values) {
        for (final doc in fetched[entity]!) {
          await applier.apply(entity, doc);
        }
      }
      if (applier.applied == 0) return 0;
      final checkIns = CheckInRepository(db, clock: _clock);
      for (final date in applier.affectedDates) {
        await checkIns.compactColumn(txn, date, track: false);
      }
      await UserStatsRepository(db, clock: _clock).recalculate(txn, now: now);
      return applier.applied;
    });

    if (generation != _generation) return false;
    for (final entity in SyncEntity.values) {
      await prefs.setInt(_watermarkKey(entity), watermarks[entity]!);
    }
    return applied > 0;
  }

  /// Empties this device back to a fresh guest state.
  Future<void> wipeLocal() async {
    _generation++;
    await db.transaction((txn) async {
      await txn.delete('check_ins');
      await txn.delete('habits');
      await txn.delete('sync_outbox');
      await txn.insert('user_stats', {
        'id': 1,
        ...UserStats.initial.toMap(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    for (final key in prefs.getKeys().where((k) => k.startsWith(_keyPrefix))) {
      await prefs.remove(key);
    }
  }
}
