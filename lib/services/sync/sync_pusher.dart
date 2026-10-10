import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/sync/sync_outbox.dart';
import 'sync_documents.dart';

typedef _Write = (
  OutboxEntry,
  DocumentReference<Map<String, dynamic>>,
  Map<String, Object?>,
);

/// Uploads the outbox to Firestore in batches.
class SyncPusher {
  SyncPusher(this._db, this._firestore, this._collection, this._timeout);

  static const int batchSize = 400;

  final Database _db;
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> Function(SyncEntity)
  _collection;
  final Duration _timeout;

  /// Uploads queued changes until the outbox is empty. An entry is dequeued
  /// only if the row was not changed again while uploading. If the server
  /// rejects a batch with `permission-denied`, its changes are retried one
  /// by one and the rejected ones are quarantined, so a single bad row can
  /// not block everything else.
  Future<void> push() async {
    while (true) {
      final entries = await SyncOutbox.read(_db, limit: batchSize);
      if (entries.isEmpty) return;
      final writes = <_Write>[];
      for (final e in entries) {
        final data = await _document(e);
        if (data != null) {
          writes.add((e, _collection(e.entity).doc(e.id), data));
        }
      }
      try {
        await _commit(writes);
        await SyncOutbox.clearUnchanged(_db, entries);
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
        await _pushOneByOne(writes);
        // Upserts whose row vanished have nothing to send.
        await SyncOutbox.clearUnchanged(
          _db,
          entries.where((e) => !writes.any((w) => identical(w.$1, e))),
        );
      }
      if (entries.length < batchSize) return;
    }
  }

  Future<void> _pushOneByOne(List<_Write> writes) async {
    for (final write in writes) {
      try {
        await _commit([write]);
        await SyncOutbox.clearUnchanged(_db, [write.$1]);
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') rethrow;
        debugPrint(
          'Sync: quarantined ${write.$1.entity.key} ${write.$1.id}: ${e.code}',
        );
        await SyncOutbox.quarantine(_db, write.$1);
      }
    }
  }

  Future<void> _commit(List<_Write> writes) {
    final batch = _firestore.batch();
    for (final (_, ref, data) in writes) {
      batch.set(ref, data);
    }
    return batch.commit().timeout(_timeout);
  }

  /// The document for [e], or null if an upserted row no longer exists.
  Future<Map<String, Object?>?> _document(OutboxEntry e) async {
    if (e.op == SyncOp.delete) {
      return SyncDocuments.tombstone(e.id, e.updatedAt);
    }
    final rows = await _db.query(
      e.entity.table,
      columns: SyncDocuments.columns(e.entity),
      where: 'id = ?',
      whereArgs: [e.id],
      limit: 1,
    );
    return rows.isEmpty ? null : SyncDocuments.fromRow(rows.first);
  }
}
