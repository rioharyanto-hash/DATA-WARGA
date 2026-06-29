import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/local_db_helper.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final db = await LocalDbHelper.database;

    // Jumlah Bangunan & KK
    final bangunanCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM bangunan'),
        ) ??
        0;
    final kkCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM keluarga'),
        ) ??
        0;

    // Balita (0 - 5 tahun)
    final balitaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 0 AND 5
    '''),
        ) ??
        0;

    // Lansia (>= 60 tahun)
    final lansiaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) >= 60
    '''),
        ) ??
        0;

    // WUS (Wanita Usia Subur: Perempuan, 15 - 49 tahun)
    final wusCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE jenis_kelamin = 'Perempuan' 
      AND CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 15 AND 49
    '''),
        ) ??
        0;

    // PUS (Pasangan Usia Subur: Perempuan, status Kawin, 15 - 49 tahun)
    // Asumsi nilai status_perkawinan adalah 'Kawin'
    final pusCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE jenis_kelamin = 'Perempuan' 
      AND status_perkawinan = 'Kawin'
      AND CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 15 AND 49
    '''),
        ) ??
        0;

    // Pendidikan Grouping
    final pendidikanRaw = await db.rawQuery(
      'SELECT pendidikan_terakhir, COUNT(*) as count FROM individu GROUP BY pendidikan_terakhir',
    );
    final Map<String, int> pendidikanGrouping = {};
    for (var row in pendidikanRaw) {
      final key = row['pendidikan_terakhir'] as String? ?? 'Tidak Diketahui';
      final count = row['count'] as int? ?? 0;
      pendidikanGrouping[key] = count;
    }

    // Pekerjaan Grouping
    final pekerjaanRaw = await db.rawQuery(
      'SELECT pekerjaan, COUNT(*) as count FROM individu GROUP BY pekerjaan',
    );
    final Map<String, int> pekerjaanGrouping = {};
    for (var row in pekerjaanRaw) {
      final key = row['pekerjaan'] as String? ?? 'Tidak Diketahui';
      final count = row['count'] as int? ?? 0;
      pekerjaanGrouping[key] = count;
    }

    // Jenis Kelamin
    final lakiLakiCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM individu WHERE jenis_kelamin = 'Laki-laki'",
          ),
        ) ??
        0;
    final perempuanCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM individu WHERE jenis_kelamin = 'Perempuan'",
          ),
        ) ??
        0;

    // Umur Grouping
    // 0 - <5 (Balita)
    // 5 - <10 (Anak)
    // 10 - <25 (Remaja)
    // 25 - <60 (Dewasa)
    // >= 60 (Lansia)
    final anakCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) >= 5 
      AND CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) < 10
    '''),
        ) ??
        0;

    final remajaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) >= 10 
      AND CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) < 25
    '''),
        ) ??
        0;

    final dewasaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu 
      WHERE CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) >= 25 
      AND CAST((julianday('now') - julianday(tanggal_lahir)) / 365.25 AS INTEGER) < 60
    '''),
        ) ??
        0;

    final Map<String, int> umurGrouping = {
      'Balita (0-4)': balitaCount,
      'Anak (5-9)': anakCount,
      'Remaja (10-24)': remajaCount,
      'Dewasa (25-59)': dewasaCount,
      'Lansia (>=60)': lansiaCount,
    };

    // Mutasi
    final mutasiCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM mutasi'),
        ) ??
        0;

    return DashboardSummary(
      jumlahBangunan: bangunanCount,
      jumlahKk: kkCount,
      jumlahMutasi: mutasiCount,
      jumlahBalita: balitaCount,
      jumlahLansia: lansiaCount,
      jumlahWus: wusCount,
      jumlahPus: pusCount,
      jumlahLakiLaki: lakiLakiCount,
      jumlahPerempuan: perempuanCount,
      pendidikanGrouping: pendidikanGrouping,
      pekerjaanGrouping: pekerjaanGrouping,
      umurGrouping: umurGrouping,
    );
  }
}
