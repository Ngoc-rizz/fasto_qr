import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'qr_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE qr_items (
            id TEXT PRIMARY KEY,
            bin INTEGER NOT NULL,
            bank_name TEXT NOT NULL,
            bank_short_name TEXT NOT NULL,
            account_number TEXT NOT NULL,
            account_name TEXT,
            amount INTEGER,
            content TEXT,
            background TEXT
          )
        ''');
      },
    );
  }
}
