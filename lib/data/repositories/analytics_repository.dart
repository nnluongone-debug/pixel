import 'package:sqflite/sqflite.dart';

import '../../domain/analytics/check_in_record.dart';

/// Read-only history queries for the analytics screen. All calendar math
/// lives in `domain/analytics`; this class only fetches rows.
class AnalyticsRepository {
  AnalyticsRepository(this._db);

  final Database _db;

  /// Every check-in, oldest first.
  Future<List<CheckInRecord>> getCheckInRecords() async {
    final rows = await _db.query(
      'check_ins',
      columns: ['habit_id', 'grid_x', 'xp_earned'],
      orderBy: 'grid_x ASC, id ASC',
    );
    return [
      for (final row in rows)
        CheckInRecord(
          habitId: row['habit_id']! as String,
          epochDay: row['grid_x']! as int,
          xp: row['xp_earned']! as int,
        ),
    ];
  }
}
