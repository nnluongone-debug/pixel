import 'package:sqflite/sqflite.dart';

/// Which synced table a change belongs to.
enum SyncEntity {
  habit('habit', 'habits'),
  checkIn('checkIn', 'check_ins');

  const SyncEntity(this.key, this.table);

  /// Value stored in `sync_outbox.entity`.
  final String key;

  /// SQLite table holding the rows.
  final String table;

  static SyncEntity fromKey(String key) =>
      values.firstWhere((e) => e.key == key);
}

enum SyncOp { upsert, delete }

/// One queued local change.
class OutboxEntry {
  const OutboxEntry({
    required this.entity,
    required this.id,
    required this.op,
    required this.updatedAt,
  });

  final SyncEntity entity;
  final String id;
  final SyncOp op;

  /// Epoch ms of the local change.
  final int updatedAt;
}

/// `sync_outbox` holds at most one pending change per row: a newer change
/// replaces the older one. Call these inside the mutation's transaction.
abstract final class SyncOutbox {
  static const _table = 'sync_outbox';

  static Future<void> enqueue(
    DatabaseExecutor executor,
    SyncEntity entity,
    String id,
    SyncOp op,
    int updatedAt,
  ) {
    return executor.insert(_table, {
      'entity': entity.key,
      'entity_id': id,
      'op': op.name,
      'updated_at': updatedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Oldest changes first, at most [limit].
  static Future<List<OutboxEntry>> read(
    DatabaseExecutor executor, {
    required int limit,
  }) async {
    final rows = await executor.query(
      _table,
      where: 'quarantined = 0',
      orderBy: 'updated_at ASC, entity_id ASC',
      limit: limit,
    );
    return [
      for (final r in rows)
        OutboxEntry(
          entity: SyncEntity.fromKey(r['entity']! as String),
          id: r['entity_id']! as String,
          op: SyncOp.values.byName(r['op']! as String),
          updatedAt: r['updated_at']! as int,
        ),
    ];
  }

  static Future<OutboxEntry?> find(
    DatabaseExecutor executor,
    SyncEntity entity,
    String id,
  ) async {
    final rows = await executor.query(
      _table,
      where: 'entity = ? AND entity_id = ?',
      whereArgs: [entity.key, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OutboxEntry(
      entity: entity,
      id: id,
      op: SyncOp.values.byName(rows.first['op']! as String),
      updatedAt: rows.first['updated_at']! as int,
    );
  }

  /// Changes still waiting for upload (quarantined ones are excluded).
  static Future<int> count(DatabaseExecutor executor) async {
    final rows = await executor.rawQuery(
      'SELECT COUNT(*) AS n FROM $_table WHERE quarantined = 0',
    );
    return rows.first['n']! as int;
  }

  /// Removes [entries] that were uploaded, unless the row was changed again
  /// meanwhile (its `updated_at` differs), so newer edits stay queued.
  static Future<void> clearUnchanged(
    DatabaseExecutor executor,
    Iterable<OutboxEntry> entries,
  ) async {
    final batch = executor.batch();
    for (final e in entries) {
      batch.delete(
        _table,
        where: 'entity = ? AND entity_id = ? AND updated_at = ?',
        whereArgs: [e.entity.key, e.id, e.updatedAt],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Parks a change the server rejected so it stops blocking uploads. A newer
  /// edit of the row re-queues it normally.
  static Future<void> quarantine(DatabaseExecutor executor, OutboxEntry e) {
    return executor.update(
      _table,
      {'quarantined': 1},
      where: 'entity = ? AND entity_id = ? AND updated_at = ?',
      whereArgs: [e.entity.key, e.id, e.updatedAt],
    );
  }

  static Future<void> remove(
    DatabaseExecutor executor,
    SyncEntity entity,
    String id,
  ) {
    return executor.delete(
      _table,
      where: 'entity = ? AND entity_id = ?',
      whereArgs: [entity.key, id],
    );
  }

  /// Queues every existing row as an upsert (first link of an account).
  /// Rows never stamped (`updated_at = 0`) get [now] first.
  static Future<void> enqueueAll(DatabaseExecutor executor, int now) async {
    for (final entity in SyncEntity.values) {
      await executor.rawUpdate(
        'UPDATE ${entity.table} SET updated_at = ? WHERE updated_at = 0',
        [now],
      );
      await executor.rawInsert(
        'INSERT OR REPLACE INTO $_table '
        '(entity, entity_id, op, updated_at) '
        "SELECT '${entity.key}', id, 'upsert', updated_at "
        'FROM ${entity.table}',
      );
    }
  }
}
