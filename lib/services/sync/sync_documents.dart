import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/check_in.dart';
import '../../data/models/habit.dart';
import '../../data/sync/sync_outbox.dart';

/// Conversion between SQLite rows (snake_case) and Firestore documents
/// (camelCase keys, plus `updatedAt`, `deleted` and the server-set
/// `syncedAt` that pull uses as its watermark).
abstract final class SyncDocuments {
  static List<String> columns(SyncEntity entity) =>
      entity == SyncEntity.habit ? _habitColumns : _checkInColumns;

  static const _habitColumns = [
    'id',
    'name',
    'type',
    'target',
    'current_progress',
    'color_hex',
    'icon_name',
    'unit',
    'schedule_days',
    'reminder_minutes',
    'created_at',
    'progress_date',
    'updated_at',
  ];

  static const _checkInColumns = [
    'id',
    'habit_id',
    'date',
    'xp_earned',
    'grid_x',
    'grid_y',
    'updated_at',
  ];

  static String _camel(String column) =>
      column.replaceAllMapped(RegExp('_([a-z])'), (m) => m[1]!.toUpperCase());

  static Map<String, Object?> fromRow(Map<String, Object?> row) => {
    for (final e in row.entries) _camel(e.key): e.value,
    'deleted': false,
    'syncedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, Object?> tombstone(String id, int updatedAt) => {
    'id': id,
    'updatedAt': updatedAt,
    'deleted': true,
    'syncedAt': FieldValue.serverTimestamp(),
  };

  /// The local row for a remote [doc], or null if it is malformed. Only
  /// known columns are read, and values are checked by the models.
  static Map<String, Object?>? toRow(
    SyncEntity entity,
    Map<String, Object?> doc,
  ) {
    final row = <String, Object?>{
      for (final c in columns(entity)) c: _normalize(doc[_camel(c)]),
    };
    try {
      if (row['updated_at'] is! int) return null;
      if (entity == SyncEntity.habit) {
        Habit.fromMap(row);
      } else {
        CheckIn.fromMap(row);
      }
      return row;
    } on Object {
      return null;
    }
  }

  /// Firestore may hand back whole numbers as doubles.
  static Object? _normalize(Object? value) =>
      value is double && value == value.truncateToDouble()
      ? value.toInt()
      : value;
}
