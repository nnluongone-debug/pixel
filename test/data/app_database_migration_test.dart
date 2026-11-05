import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('v1 database upgrades to the latest schema and keeps habits', () async {
    final dir = await Directory.systemTemp.createTemp('pixel_quest_mig');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'v1.db');
    final factory = databaseFactoryFfiNoIsolate;

    // Schema exactly as shipped in v1 (no `unit` column).
    final v1 = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE habits (
              id TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT NOT NULL,
              target INTEGER NOT NULL, current_progress INTEGER NOT NULL,
              color_hex TEXT NOT NULL, icon_name TEXT NOT NULL,
              created_at TEXT NOT NULL, progress_date TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE check_ins (
              id TEXT PRIMARY KEY, habit_id TEXT NOT NULL, date TEXT NOT NULL,
              xp_earned INTEGER NOT NULL, grid_x INTEGER NOT NULL,
              grid_y INTEGER NOT NULL
            )
          ''');
          await db.insert('habits', {
            'id': 'h1',
            'name': 'Drink Water',
            'type': 'counter',
            'target': 8,
            'current_progress': 5,
            'color_hex': '#00E5FF',
            'icon_name': 'water_drop',
            'created_at': '2026-10-01T00:00:00.000Z',
          });
        },
      ),
    );
    await v1.close();

    final db = await AppDatabase.open(factory: factory, path: path);
    addTearDown(db.close);
    expect(await db.getVersion(), AppDatabase.schemaVersion);

    final habit = Habit.fromMap((await db.query('habits')).single);
    expect(
      (habit.name, habit.currentProgress, habit.unit),
      ('Drink Water', 5, ''),
    );
    expect((await db.query('habits')).single['updated_at'], 0);
    expect(await db.query('sync_outbox'), isEmpty);
  });

  Future<Set<String>> columns(Database db, String table) async => {
    for (final r in await db.rawQuery('PRAGMA table_info($table)'))
      r['name']! as String,
  };

  test('v1 and v3 databases gain updated_at and sync_outbox', () async {
    final dir = await Directory.systemTemp.createTemp('pixel_quest_mig4');
    addTearDown(() => dir.delete(recursive: true));
    final factory = databaseFactoryFfiNoIsolate;

    // v3: habits with schedule columns, check_ins without updated_at.
    final v3Path = p.join(dir.path, 'v3.db');
    final v3 = await factory.openDatabase(
      v3Path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE habits (id TEXT PRIMARY KEY, name TEXT NOT NULL, '
            'type TEXT NOT NULL, target INTEGER NOT NULL, '
            'current_progress INTEGER NOT NULL, color_hex TEXT NOT NULL, '
            "icon_name TEXT NOT NULL, unit TEXT NOT NULL DEFAULT '', "
            'schedule_days INTEGER NOT NULL DEFAULT 127, '
            'reminder_minutes INTEGER, created_at TEXT NOT NULL, '
            'progress_date TEXT)',
          );
          await db.execute(
            'CREATE TABLE check_ins (id TEXT PRIMARY KEY, '
            'habit_id TEXT NOT NULL, date TEXT NOT NULL, '
            'xp_earned INTEGER NOT NULL, grid_x INTEGER NOT NULL, '
            'grid_y INTEGER NOT NULL)',
          );
          await db.insert('habits', {
            'id': 'h1',
            'name': 'Read',
            'type': 'checklist',
            'target': 1,
            'current_progress': 0,
            'color_hex': '#00FF66',
            'icon_name': 'book',
            'created_at': '2026-10-01T00:00:00.000Z',
          });
        },
      ),
    );
    await v3.close();

    final db = await AppDatabase.open(factory: factory, path: v3Path);
    addTearDown(db.close);
    expect(await db.getVersion(), AppDatabase.schemaVersion);
    expect(await columns(db, 'habits'), contains('updated_at'));
    expect(await columns(db, 'check_ins'), contains('updated_at'));
    expect((await db.query('habits')).single['updated_at'], 0);
    expect(await db.query('sync_outbox'), isEmpty);
    await db.insert('sync_outbox', {
      'entity': 'habit',
      'entity_id': 'h1',
      'op': 'upsert',
      'updated_at': 1,
    });
    expect(
      () => db.insert('sync_outbox', {
        'entity': 'other',
        'entity_id': 'x',
        'op': 'upsert',
        'updated_at': 1,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('fresh install has the latest sync schema', () async {
    final db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    addTearDown(db.close);
    expect(await columns(db, 'habits'), contains('updated_at'));
    expect(await columns(db, 'check_ins'), contains('updated_at'));
    expect(await columns(db, 'sync_outbox'), {
      'entity',
      'entity_id',
      'op',
      'updated_at',
      'quarantined',
    });
  });

  test('v4 outbox gains the quarantined column in v5', () async {
    final factory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('pixel_quest_mig5');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'v4.db');
    final old = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, _) async {
          // Minimal v4 habits table: later migrations alter it.
          await db.execute(
            'CREATE TABLE habits (id TEXT PRIMARY KEY, '
            'reminder_minutes INTEGER)',
          );
          await db.insert('habits', {'id': 'h', 'reminder_minutes': 1230});
          await db.execute(
            'CREATE TABLE sync_outbox (entity TEXT NOT NULL, '
            'entity_id TEXT NOT NULL, op TEXT NOT NULL, '
            'updated_at INTEGER NOT NULL, PRIMARY KEY (entity, entity_id))',
          );
          await db.insert('sync_outbox', {
            'entity': 'habit',
            'entity_id': 'h',
            'op': 'upsert',
            'updated_at': 1,
          });
        },
      ),
    );
    await old.close();
    final db = await AppDatabase.open(factory: factory, path: path);
    addTearDown(db.close);
    expect((await db.query('sync_outbox')).single['quarantined'], 0);
    // v6 copies the single reminder into the multi-time column.
    expect((await db.query('habits')).single['reminder_times'], '1230');
    // v7 adds the repeat window with its defaults.
    final habit = (await db.query('habits')).single;
    expect(
      [habit['reminder_every'], habit['reminder_from'], habit['reminder_to']],
      [null, 480, 1320],
    );
  });
}
