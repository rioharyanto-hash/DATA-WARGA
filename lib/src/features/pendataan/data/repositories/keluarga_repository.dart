import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../models/keluarga_model.dart';
import '../../domain/entities/keluarga.dart';

class KeluargaRepository {
  Future<void> insertKeluarga(Keluarga keluarga) async {
    final db = await LocalDbHelper.database;
    final model = KeluargaModel.fromEntity(keluarga);
    await db.insert(
      'keluarga',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Keluarga>> getKeluargaByKrtId(String krtId) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'keluarga',
      where: 'id_krt = ?',
      whereArgs: [krtId],
    );
    return maps.map((json) => KeluargaModel.fromJson(json)).toList();
  }

  Future<Keluarga?> getKeluargaById(String id) async {
    final db = await LocalDbHelper.database;
    final maps = await db.query(
      'keluarga',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return KeluargaModel.fromJson(maps.first);
  }

  Future<void> updateKeluarga(Keluarga keluarga) async {
    final db = await LocalDbHelper.database;
    final model = KeluargaModel.fromEntity(keluarga);
    await db.update(
      'keluarga',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [keluarga.id],
    );
  }

  Future<void> deleteKeluarga(String id) async {
    final db = await LocalDbHelper.database;
    await db.delete('keluarga', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchKeluargaWithKrtName(
    String query, {
    String? kelompokDawis,
  }) async {
    final db = await LocalDbHelper.database;

    String sql = '''
      SELECT k.id as keluarga_id, 
             k.no_kk, 
             COALESCE(i.nama_lengkap, krt.nama_krt) as nama_krt, 
             i.id as individu_krt_id, 
             b.kelompok_dawis,
             (SELECT GROUP_CONCAT(nama_lengkap, ', ') FROM individu WHERE id_keluarga = k.id AND nama_lengkap IS NOT NULL) as anggota_keluarga
      FROM keluarga k
      LEFT JOIN krt ON k.id_krt = krt.id
      LEFT JOIN bangunan b ON krt.id_bangunan = b.id
      LEFT JOIN individu i ON i.id_keluarga = k.id AND (
        UPPER(i.status_dgn_krt) IN ('KEPALA RUMAH TANGGA', 'KEPALA KELUARGA', 'KK')
        OR UPPER(i.status_dgn_krt) LIKE 'KK %'
        OR UPPER(i.hubungan_keluarga) IN ('KEPALA KELUARGA', 'KK', 'KEPALA RUMAH TANGGA')
        OR UPPER(i.hubungan_keluarga) LIKE 'KK %'
      )
      WHERE (k.no_kk LIKE ? OR COALESCE(i.nama_lengkap, krt.nama_krt) LIKE ? OR EXISTS (SELECT 1 FROM individu WHERE id_keluarga = k.id AND nama_lengkap LIKE ?))
    ''';

    final args = <Object?>['%$query%', '%$query%', '%$query%'];

    if (kelompokDawis != null &&
        kelompokDawis != 'Semua' &&
        kelompokDawis.isNotEmpty) {
      // Apply exact normalization matching as per AGENTS.md rules
      final normalizedDawis = kelompokDawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      sql +=
          " AND REPLACE(REPLACE(LOWER(b.kelompok_dawis), '.', ''), ' ', '') = ?";
      args.add(normalizedDawis);
    }

    sql +=
        ' GROUP BY k.id ORDER BY b.kelompok_dawis ASC, i.nama_lengkap ASC, k.no_kk ASC LIMIT 50';

    final maps = await db.rawQuery(sql, args);
    return maps;
  }
}
