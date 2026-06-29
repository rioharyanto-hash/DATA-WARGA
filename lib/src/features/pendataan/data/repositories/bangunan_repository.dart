import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../models/bangunan_model.dart';
import '../../domain/entities/bangunan.dart';

class BangunanRepository {
  Future<void> insertBangunan(Bangunan bangunan) async {
    final db = await LocalDbHelper.database;
    final model = BangunanModel.fromEntity(bangunan);
    await db.insert(
      'bangunan',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bangunan>> getAllBangunan() async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('bangunan');
    return maps.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByKelompokDawis(String kelompok) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'bangunan',
      where: 'kelompok_dawis = ?',
      whereArgs: [kelompok],
    );
    return maps.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByRw(String rw) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('bangunan', where: 'rw = ?', whereArgs: [rw]);
    return maps.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByRtRw(String rt, String rw) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'bangunan',
      where: 'rt = ? AND rw = ?',
      whereArgs: [rt, rw],
    );
    return maps.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<Bangunan?> getBangunanById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('bangunan', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return BangunanModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateBangunan(Bangunan bangunan) async {
    final db = await LocalDbHelper.database;
    final model = BangunanModel.fromEntity(bangunan);
    await db.update(
      'bangunan',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [bangunan.id],
    );
  }

  Future<void> deleteBangunan(String id) async {
    final db = await LocalDbHelper.database;
    // Hapus bangunan
    await db.delete('bangunan', where: 'id = ?', whereArgs: [id]);
    // Idealnya, hapus juga data KRT, Keluarga, Individu terkait
    // Untuk saat ini kita hapus KRT terkait (cascade manual sederhana)
    final krtList = await db.query(
      'krt',
      columns: ['id'],
      where: 'id_bangunan = ?',
      whereArgs: [id],
    );
    for (var krt in krtList) {
      final krtId = krt['id'];
      final kelList = await db.query(
        'keluarga',
        columns: ['id'],
        where: 'id_krt = ?',
        whereArgs: [krtId],
      );
      for (var kel in kelList) {
        final kelId = kel['id'];
        await db.delete(
          'individu',
          where: 'id_keluarga = ?',
          whereArgs: [kelId],
        );
      }
      await db.delete('keluarga', where: 'id_krt = ?', whereArgs: [krtId]);
    }
    await db.delete('krt', where: 'id_bangunan = ?', whereArgs: [id]);
  }

  Future<List<String>> getDistinctKelompokDawis() async {
    final db = await LocalDbHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT kelompok_dawis FROM bangunan WHERE kelompok_dawis IS NOT NULL AND kelompok_dawis != "" ORDER BY kelompok_dawis ASC',
    );
    return result.map((e) => e['kelompok_dawis'] as String).toList();
  }
}
