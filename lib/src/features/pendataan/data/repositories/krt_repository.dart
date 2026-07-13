import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../models/krt_model.dart';
import '../../domain/entities/krt.dart';

class KrtRepository {
  Future<void> insertKrt(Krt krt) async {
    final db = await LocalDbHelper.database;
    final model = KrtModel.fromEntity(krt);
    await db.insert(
      'krt',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Krt>> getKrtByBangunanId(String bangunanId) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'krt',
      where: 'id_bangunan = ?',
      whereArgs: [bangunanId],
    );
    return maps.map((json) => KrtModel.fromJson(json)).toList();
  }

  Future<Krt?> getKrtById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'krt',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return KrtModel.fromJson(maps.first);
  }

  Future<void> updateKrt(Krt krt) async {
    final db = await LocalDbHelper.database;
    final model = KrtModel.fromEntity(krt);
    await db.update(
      'krt',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [krt.id],
    );
  }

  Future<void> updateKrtNameAndNik(String krtId, String newName, String newNik) async {
    final db = await LocalDbHelper.database;
    await db.update(
      'krt',
      {
        'nama_krt': newName,
        'nik_krt': newNik,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [krtId],
    );
  }

  Future<void> deleteKrt(String id) async {
    final db = await LocalDbHelper.database;
    await db.delete('krt', where: 'id = ?', whereArgs: [id]);
  }
}
