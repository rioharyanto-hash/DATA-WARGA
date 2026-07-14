import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/local_db_helper.dart';
import '../../../settings/domain/entities/app_user.dart';
import '../../domain/entities/data_warga_bangunan.dart';
import '../../domain/entities/data_warga_keluarga.dart';
import '../../domain/repositories/data_warga_repository.dart';

class DataWargaRepositoryImpl implements DataWargaRepository {
  @override
  Future<List<String>> getRtList(AppUser user) async {
    final db = await LocalDbHelper.database;
    String where = '1=1';
    List<Object?> params = [];

    if (user.role == 'RW') {
      where += ' AND rw = ?';
      params.add(user.rw);
    } else if (user.role == 'RT') {
      where += ' AND rw = ? AND rt = ?';
      params.add(user.rw);
      params.add(user.rt);
    }

    final query = '''
      SELECT DISTINCT rt, kelompok_dawis 
      FROM bangunan 
      WHERE $where AND rt IS NOT NULL AND rt != ''
    ''';
    
    final results = await db.rawQuery(query, params);
    
    // Manual filter for KADER due to naming inconsistencies
    Iterable<Map<String, Object?>> filteredResults = results;
    if (user.role == 'KADER' && user.kelompokDawis != null) {
      final normalizedName = user.kelompokDawis!.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
      filteredResults = results.where((e) {
        final kd = e['kelompok_dawis']?.toString() ?? '';
        final normalizedKd = kd.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
        return normalizedKd == normalizedName;
      });
    }
    
    final rtSet = filteredResults.map((e) => e['rt'].toString()).toSet();
    final rtList = rtSet.toList()..sort();
    return rtList;
  }

  @override
  Future<List<DataWargaBangunan>> getBangunanList(
    AppUser user, {
    String? searchQuery,
    String? rtFilter,
  }) async {
    final db = await LocalDbHelper.database;

    String where = '1=1';
    List<Object?> params = [];

    // RBAC Filtering
    if (user.role == 'RW') {
      where += ' AND b.rw = ?';
      params.add(user.rw);
    } else if (user.role == 'RT') {
      where += ' AND b.rw = ? AND b.rt = ?';
      params.add(user.rw);
      params.add(user.rt);
    }

    if (rtFilter != null && rtFilter.isNotEmpty && rtFilter != 'Semua') {
      where += ' AND b.rt = ?';
      params.add(rtFilter);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where += ''' AND (b.nama_bangunan LIKE ? 
                    OR b.alamat_lengkap LIKE ? 
                    OR EXISTS (
                      SELECT 1 FROM krt k
                      LEFT JOIN keluarga kel ON k.id = kel.id_krt
                      LEFT JOIN individu i ON kel.id = i.id_keluarga
                      WHERE k.id_bangunan = b.id 
                      AND (k.nama_krt LIKE ? OR i.nama_lengkap LIKE ?)
                    ))''';
      params.add('%$searchQuery%');
      params.add('%$searchQuery%');
      params.add('%$searchQuery%');
      params.add('%$searchQuery%');
    }

    final query =
        '''
      SELECT 
        b.id, b.nama_bangunan, b.nomor_urut_bangunan, b.alamat_lengkap as alamat, b.rt, b.rw, '' as kelurahan, b.kategori_bangunan, b.kelompok_dawis,
        (SELECT COUNT(*) FROM keluarga kel JOIN krt k ON kel.id_krt = k.id WHERE k.id_bangunan = b.id) as total_kk,
        (SELECT COUNT(*) FROM individu i JOIN keluarga kel ON i.id_keluarga = kel.id JOIN krt k ON kel.id_krt = k.id WHERE k.id_bangunan = b.id) as total_penghuni,
        (SELECT COUNT(*) FROM individu i JOIN keluarga kel ON i.id_keluarga = kel.id JOIN krt k ON kel.id_krt = k.id WHERE k.id_bangunan = b.id AND i.jenis_kelamin = 'Laki-laki') as laki_laki,
        (SELECT COUNT(*) FROM individu i JOIN keluarga kel ON i.id_keluarga = kel.id JOIN krt k ON kel.id_krt = k.id WHERE k.id_bangunan = b.id AND i.jenis_kelamin = 'Perempuan') as perempuan
      FROM bangunan b
      WHERE $where
      ORDER BY b.nama_bangunan ASC
    ''';

    final results = await db.rawQuery(query, params);

    // Manual filter for KADER due to naming inconsistencies
    Iterable<Map<String, Object?>> filteredResults = results;
    if (user.role == 'KADER' && user.kelompokDawis != null) {
      final normalizedName = user.kelompokDawis!.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
      filteredResults = results.where((e) {
        final kd = e['kelompok_dawis']?.toString() ?? '';
        final normalizedKd = kd.replaceAll('.', '').replaceAll(' ', '').toLowerCase();
        return normalizedKd == normalizedName;
      });
    }

    return filteredResults.map((e) {
      return DataWargaBangunan(
        id: e['id']?.toString() ?? '',
        namaBangunan: e['nama_bangunan']?.toString() ?? '',
        nomorBangunan: e['nomor_urut_bangunan']?.toString(),
        alamat: e['alamat']?.toString() ?? '',
        rt: e['rt']?.toString() ?? '',
        rw: e['rw']?.toString() ?? '',
        kelurahan: e['kelurahan']?.toString() ?? '',
        totalPenghuni:
            Sqflite.firstIntValue([
              {'count': e['total_penghuni']},
            ]) ??
            0,
        totalKk:
            Sqflite.firstIntValue([
              {'count': e['total_kk']},
            ]) ??
            0,
        lakiLaki:
            Sqflite.firstIntValue([
              {'count': e['laki_laki']},
            ]) ??
            0,
        perempuan:
            Sqflite.firstIntValue([
              {'count': e['perempuan']},
            ]) ??
            0,
        kategoriBangunan: e['kategori_bangunan'] != null
            ? int.tryParse(e['kategori_bangunan'].toString())
            : null,
      );
    }).toList();
  }

