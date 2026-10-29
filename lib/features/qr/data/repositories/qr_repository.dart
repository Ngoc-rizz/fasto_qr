import 'package:fasto_qr/core/database/app_database.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:sqflite/sqflite.dart';

class QrRepository {
  final AppDatabase _appDatabase;

  QrRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<int> create(QrModel qr) async {
    final db = await _db;

    return db.insert(
      'qr_items',
      qr.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<QrModel>> getAll() async {
    final db = await _db;

    final maps = await db.query('qr_items', orderBy: 'rowid DESC');

    return maps.map(QrModel.fromMap).toList();
  }

  Future<QrModel?> getById(String id) async {
    final db = await _db;

    final maps = await db.query(
      'qr_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return QrModel.fromMap(maps.first);
  }

  Future<int> update(QrModel qr) async {
    final db = await _db;

    return db.update(
      'qr_items',
      qr.toMap(),
      where: 'id = ?',
      whereArgs: [qr.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;

    return db.delete('qr_items', where: 'id = ?', whereArgs: [id]);
  }
}
