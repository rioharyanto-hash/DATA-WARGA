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

  Future<void> deleteIndividu(String id) async {
    final db = await LocalDbHelper.database;
    await db.delete(
      'individu',
      where: 'id = ?',
      whereArgs: [id],
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

  Future<List<Individu>> getPenggantiKkCandidates(String keluargaId, String excludeId) async {
    final db = await LocalDbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT * FROM individu 
      WHERE id_keluarga = ? 
      AND id != ?
      AND id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      ''',
      [keluargaId, excludeId],
    );
    return maps.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> getPenggantiKrtCandidates(String bangunanId, String excludeId) async {
    final db = await LocalDbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT individu.* FROM individu 
      JOIN keluarga ON individu.id_keluarga = keluarga.id
      JOIN krt ON keluarga.id_krt = krt.id
      WHERE krt.id_bangunan = ? 
      AND individu.id != ?
      AND (UPPER(individu.hubungan_keluarga) IN ('KK', 'KEPALA KELUARGA'))
      AND individu.id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      ''',
      [bangunanId, excludeId],
    );
    return maps.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> searchIndividu(
    String query, {
    String? kelompokDawis,
  }) async {
    final db = await LocalDbHelper.database;
    if (kelompokDawis != null && kelompokDawis.isNotEmpty) {
      final maps = await db.rawQuery(
        '''
        SELECT individu.* FROM individu 
        JOIN keluarga ON individu.id_keluarga = keluarga.id
        JOIN krt ON keluarga.id_krt = krt.id
        JOIN bangunan ON krt.id_bangunan = bangunan.id
        WHERE individu.nama_lengkap LIKE ? 
        AND bangunan.kelompok_dawis = ?
        AND individu.id NOT IN (
          SELECT id_individu_asal FROM mutasi 
          WHERE id_individu_asal IS NOT NULL 
          AND jenis_mutasi IN ('Meninggal', 'Pindah')
        )
        ''',
        ['%$query%', kelompokDawis],
      );
      return maps.map((json) => IndividuModel.fromJson(json)).toList();
    } else {
      final maps = await db.rawQuery(
        '''
        SELECT * FROM individu 
        WHERE nama_lengkap LIKE ? 
        AND id NOT IN (
          SELECT id_individu_asal FROM mutasi 
          WHERE id_individu_asal IS NOT NULL 
          AND jenis_mutasi IN ('Meninggal', 'Pindah')
        )
        ''',
        ['%$query%'],
      );
      return maps.map((json) => IndividuModel.fromJson(json)).toList();
    }
  }

  Future<Individu?> getIndividuById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query('individu', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return IndividuModel.fromJson(maps.first);
    }
    return null;
  }

  Future<Map<String, String?>> getParentsNames(String idKeluarga) async {
    final db = await LocalDbHelper.database;
    
    // Fetch ayah (Kepala Keluarga and Laki-laki)
    final ayahMaps = await db.query(
      'individu',
      where: "id_keluarga = ? AND UPPER(REPLACE(hubungan_keluarga, '.', '')) IN ('KK', 'KEPALA KELUARGA', 'KEPALA RUMAH TANGGA') AND UPPER(jenis_kelamin) = 'LAKI-LAKI'",
      whereArgs: [idKeluarga],
      limit: 1,
    );
    String? namaAyah;
    if (ayahMaps.isNotEmpty) {
      namaAyah = ayahMaps.first['nama_lengkap'] as String?;
    }

    // Fetch ibu (Istri OR (Kepala Keluarga and Perempuan))
    final ibuMaps = await db.query(
      'individu',
      where: "id_keluarga = ? AND (UPPER(REPLACE(hubungan_keluarga, '.', '')) = 'ISTRI' OR (UPPER(REPLACE(hubungan_keluarga, '.', '')) IN ('KK', 'KEPALA KELUARGA', 'KEPALA RUMAH TANGGA') AND UPPER(jenis_kelamin) = 'PEREMPUAN'))",
      whereArgs: [idKeluarga],
      limit: 1,
    );
    String? namaIbu;
    if (ibuMaps.isNotEmpty) {
      namaIbu = ibuMaps.first['nama_lengkap'] as String?;
    }

    return {
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
    };
  }
}
