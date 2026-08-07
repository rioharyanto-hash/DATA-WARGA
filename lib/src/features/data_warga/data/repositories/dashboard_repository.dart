import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/database/local_db_helper.dart';
import '../../../settings/domain/entities/app_user.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

class DashboardRepository {
  String _buildFilterCondition(AppUser user, {String? rtFilter}) {
    List<String> conditions = [];
    if (user.role == 'RW') {
      conditions.add("bangunan.rw = '${user.rw}'");
    } else if (user.role == 'RT') {
      conditions.add(
        "bangunan.rw = '${user.rw}' AND bangunan.rt = '${user.rt}'",
      );
    } else if (user.role == 'KADER') {
      conditions.add("bangunan.kelompok_dawis = '${user.kelompokDawis}'");
    }

    if (rtFilter != null && rtFilter.isNotEmpty && rtFilter != 'Semua') {
      final rtInt = int.tryParse(rtFilter);
      if (rtInt != null) {
        conditions.add(
          "(bangunan.rt = '$rtFilter' OR CAST(bangunan.rt AS INTEGER) = $rtInt)",
        );
      } else {
        conditions.add("bangunan.rt = '$rtFilter'");
      }
    }

    if (conditions.isEmpty) {
      return "1=1";
    }
    return conditions.join(" AND ");
  }

  Future<Map<String, dynamic>> getDemografiAgregat(
    AppUser user, {
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);

    // Total KK
    final kkResult = await db.rawQuery(
      "SELECT COUNT(keluarga.id) as total FROM keluarga JOIN krt ON keluarga.id_krt = krt.id JOIN bangunan ON krt.id_bangunan = bangunan.id WHERE $filter",
    );
    final totalKk = SqfliteUtils.firstIntValue(kkResult) ?? 0;

    final individuJoin =
        "FROM individu JOIN keluarga ON individu.id_keluarga = keluarga.id JOIN krt ON keluarga.id_krt = krt.id JOIN bangunan ON krt.id_bangunan = bangunan.id WHERE $filter";

    final aggregatedResult = await db.rawQuery('''
      SELECT 
        COUNT(individu.id) as totalWarga,
        SUM(CASE WHEN individu.jenis_kelamin = 'Laki-laki' THEN 1 ELSE 0 END) as totalLaki,
        SUM(CASE WHEN individu.jenis_kelamin = 'Perempuan' THEN 1 ELSE 0 END) as totalPerempuan,
        SUM(CASE WHEN UPPER(individu.status_yatim_piatu) IN ('YATIM', 'PIATU', 'YATIM PIATU', 'YATIM (AUTO)') THEN 1 ELSE 0 END) as totalYatim,
        SUM(CASE WHEN UPPER(individu.status_yatim_piatu) IN ('YATIM', 'YATIM (AUTO)') THEN 1 ELSE 0 END) as yatimOnly,
        SUM(CASE WHEN UPPER(individu.status_yatim_piatu) = 'PIATU' THEN 1 ELSE 0 END) as piatuOnly,
        SUM(CASE WHEN UPPER(individu.status_yatim_piatu) = 'YATIM PIATU' THEN 1 ELSE 0 END) as yatimPiatu,
        SUM(CASE WHEN individu.kriteria_berkebutuhan_khusus IS NOT NULL AND individu.kriteria_berkebutuhan_khusus != '' AND UPPER(individu.kriteria_berkebutuhan_khusus) NOT IN ('TIDAK ADA', 'TIDAK') THEN 1 ELSE 0 END) as totalDifabel,
        SUM(CASE WHEN individu.jenis_bantuan IS NOT NULL AND individu.jenis_bantuan != '' AND individu.jenis_bantuan != 'Tidak Ada' THEN 1 ELSE 0 END) as totalBansos
      $individuJoin
    ''');

    int totalWarga = 0;
    int totalLaki = 0;
    int totalPerempuan = 0;
    int totalYatim = 0;
    int yatimOnly = 0;
    int piatuOnly = 0;
    int yatimPiatu = 0;
    int totalDifabel = 0;
    int totalBansos = 0;

    if (aggregatedResult.isNotEmpty) {
      final row = aggregatedResult.first;
      totalWarga = (row['totalWarga'] as num?)?.toInt() ?? 0;
      totalLaki = (row['totalLaki'] as num?)?.toInt() ?? 0;
      totalPerempuan = (row['totalPerempuan'] as num?)?.toInt() ?? 0;
      totalYatim = (row['totalYatim'] as num?)?.toInt() ?? 0;
      yatimOnly = (row['yatimOnly'] as num?)?.toInt() ?? 0;
      piatuOnly = (row['piatuOnly'] as num?)?.toInt() ?? 0;
      yatimPiatu = (row['yatimPiatu'] as num?)?.toInt() ?? 0;
      totalDifabel = (row['totalDifabel'] as num?)?.toInt() ?? 0;
      totalBansos = (row['totalBansos'] as num?)?.toInt() ?? 0;
    }

    return {
      'totalKk': totalKk,
      'totalWarga': totalWarga,
      'totalLaki': totalLaki,
      'totalPerempuan': totalPerempuan,
      'totalYatim': totalYatim,
      'yatimOnly': yatimOnly,
      'piatuOnly': piatuOnly,
      'yatimPiatu': yatimPiatu,
      'totalDifabel': totalDifabel,
      'totalBansos': totalBansos,
    };
  }

