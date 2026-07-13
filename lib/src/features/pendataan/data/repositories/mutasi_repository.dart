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
    // by setting id_bangunan to empty string so they are not lost.
    await db.rawUpdate('''
        UPDATE mutasi 
        SET id_bangunan = ''
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
    final normalizedName =
        kelompokDawis.replaceAll('.', '').replaceAll(' ', '').toLowerCase();

    final maps = await db.rawQuery(
      '''
      SELECT mutasi.*, bangunan.kelompok_dawis as b_kelompok_dawis FROM mutasi
      JOIN bangunan ON mutasi.id_bangunan = bangunan.id
      ORDER BY mutasi.tanggal_mutasi DESC
    ''',
    );

    return maps.where((json) {
      final dbName = json['b_kelompok_dawis']?.toString() ?? '';
      final normalizedDbName =
          dbName.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
      return normalizedDbName == normalizedName;
    }).map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getLampidReportData({
    String? kelompokDawis,
    String? bulan,
    String? tahun,
  }) async {
    final db = await LocalDbHelper.database;
    
    String dateFilter = "";
    List<dynamic> args = [];
    
    if (bulan != null && tahun != null) {
      // bulan is expected to be '01' through '12'
      dateFilter = " AND substr(mutasi.tanggal_mutasi, 1, 7) = ?";
      args.add("$tahun-$bulan");
    }

    final maps = await db.rawQuery(
      '''
      SELECT 
        mutasi.*, 
        bangunan.nama_bangunan, 
        bangunan.alamat_lengkap, 
        bangunan.kelompok_dawis as b_kelompok_dawis,
        individu.jenis_kelamin,
        individu.tanggal_lahir
      FROM mutasi
      LEFT JOIN bangunan ON mutasi.id_bangunan = bangunan.id
      LEFT JOIN individu ON mutasi.id_individu_asal = individu.id
      WHERE 1=1 $dateFilter
      ORDER BY mutasi.tanggal_mutasi ASC
    ''',
      args
    );

    if (kelompokDawis != null && kelompokDawis.isNotEmpty && kelompokDawis != 'Semua Dawis') {
      final normalizedName = kelompokDawis.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
      return maps.where((json) {
        final dbName = json['b_kelompok_dawis']?.toString() ?? '';
        final normalizedDbName = dbName.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
        return normalizedDbName == normalizedName;
      }).toList();
    }
    
    return maps;
  }
}
