import 'package:sqflite/sqflite.dart';

import '../../data/sync/sync_outbox.dart';
import 'sync_documents.dart';

/// Applies remote documents inside one SQLite transaction with
/// last-write-wins against the local `updated_at`. Nothing here is queued in
/// the outbox; applied rows also drop their now-obsolete pending change.
class SyncPullApplier {
  SyncPullApplier(this._txn);

  final Transaction _txn;

  /// Days whose `grid_y` stacking may need re-compacting.
  final Set<String> affectedDates = {};

  /// Documents that changed local data.
  int applied = 0;

  /// Applies [doc] atomically; a document the database rejects (constraint
  /// violation, missing parent habit) is skipped without touching anything.
  Future<void> apply(SyncEntity entity, Map<String, Object?> doc) async {
    await _txn.execute('SAVEPOINT remote_doc');
    try {
      final changed = entity == SyncEntity.habit
          ? await _habit(doc)
          : await _checkIn(doc);
      if (changed) applied++;
      await _txn.execute('RELEASE remote_doc');
    } on DatabaseException {
      await _txn.execute('ROLLBACK TO remote_doc');
      await _txn.execute('RELEASE remote_doc');
    }
  }

  Future<bool> _habit(Map<String, Object?> doc) async {
    final id = doc['id'];
    final stamp = doc['updatedAt'];
    if (id is! String || stamp is! int) return false;
    final local = await _stamp('habits', id);

    if (doc['deleted'] == true) {
      if (local == null || local > stamp) return false;
      for (final r in await _txn.query(
        'check_ins',
        columns: ['id', 'date'],
        where: 'habit_id = ?',
        whereArgs: [id],
      )) {
        affectedDates.add(r['date']! as String);
        await SyncOutbox.remove(_txn, SyncEntity.checkIn, r['id']! as String);
      }
      await _txn.delete('habits', where: 'id = ?', whereArgs: [id]);
      await SyncOutbox.remove(_txn, SyncEntity.habit, id);
      return true;
    }

    final row = SyncDocuments.toRow(SyncEntity.habit, doc);
    if (row == null || !await _remoteWins(SyncEntity.habit, id, stamp, local)) {
      return false;
    }
    await _write('habits', row, exists: local != null);
    await SyncOutbox.remove(_txn, SyncEntity.habit, id);
    return true;
  }

  Future<bool> _checkIn(Map<String, Object?> doc) async {
    final id = doc['id'];
    final stamp = doc['updatedAt'];
    if (id is! String || stamp is! int) return false;
    final byId = await _row('check_ins', id);

    if (doc['deleted'] == true) {
      if (byId == null || (byId['updated_at']! as int) > stamp) return false;
      affectedDates.add(byId['date']! as String);
      await _txn.delete('check_ins', where: 'id = ?', whereArgs: [id]);
      await SyncOutbox.remove(_txn, SyncEntity.checkIn, id);
      return true;
    }

    final row = SyncDocuments.toRow(SyncEntity.checkIn, doc);
    if (row == null ||
        !await _remoteWins(
          SyncEntity.checkIn,
          id,
          stamp,
          byId?['updated_at'] as int?,
        )) {
      return false;
    }

    // UNIQUE (habit_id, date): another block already holds this slot. The
    // newer one wins; on equal stamps the smaller id, so every device agrees.
    final clash = await _txn.query(
      'check_ins',
      columns: ['id', 'updated_at'],
      where: 'habit_id = ? AND date = ? AND id != ?',
      whereArgs: [row['habit_id'], row['date'], id],
      limit: 1,
    );
    if (clash.isNotEmpty) {
      final clashId = clash.first['id']! as String;
      final clashStamp = clash.first['updated_at']! as int;
      final wins =
          stamp > clashStamp ||
          (stamp == clashStamp && id.compareTo(clashId) < 0);
      if (!wins) return false;
      await _txn.delete('check_ins', where: 'id = ?', whereArgs: [clashId]);
      await SyncOutbox.remove(_txn, SyncEntity.checkIn, clashId);
    }

    if (byId != null) affectedDates.add(byId['date']! as String);
    await _write('check_ins', row, exists: byId != null);
    affectedDates.add(row['date']! as String);
    await SyncOutbox.remove(_txn, SyncEntity.checkIn, id);
    return true;
  }

  /// A remote upsert beats a local row only if strictly newer, and beats a
  /// pending local delete only if newer than that delete.
  Future<bool> _remoteWins(
    SyncEntity entity,
    String id,
    int stamp,
    int? localStamp,
  ) async {
    if (localStamp != null) return stamp > localStamp;
    final pending = await SyncOutbox.find(_txn, entity, id);
    return pending == null ||
        pending.op != SyncOp.delete ||
        stamp > pending.updatedAt;
  }

  Future<void> _write(
    String table,
    Map<String, Object?> row, {
    required bool exists,
  }) async {
    if (!exists) {
      await _txn.insert(table, row);
      return;
    }
    await _txn.update(
      table,
      {...row}..remove('id'),
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<Map<String, Object?>?> _row(String table, String id) async {
    final rows = await _txn.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int?> _stamp(String table, String id) async =>
      (await _row(table, id))?['updated_at'] as int?;
}
