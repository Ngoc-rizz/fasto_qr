import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'qr_v2.db';
  static const _version = 2;

  Future<Database>? _opening;
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _dbName),
      version: _version,
      onCreate: (db, _) => _createTable(db),
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE qr_items (
        id              TEXT PRIMARY KEY NOT NULL,
        bin             INTEGER NOT NULL,
        bank_name       TEXT NOT NULL,
        bank_short_name TEXT NOT NULL DEFAULT '',
        account_number  TEXT NOT NULL,
        account_name    TEXT,
        amount          INTEGER,
        content         TEXT,
        background      TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await _opening;
    await db?.close();
    _opening = null;
  }
}