  Future<List<Map<String, dynamic>>> getDetailPenerimaBansos(
    AppUser user, {
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);
    final res = await db.rawQuery('''
      SELECT 
        individu.nama_lengkap, 
        individu.nik, 
        individu.jenis_bantuan, 
        individu.jumlah_bantuan, 
        bangunan.rt, 
        bangunan.rw 
      FROM individu 
      JOIN keluarga ON individu.id_keluarga = keluarga.id 
      JOIN krt ON keluarga.id_krt = krt.id
      JOIN bangunan ON krt.id_bangunan = bangunan.id 
      WHERE $filter 
        AND individu.jenis_bantuan IS NOT NULL 
        AND individu.jenis_bantuan != '' 
        AND individu.jenis_bantuan != 'Tidak Ada'
      ORDER BY bangunan.rw ASC, bangunan.rt ASC, individu.nama_lengkap ASC
    ''');
    return res;
  }

  Future<List<Map<String, dynamic>>> getDetailYatimPiatu(
    AppUser user, {
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);
    final res = await db.rawQuery('''
      SELECT 
        individu.nama_lengkap, 
        individu.nik, 
        individu.status_yatim_piatu, 
        individu.tanggal_lahir, 
        bangunan.rt, 
        bangunan.rw 
      FROM individu 
      JOIN keluarga ON individu.id_keluarga = keluarga.id 
      JOIN krt ON keluarga.id_krt = krt.id
      JOIN bangunan ON krt.id_bangunan = bangunan.id 
      WHERE $filter 
        AND UPPER(individu.status_yatim_piatu) IN ('YATIM', 'PIATU', 'YATIM PIATU', 'YATIM (AUTO)')
      ORDER BY bangunan.rw ASC, bangunan.rt ASC, individu.nama_lengkap ASC
    ''');
    return res;
  }

  Future<List<Map<String, dynamic>>> getDetailDisabilitas(
    AppUser user, {
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);
    final res = await db.rawQuery('''
      SELECT 
        individu.nama_lengkap, 
        individu.nik, 
        individu.kriteria_berkebutuhan_khusus, 
        bangunan.rt, 
        bangunan.rw 
      FROM individu 
      JOIN keluarga ON individu.id_keluarga = keluarga.id 
      JOIN krt ON keluarga.id_krt = krt.id
      JOIN bangunan ON krt.id_bangunan = bangunan.id 
      WHERE $filter 
        AND individu.kriteria_berkebutuhan_khusus IS NOT NULL 
        AND individu.kriteria_berkebutuhan_khusus != '' 
        AND UPPER(individu.kriteria_berkebutuhan_khusus) NOT IN ('TIDAK ADA', 'TIDAK')
      ORDER BY bangunan.rw ASC, bangunan.rt ASC, individu.nama_lengkap ASC
    ''');
    return res;
  }

  Future<List<Map<String, dynamic>>> getDetailKk(
    AppUser user, {
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);
    final res = await db.rawQuery('''
      SELECT 
        keluarga.no_kk, 
        krt.nama_krt,
        bangunan.rt, 
        bangunan.rw 
      FROM keluarga 
      JOIN krt ON keluarga.id_krt = krt.id
      JOIN bangunan ON krt.id_bangunan = bangunan.id 
      WHERE $filter 
      ORDER BY bangunan.rw ASC, bangunan.rt ASC, krt.nama_krt ASC
    ''');
    return res;
  }

  Future<List<Map<String, dynamic>>> getDetailWarga(
    AppUser user, {
    String? jenisKelamin,
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;
    final filter = _buildFilterCondition(user, rtFilter: rtFilter);

    String genderFilter = '';
    if (jenisKelamin != null) {
      genderFilter = "AND individu.jenis_kelamin = '$jenisKelamin'";
    }

    final res = await db.rawQuery('''
      SELECT 
        individu.nama_lengkap, 
        individu.nik, 
        individu.jenis_kelamin, 
        individu.tanggal_lahir, 
        bangunan.rt, 
        bangunan.rw 
      FROM individu 
      JOIN keluarga ON individu.id_keluarga = keluarga.id 
      JOIN krt ON keluarga.id_krt = krt.id
      JOIN bangunan ON krt.id_bangunan = bangunan.id 
      WHERE $filter 
        $genderFilter
      ORDER BY bangunan.rw ASC, bangunan.rt ASC, individu.nama_lengkap ASC
    ''');
    return res;
  }
}

class SqfliteUtils {
  static int? firstIntValue(List<Map<String, Object?>> list) {
    if (list.isNotEmpty && list.first.values.isNotEmpty) {
      final value = list.first.values.first;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }
}
