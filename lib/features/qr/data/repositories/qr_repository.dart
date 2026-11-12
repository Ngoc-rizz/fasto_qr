import 'package:fasto_qr/core/database/app_database.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:sqflite/sqflite.dart';

class QrRepository {
  final AppDatabase _appDatabase;

  QrRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<void> create(QrModel qr) async {
    final db = await _db;
    final map = qr.toMap();
    final columns = map.keys.join(', ');
    final placeholders = map.keys.map((_) => '?').join(', ');

    await db.rawInsert(
      'INSERT OR ABORT INTO qr_items ($columns) VALUES ($placeholders)',
      map.values.toList(),
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

  Future<void> update(QrModel qr) async {
    final db = await _db;
    final map = qr.toMap();
    final sets = map.keys.map((k) => '$k = ?').join(', ');

    await db.rawUpdate(
      'UPDATE qr_items SET $sets WHERE id = ?',
      [...map.values, qr.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;

    await db.rawDelete('DELETE FROM qr_items WHERE id = ?', [id]);
  }
}
