import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../models/individu_model.dart';
import '../../domain/entities/individu.dart';

class IndividuRepository {
  Future<void> insertIndividu(Individu individu) async {
    final db = await LocalDbHelper.database;
    final model = IndividuModel.fromEntity(individu);
    await db.insert(
      'individu',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIndividu(Individu individu) async {
    final db = await LocalDbHelper.database;
    final model = IndividuModel.fromEntity(individu);
    await db.update(
      'individu',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [individu.id],
    );
  }

  Future<List<Individu>> getIndividuByKeluargaId(String keluargaId) async {
    final db = await LocalDbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM individu 
      WHERE id_keluarga = ? 
      AND id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      ''',
      [keluargaId],
    );
    return maps.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> searchIndividu(String query) async {
    final db = await LocalDbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM individu 
      WHERE nama_lengkap LIKE ? 
      AND id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      LIMIT 20
      ''',
      ['%$query%'],
    );
    return maps.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<Individu?> getIndividuById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('individu', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return IndividuModel.fromJson(maps.first);
    }
    return null;
  }
}
