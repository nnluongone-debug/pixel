import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/user_stats.dart';

/// Opens the local SQLite database and owns the schema.
abstract final class AppDatabase {
  static const String fileName = 'pixel_quest.db';
  static const int schemaVersion = 7;

  /// Opens (and creates on first run) the database.
  ///
  /// [factory] and [path] are overridable for tests, e.g. the FFI factory
  /// with [inMemoryDatabasePath].
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), fileName);
    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => _createSchema(db),
        onUpgrade: _migrate,
      ),
    );
  }

  /// Step-by-step upgrades; each block brings the schema up one version.
  static Future<void> _migrate(Database db, int from, int to) async {
    if (from < 2) {
      await db.execute(
        "ALTER TABLE habits ADD COLUMN unit TEXT NOT NULL DEFAULT ''",
      );
    }
    if (from < 3) {
      await db.execute(
        'ALTER TABLE habits ADD COLUMN schedule_days INTEGER NOT NULL '
        'DEFAULT 127',
      );
      await db.execute(
        'ALTER TABLE habits ADD COLUMN reminder_minutes INTEGER',
      );
    }
    if (from < 4) {
      await db.execute(
        'ALTER TABLE habits ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE check_ins ADD COLUMN updated_at INTEGER NOT NULL '
        'DEFAULT 0',
      );
      await db.execute(_outboxSql);
    } else if (from < 5) {
      await db.execute(
        'ALTER TABLE sync_outbox ADD COLUMN quarantined INTEGER NOT NULL '
        'DEFAULT 0',
      );
    }
    if (from < 6) {
      // Multi-time reminders; `reminder_minutes` stays as an unused legacy
      // column (SQLite can't drop it cheaply).
      await db.execute(
        "ALTER TABLE habits ADD COLUMN reminder_times TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        'UPDATE habits SET reminder_times = CAST(reminder_minutes AS TEXT) '
        'WHERE reminder_minutes IS NOT NULL',
      );
    }
    if (from < 7) {
      // "Every N minutes" reminders within a daily window.
      for (final column in const [
        'reminder_every INTEGER',
        'reminder_from INTEGER NOT NULL DEFAULT 480',
        'reminder_to INTEGER NOT NULL DEFAULT 1320',
      ]) {
        await db.execute('ALTER TABLE habits ADD COLUMN $column');
      }
    }
  }

  /// Local changes waiting to be uploaded; one row per synced entity.
  /// `quarantined` marks changes the server rejected for good; they are
  /// skipped until the row is edited again.
  static const String _outboxSql = '''
      CREATE TABLE sync_outbox (
        entity TEXT NOT NULL CHECK (entity IN ('habit', 'checkIn')),
        entity_id TEXT NOT NULL,
        op TEXT NOT NULL CHECK (op IN ('upsert', 'delete')),
        updated_at INTEGER NOT NULL,
        quarantined INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (entity, entity_id)
      )
    ''';

  static Future<void> _createSchema(Database db) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('counter', 'checklist', 'timer')),
        target INTEGER NOT NULL CHECK (target > 0),
        current_progress INTEGER NOT NULL DEFAULT 0
          CHECK (current_progress >= 0),
        color_hex TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        unit TEXT NOT NULL DEFAULT '',
        schedule_days INTEGER NOT NULL DEFAULT 127
          CHECK (schedule_days BETWEEN 1 AND 127),
        reminder_minutes INTEGER
          CHECK (reminder_minutes BETWEEN 0 AND 1439),
        reminder_times TEXT NOT NULL DEFAULT '',
        reminder_every INTEGER CHECK (reminder_every BETWEEN 5 AND 720),
        reminder_from INTEGER NOT NULL DEFAULT 480,
        reminder_to INTEGER NOT NULL DEFAULT 1320,
        created_at TEXT NOT NULL,
        progress_date TEXT,
        updated_at INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute('''
      CREATE TABLE check_ins (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
        date TEXT NOT NULL,
        xp_earned INTEGER NOT NULL CHECK (xp_earned >= 0),
        grid_x INTEGER NOT NULL,
        grid_y INTEGER NOT NULL CHECK (grid_y >= 0),
        updated_at INTEGER NOT NULL DEFAULT 0,
        UNIQUE (habit_id, date)
      )
    ''');
    batch.execute(_outboxSql);
    batch.execute('CREATE INDEX idx_check_ins_date ON check_ins (date)');
    batch.execute('CREATE INDEX idx_check_ins_grid_x ON check_ins (grid_x)');
    batch.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        current_level INTEGER NOT NULL,
        current_xp INTEGER NOT NULL,
        target_xp INTEGER NOT NULL,
        streak_days INTEGER NOT NULL
      )
    ''');
    batch.insert('user_stats', {'id': 1, ...UserStats.initial.toMap()});
    await batch.commit(noResult: true);
  }
}
