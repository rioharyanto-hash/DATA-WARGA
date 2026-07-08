import 'dart:io';

void main() async {
  final file = File('lib/src/features/dashboard/data/repositories/dashboard_repository_impl.dart');
  
  final content = """import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/local_db_helper.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<Map<String, List<String>>> getFilterOptions() async {
    final db = await LocalDbHelper.database;
    final rwList = await db.rawQuery('SELECT DISTINCT rw FROM bangunan WHERE rw IS NOT NULL AND rw != "" ORDER BY rw');
    final rtList = await db.rawQuery('SELECT DISTINCT rt FROM bangunan WHERE rt IS NOT NULL AND rt != "" ORDER BY rt');
    final kaderList = await db.rawQuery('SELECT DISTINCT kelompok_dawis FROM bangunan WHERE kelompok_dawis IS NOT NULL AND kelompok_dawis != "" ORDER BY kelompok_dawis');

    return {
      'rw': rwList.map((e) => e['rw'].toString()).toList(),
      'rt': rtList.map((e) => e['rt'].toString()).toList(),
      'kader': kaderList.map((e) => e['kelompok_dawis'].toString()).toList(),
    };
  }

  @override
  Future<DashboardSummary> getDashboardSummary({
    String? rw,
    String? rt,
    String? kelompokDawis,
  }) async {
    final db = await LocalDbHelper.database;

    String bJoin = '';
    String bWhere = '1=1';
    List<Object?> bParams = [];
    
    if (rw != null && rw.isNotEmpty) {
      bWhere += ' AND b.rw = ?';
      bParams.add(rw);
    }
    if (rt != null && rt.isNotEmpty) {
      bWhere += ' AND b.rt = ?';
      bParams.add(rt);
    }
    if (kelompokDawis != null && kelompokDawis.isNotEmpty) {
      bWhere += ' AND b.kelompok_dawis = ?';
      bParams.add(kelompokDawis);
    }
    
    String bangunanWhere = bWhere.replaceAll('b.', '');
    
    String keluargaJoin = 'JOIN krt k ON kel.id_krt = k.id JOIN bangunan b ON k.id_bangunan = b.id';
    String individuJoin = 'JOIN keluarga kel ON i.id_keluarga = kel.id JOIN krt k ON kel.id_krt = k.id JOIN bangunan b ON k.id_bangunan = b.id';

    // Jumlah Bangunan & KK
    final bangunanCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM bangunan b WHERE \$bangunanWhere', bParams),
        ) ??
        0;
    final kkCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM keluarga kel \$keluargaJoin WHERE \$bWhere', bParams),
        ) ??
        0;

    // Balita (0 - 5 tahun)
    final balitaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 0 AND 5
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    // Lansia (>= 60 tahun)
    final lansiaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) >= 60
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    // WUS (Wanita Usia Subur: Perempuan, 15 - 49 tahun)
    final wusCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE i.jenis_kelamin = 'Perempuan' 
      AND CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 15 AND 49
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    // PUS (Pasangan Usia Subur: Perempuan, status Kawin, 15 - 49 tahun)
    final pusCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE i.jenis_kelamin = 'Perempuan' 
      AND i.status_perkawinan = 'Kawin'
      AND CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) BETWEEN 15 AND 49
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    // Pendidikan Grouping
    final pendidikanRaw = await db.rawQuery(
      'SELECT i.pendidikan_terakhir, COUNT(*) as count FROM individu i \$individuJoin WHERE \$bWhere GROUP BY i.pendidikan_terakhir', bParams
    );
    final Map<String, int> pendidikanGrouping = {};
    for (var row in pendidikanRaw) {
      final key = row['pendidikan_terakhir'] as String? ?? 'Tidak Diketahui';
      final count = row['count'] as int? ?? 0;
      pendidikanGrouping[key] = count;
    }

    // Pekerjaan Grouping
    final pekerjaanRaw = await db.rawQuery(
      'SELECT i.pekerjaan, COUNT(*) as count FROM individu i \$individuJoin WHERE \$bWhere GROUP BY i.pekerjaan', bParams
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
            "SELECT COUNT(*) FROM individu i \$individuJoin WHERE i.jenis_kelamin = 'Laki-laki' AND \$bWhere", bParams
          ),
        ) ??
        0;
    final perempuanCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM individu i \$individuJoin WHERE i.jenis_kelamin = 'Perempuan' AND \$bWhere", bParams
          ),
        ) ??
        0;

    // Umur Grouping
    final anakCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) >= 5 
      AND CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) < 10
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    final remajaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) >= 10 
      AND CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) < 25
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    final dewasaCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) FROM individu i \$individuJoin
      WHERE CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) >= 25 
      AND CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) < 60
      AND \$bWhere
    ''', bParams),
        ) ??
        0;

    final Map<String, int> umurGrouping = {
      'Balita (0-4)': balitaCount,
      'Anak (5-9)': anakCount,
      'Remaja (10-24)': remajaCount,
      'Dewasa (25-59)': dewasaCount,
      'Lansia (>=60)': lansiaCount,
    };

    // Mutasi - LAMPID
    String mutasiJoin = 'JOIN bangunan b ON m.id_bangunan = b.id';
    
    final mutasiCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM mutasi m \$mutasiJoin WHERE \$bWhere', bParams),
        ) ??
        0;
        
    final lahirCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM mutasi m \$mutasiJoin WHERE UPPER(m.jenis_mutasi) = 'LAHIR' AND \$bWhere", bParams),
    ) ?? 0;
    
    final matiCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM mutasi m \$mutasiJoin WHERE UPPER(m.jenis_mutasi) = 'MENINGGAL' AND \$bWhere", bParams),
    ) ?? 0;
    
    final pindahCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM mutasi m \$mutasiJoin WHERE UPPER(m.jenis_mutasi) = 'PINDAH' AND \$bWhere", bParams),
    ) ?? 0;
    
    final datangCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM mutasi m \$mutasiJoin WHERE UPPER(m.jenis_mutasi) = 'DATANG' AND \$bWhere", bParams),
    ) ?? 0;
    
    // Disabilitas
    final disabilitasCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM individu i \$individuJoin WHERE i.kriteria_berkebutuhan_khusus IS NOT NULL AND i.kriteria_berkebutuhan_khusus != '' AND \$bWhere", bParams),
    ) ?? 0;

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
      jumlahDisabilitas: disabilitasCount,
      jumlahLahir: lahirCount,
      jumlahMeninggal: matiCount,
      jumlahPindah: pindahCount,
      jumlahDatang: datangCount,
    );
  }
}
""";
  
  await file.writeAsString(content);
}
