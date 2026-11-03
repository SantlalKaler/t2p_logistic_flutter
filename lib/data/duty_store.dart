import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// User-scoped, durable outbox. Acknowledgements remove only the sent rows.
class DutyStore {
  Database? _database;
  Future<Database> get database async => _database ??= await openDatabase(
    '${await getDatabasesPath()}/t2p_duty.db',
    version: 1,
    onCreate: (db, _) async {
      await db.execute(
        'CREATE TABLE state (owner TEXT PRIMARY KEY, body TEXT NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE points (id INTEGER PRIMARY KEY AUTOINCREMENT, owner TEXT NOT NULL, session TEXT NOT NULL, at TEXT NOT NULL, body TEXT NOT NULL, UNIQUE(owner, session, at))',
      );
    },
  );
  Future<Map<String, dynamic>> read(String owner) async {
    final rows = await (await database).query(
      'state',
      where: 'owner = ?',
      whereArgs: [owner],
    );
    return rows.isEmpty
        ? {}
        : Map<String, dynamic>.from(jsonDecode(rows.first['body'] as String));
  }

  Future<void> write(String owner, Map<String, dynamic> state) async {
    await (await database).insert('state', {
      'owner': owner,
      'body': jsonEncode(state),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> add(
    String owner,
    String session,
    Map<String, dynamic> point,
  ) async {
    await (await database).insert('points', {
      'owner': owner,
      'session': session,
      'at': point['at'],
      'body': jsonEncode(point),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, Object?>>> batch(
    String owner, {
    String? session,
    List<String> excludeSessions = const [],
  }) async => (await database).query(
    'points',
    where:
        'owner = ?${session == null ? '' : ' AND session = ?'}'
        '${excludeSessions.isEmpty ? '' : ' AND session NOT IN (${List.filled(excludeSessions.length, '?').join(',')})'}',
    whereArgs: [owner, ?session, ...excludeSessions],
    orderBy: 'at ASC, id ASC',
    limit: 500,
  );
  Future<void> acknowledge(List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return;
    await (await database).delete(
      'points',
      where: 'id IN (${List.filled(rows.length, '?').join(',')})',
      whereArgs: rows.map((r) => r['id']).toList(),
    );
  }

  static Map<String, dynamic> point(Map<String, Object?> row) =>
      Map<String, dynamic>.from(jsonDecode(row['body'] as String));
}
