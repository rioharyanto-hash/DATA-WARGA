import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../models/mutasi_model.dart';
import '../../domain/entities/mutasi.dart';

class MutasiRepository {
  Future<void> insertMutasi(Mutasi mutasi) async {
    final db = await LocalDbHelper.database;
    final model = MutasiModel.fromEntity(mutasi);
    await db.insert(
      'mutasi',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Mutasi>> getMutasiByBangunan(String idBangunan) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'mutasi',
      where: 'id_bangunan = ?',
      whereArgs: [idBangunan],
      orderBy: 'tanggal_mutasi DESC',
    );
    return maps.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Mutasi>> getMutasiByIndividuAsal(String idIndividuAsal) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'mutasi',
      where: 'id_individu_asal = ?',
      whereArgs: [idIndividuAsal],
      orderBy: 'tanggal_mutasi DESC',
    );
    return maps.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Mutasi>> getAllMutasi() async {
    final db = await LocalDbHelper.database;

    // Clean up orphaned mutasi (where id_bangunan doesn't exist in bangunan table)
    // but only if id_bangunan is not empty, because some mutasi are created without id_bangunan.
    await db.rawDelete('''
      DELETE FROM mutasi 
      WHERE id_bangunan != '' AND id_bangunan NOT IN (SELECT id FROM bangunan)
    ''');

    final maps = await db.query('mutasi', orderBy: 'tanggal_mutasi DESC');
    return maps.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<void> deleteMutasi(String id) async {
    final db = await LocalDbHelper.database;
    await db.delete('mutasi', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Mutasi>> getMutasiByKelompokDawis(String kelompokDawis) async {
    final db = await LocalDbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT mutasi.* FROM mutasi
      JOIN bangunan ON mutasi.id_bangunan = bangunan.id
      WHERE bangunan.kelompok_dawis = ?
      ORDER BY mutasi.tanggal_mutasi DESC
    ''',
      [kelompokDawis],
    );
    return maps.map((json) => MutasiModel.fromJson(json)).toList();
  }
}