  @override
  Future<List<DataWargaKeluarga>> getKeluargaList(String bangunanId) async {
    final db = await LocalDbHelper.database;

    // We get keluarga inside the given bangunan.
    // The query finds all keluarga that belong to any KRT that belongs to the bangunan.
    final query = '''
      SELECT 
        kel.id, 
        k.id as id_krt,
        COALESCE(
          (SELECT nama_lengkap FROM individu i 
           WHERE i.id_keluarga = kel.id 
           AND UPPER(i.hubungan_keluarga) IN ('KK', 'KEPALA KELUARGA', 'KEPALA RUMAH TANGGA') 
           LIMIT 1),
          k.nama_krt,
          'Tanpa Nama'
        ) as nama_kepala_keluarga, 
        kel.no_kk,
        (SELECT COUNT(*) FROM individu i WHERE i.id_keluarga = kel.id) as jumlah_anggota,
        (SELECT b.status_hunian FROM bangunan b WHERE b.id = k.id_bangunan LIMIT 1) as status_hunian
      FROM keluarga kel
      JOIN krt k ON kel.id_krt = k.id
      WHERE k.id_bangunan = ?
      ORDER BY nama_kepala_keluarga ASC
    ''';

    final results = await db.rawQuery(query, [bangunanId]);

    return results.map((e) {
      return DataWargaKeluarga(
        id: e['id']?.toString() ?? '',
        idKrt: e['id_krt']?.toString() ?? '',
        namaKepalaKeluarga: e['nama_kepala_keluarga']?.toString() ?? '',
        noKk: e['no_kk']?.toString() ?? '-',
        jumlahAnggota:
            Sqflite.firstIntValue([
              {'count': e['jumlah_anggota']},
            ]) ??
            0,
        statusHunian: e['status_hunian']?.toString() ?? 'Tidak Diketahui',
      );
    }).toList();
  }
}
