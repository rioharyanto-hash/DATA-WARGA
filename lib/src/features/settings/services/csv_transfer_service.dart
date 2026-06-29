import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import 'package:dawis/core/database/local_db_helper.dart';

class ImportSummary {
  final int totalRows;
  final int acceptedRows;
  final int rejectedRows;
  final List<String> errors;

  ImportSummary({
    required this.totalRows,
    required this.acceptedRows,
    required this.rejectedRows,
    this.errors = const [],
  });
}

class CsvTransferService {
  final _uuid = const Uuid();

  /// Mendownload template CSV kosong untuk diisi
  Future<String> generateTemplateCsv() async {
    List<List<dynamic>> rows = [
      [
        'KELOMPOK_DAWIS',
        'RT',
        'RW',
        'NOMOR_URUT_BANGUNAN',
        'NAMA_BANGUNAN',
        'ALAMAT_BANGUNAN',
        'NAMA_KRT',
        'NIK_KRT',
        'NO_TLP',
        'NO_KK',
        'NIK_INDIVIDU',
        'NAMA_INDIVIDU',
        'HUBUNGAN_KELUARGA',
        'STTS_DGN_KRT',
        'JENIS_KELAMIN',
        'TEMPAT_LAHIR',
        'TANGGAL_LAHIR',
        'AGAMA',
        'PUNYA_AKTE_KELAHIRAN',
        'NO_AKTE_KELAHIRAN',
        'PUNYA_BPJS',
        'JENIS_BPJS',
        'AKTIF_POSYANDU',
        'FREKUENSI_POSYANDU',
        'IKUT_KERJA_BAKTI',
      ],
      [
        'Dawis Mawar 1',
        '01',
        '02',
        '1',
        'Rumah Pak Budi',
        'Jl. Melati No 10',
        'Budi Santoso',
        '3301010000000001',
        '081234567890',
        '3301010000000001',
        '3301010000000001',
        'Budi Santoso',
        'Kepala Keluarga',
        'Kepala Rumah Tangga',
        'Laki-laki',
        'Jakarta',
        '1980-01-01',
        'Islam',
        1,
        '1234567890',
        1,
        'Mandiri',
        0,
        '',
        1,
      ],
      [
        'Dawis Mawar 1',
        '01',
        '02',
        '1',
        'Rumah Pak Budi',
        'Jl. Melati No 10',
        'Budi Santoso',
        '3301010000000001',
        '081234567891',
        '3301010000000001',
        '3301020000000002',
        'Siti Aminah',
        'Istri',
        'Istri',
        'Perempuan',
        'Bandung',
        '1982-05-05',
        'Islam',
        1,
        '1234567891',
        1,
        'Mandiri',
        1,
        '2 kali',
        1,
      ],
    ];

    String csvData = Csv().encode(rows);
    return csvData;
  }

  /// Ekspor seluruh data dari database ke CSV flat
  Future<String> exportAllDataToCsv() async {
    final db = await LocalDbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        b.kelompok_dawis, b.rt, b.rw, b.nomor_urut_bangunan, b.nama_bangunan, b.alamat_lengkap,
        k.nama_krt, k.nik_krt,
        kel.no_kk,
        i.nik, i.nama_lengkap, i.hubungan_keluarga, i.status_dgn_krt, i.jenis_kelamin, i.tempat_lahir, i.tanggal_lahir, i.status_perkawinan, i.pendidikan_terakhir, i.pekerjaan, i.no_tlp,
        i.agama, i.punya_akte_kelahiran, i.no_akte_kelahiran, i.punya_bpjs, i.jenis_bpjs,
        i.aktif_posyandu, i.frekuensi_posyandu, i.ikut_kerja_bakti
      FROM individu i
      JOIN keluarga kel ON i.id_keluarga = kel.id
      JOIN krt k ON kel.id_krt = k.id
      JOIN bangunan b ON k.id_bangunan = b.id
    ''');

    List<List<dynamic>> rows = [
      [
        'KELOMPOK_DAWIS',
        'RT',
        'RW',
        'NOMOR_URUT_BANGUNAN',
        'NAMA_BANGUNAN',
        'ALAMAT_BANGUNAN',
        'NAMA_KRT',
        'NIK_KRT',
        'NO_TLP',
        'NO_KK',
        'NIK_INDIVIDU',
        'NAMA_INDIVIDU',
        'HUBUNGAN_KELUARGA',
        'STTS_DGN_KRT',
        'JENIS_KELAMIN',
        'TEMPAT_LAHIR',
        'TANGGAL_LAHIR',
        'AGAMA',
        'PUNYA_AKTE_KELAHIRAN',
        'NO_AKTE_KELAHIRAN',
        'PUNYA_BPJS',
        'JENIS_BPJS',
        'AKTIF_POSYANDU',
        'FREKUENSI_POSYANDU',
        'IKUT_KERJA_BAKTI',
      ],
    ];

    for (var row in result) {
      rows.add([
        row['kelompok_dawis'],
        row['rt'],
        row['rw'],
        row['nomor_urut_bangunan'] ?? '',
        row['nama_bangunan'],
        row['alamat_lengkap'],
        row['nama_krt'],
        row['nik_krt'],
        row['no_tlp'] ?? '',
        row['no_kk'],
        row['nik'],
        row['nama_lengkap'],
        row['hubungan_keluarga'],
        row['status_dgn_krt'] ?? '',
        row['jenis_kelamin'],
        row['tempat_lahir'],
        row['tanggal_lahir'],
        row['agama'] ?? '',
        row['punya_akte_kelahiran'] ?? 0,
        row['no_akte_kelahiran'] ?? '',
        row['punya_bpjs'] ?? 0,
        row['jenis_bpjs'] ?? '',
        row['aktif_posyandu'] ?? 0,
        row['frekuensi_posyandu'] ?? '',
        row['ikut_kerja_bakti'] ?? 0,
      ]);
    }

    return Csv().encode(rows);
  }

  double? _parseDoubleRobust(String value) {
    if (value.isEmpty) return null;
    String cleanValue = value.replaceAll(',', '.');
    cleanValue = cleanValue.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanValue.isEmpty) return null;

    int firstDotIndex = cleanValue.indexOf('.');
    if (firstDotIndex != -1) {
      String rest = cleanValue.substring(firstDotIndex + 1).replaceAll('.', '');
      cleanValue = cleanValue.substring(0, firstDotIndex + 1) + rest;
    }

    return double.tryParse(cleanValue);
  }

  /// Impor data CSV mentah ke dalam SQLite (hierarkis)
  Future<ImportSummary> importBulkCsv(String filePath) async {
    final file = File(filePath);
    String csvString;
    try {
      csvString = await file.readAsString();
    } catch (e) {
      final bytes = await file.readAsBytes();
      csvString = latin1.decode(bytes, allowInvalid: true);
    }
    final List<List<dynamic>> rows = Csv().decode(csvString);

    if (rows.isEmpty || rows.length == 1) {
      return ImportSummary(totalRows: 0, acceptedRows: 0, rejectedRows: 0);
    }

    final db = await LocalDbHelper.database;

    // Cache ID berdasarkan unique key
    Map<String, String> bangunanMap =
        {}; // key: "nama_bangunan-rt-rw-no_urut" -> id
    final existingBangunan = await db.query(
      'bangunan',
      columns: ['id', 'nama_bangunan', 'rt', 'rw', 'nomor_urut_bangunan'],
    );
    for (var b in existingBangunan) {
      String key =
          '${b['nama_bangunan']}-${b['rt']}-${b['rw']}-${b['nomor_urut_bangunan'] ?? ''}';
      bangunanMap[key] = b['id'].toString();
    }

    Map<String, String> krtMap = {}; // key: "nik_krt" -> id
    final existingKrt = await db.query('krt', columns: ['id', 'nik_krt']);
    for (var k in existingKrt) {
      krtMap[k['nik_krt'].toString()] = k['id'].toString();
    }

    Map<String, String> keluargaMap = {}; // key: "no_kk" -> id
    final existingKeluarga = await db.query(
      'keluarga',
      columns: ['id', 'no_kk'],
    );
    for (var k in existingKeluarga) {
      keluargaMap[k['no_kk'].toString()] = k['id'].toString();
    }

    Map<String, String> individuMap =
        {}; // key: "nik" or "nama-id_keluarga" -> id
    final existingIndividu = await db.query(
      'individu',
      columns: ['id', 'nik', 'nama_lengkap', 'id_keluarga'],
    );
    for (var ind in existingIndividu) {
      String nik = ind['nik']?.toString() ?? '';
      if (nik.isNotEmpty) {
        individuMap[nik] = ind['id'].toString();
      } else {
        individuMap['${ind['nama_lengkap']}-${ind['id_keluarga']}'] = ind['id']
            .toString();
      }
    }

    int totalRows = 0;
    int acceptedRows = 0;
    int rejectedRows = 0;
    List<String> errors = [];

    bool isHeader = true;
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      if (isHeader) {
        isHeader = false;
        continue;
      }

      totalRows++;

      if (row.isEmpty || row.length < 16) {
        rejectedRows++;
        errors.add('Baris ${i + 1}: Format kolom tidak lengkap.');
        continue;
      }

      String kelompokDawis = row[0]?.toString().trim() ?? '';
      String rt = row[1]?.toString().trim() ?? '';
      String rw = row[2]?.toString().trim() ?? '';
      String nomorUrutBangunan = row[3]?.toString().trim() ?? '';
      String namaBangunan = row[4]?.toString().trim() ?? '';
      String alamat = row[5]?.toString().trim() ?? '';
      String namaKrt = row[6]?.toString().trim() ?? '';
      String nikKrt = row[7]?.toString().trim() ?? '';
      String noTlp = row[8]?.toString().trim() ?? '';
      String noKk = row[9]?.toString().trim() ?? '';
      String nikIndividu = row[10]?.toString().trim() ?? '';
      String namaIndividu = row[11]?.toString().trim() ?? '';
      String hubungan = row[12]?.toString().trim() ?? '';
      String sttsDgnKrt = row[13]?.toString().trim() ?? '';
      String jk = row[14]?.toString().trim() ?? '';
      String tempatLahir = row[15]?.toString().trim() ?? '';
      String tglLahir = row[16]?.toString().trim() ?? '';

      // Auto parse NIK if gender or dob is empty
      if (nikIndividu.length == 16 && (jk.isEmpty || tglLahir.isEmpty)) {
        try {
          final dobStr = nikIndividu.substring(6, 12);
          int dd = int.parse(dobStr.substring(0, 2));
          int mm = int.parse(dobStr.substring(2, 4));
          int yy = int.parse(dobStr.substring(4, 6));

          if (jk.isEmpty) {
            jk = (dd > 40) ? 'Perempuan' : 'Laki-laki';
          }
          if (tglLahir.isEmpty) {
            if (dd > 40) dd -= 40;
            final currentYearLast2 = DateTime.now().year % 100;
            int fullYear = yy > currentYearLast2 ? 1900 + yy : 2000 + yy;
            final dob = DateTime(fullYear, mm, dd);
            tglLahir =
                '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
          }
        } catch (e) {
          // ignore parsing error
        }
      }

      String agama = row.length > 17
          ? row[17]?.toString().trim() ?? 'Islam'
          : 'Islam';
      int punyaAkte = row.length > 18
          ? (int.tryParse(row[18]?.toString() ?? '0') ?? 0)
          : 0;
      String noAkte = row.length > 19 ? row[19]?.toString().trim() ?? '' : '';
      int punyaBpjs = row.length > 20
          ? (int.tryParse(row[20]?.toString() ?? '0') ?? 0)
          : 0;
      String jenisBpjs = row.length > 21
          ? row[21]?.toString().trim() ?? ''
          : '';
      int aktifPosyandu = row.length > 22
          ? (int.tryParse(row[22]?.toString() ?? '0') ?? 0)
          : 0;
      String frekPosyandu = row.length > 23
          ? row[23]?.toString().trim() ?? ''
          : '';
      int ikutKerjaBakti = row.length > 24
          ? (int.tryParse(row[24]?.toString() ?? '0') ?? 0)
          : 0;

      try {
        // 1. Bangunan
        String bangunanKey = '$namaBangunan-$rt-$rw-$nomorUrutBangunan';
        String idBangunan;
        if (bangunanMap.containsKey(bangunanKey)) {
          idBangunan = bangunanMap[bangunanKey]!;
        } else {
          idBangunan = _uuid.v4();
          bangunanMap[bangunanKey] = idBangunan;
          await db.insert('bangunan', {
            'id': idBangunan,
            'nomor_urut_bangunan': nomorUrutBangunan,
            'nama_bangunan': namaBangunan,
            'kelompok_dawis': kelompokDawis.isEmpty
                ? 'Unassigned'
                : kelompokDawis,
            'alamat_lengkap': alamat,
            'rt': rt,
            'rw': rw,
            'status_hunian': 'Milik Sendiri', // Default
            'is_synced': 0,
          });
        }

        // Cek apakah rumah kosong (tanpa KRT dan Individu)
        if (nikKrt.isEmpty && namaKrt.isEmpty) {
          if (namaIndividu.isNotEmpty || nikIndividu.isNotEmpty) {
            // Pengguna mengisi data individu tapi mengosongkan kolom KRT
            namaKrt = namaIndividu;
            nikKrt = nikIndividu;
            if (noKk.isEmpty) {
              noKk = nikIndividu; // Fallback untuk NO_KK
            }
          } else {
            acceptedRows++;
            continue;
          }
        }

        // 2. KRT
        String idKrt;
        String krtKey = nikKrt.isNotEmpty ? nikKrt : '$namaKrt-$idBangunan';
        if (krtMap.containsKey(krtKey)) {
          idKrt = krtMap[krtKey]!;
        } else {
          idKrt = _uuid.v4();
          krtMap[krtKey] = idKrt;
          await db.insert('krt', {
            'id': idKrt,
            'id_bangunan': idBangunan,
            'nama_krt': namaKrt,
            'nik_krt': nikKrt,
            'no_kk_krt': noKk,
            'is_synced': 0,
          });
        }

        // 3. Keluarga
        String idKeluarga;
        String kkKey = noKk.isNotEmpty
            ? noKk
            : idKrt; // Fallback ke KRT ID jika no_kk kosong
        if (keluargaMap.containsKey(kkKey)) {
          idKeluarga = keluargaMap[kkKey]!;
        } else {
          idKeluarga = _uuid.v4();
          keluargaMap[kkKey] = idKeluarga;
          await db.insert('keluarga', {
            'id': idKeluarga,
            'id_krt': idKrt,
            'no_kk': noKk,
            'status_visitasi': 'Sudah Dikunjungi',
            'is_synced': 0,
          });
        }

        // 4. Individu
        String individuKey = nikIndividu.isNotEmpty
            ? nikIndividu
            : '$namaIndividu-$idKeluarga';
        if (!individuMap.containsKey(individuKey)) {
          String idIndividu = _uuid.v4();
          individuMap[individuKey] = idIndividu;
          await db.insert('individu', {
            'id': idIndividu,
            'id_keluarga': idKeluarga,
            'nama_lengkap': namaIndividu,
            'nik': nikIndividu,
            'hubungan_keluarga': hubungan,
            'status_dgn_krt': sttsDgnKrt,
            'jenis_kelamin': jk,
            'tempat_lahir': tempatLahir,
            'tanggal_lahir': tglLahir,
            'status_perkawinan': 'Belum Kawin', // Default
            'pendidikan_terakhir': 'SD/Sederajat',
            'pekerjaan': 'Lainnya',
            'no_tlp': noTlp,
            'agama': agama,
            'punya_akte_kelahiran': punyaAkte,
            'no_akte_kelahiran': noAkte,
            'punya_bpjs': punyaBpjs,
            'jenis_bpjs': jenisBpjs,
            'aktif_posyandu': aktifPosyandu,
            'frekuensi_posyandu': frekPosyandu,
            'ikut_kerja_bakti': ikutKerjaBakti,
            'is_synced': 0,
          });
        }

        acceptedRows++;
      } catch (e) {
        rejectedRows++;
        errors.add('Baris ${i + 1}: Terjadi kesalahan internal ($e).');
      }
    }

    return ImportSummary(
      totalRows: totalRows,
      acceptedRows: acceptedRows,
      rejectedRows: rejectedRows,
      errors: errors,
    );
  }

  /// Mendownload template CSV khusus data Bangunan
  Future<String> generateTemplateBangunanCsv() async {
    List<List<dynamic>> rows = [
      [
        'KELOMPOK_DAWIS',
        'RT',
        'RW',
        'NOMOR_URUT_BANGUNAN',
        'NAMA_BANGUNAN',
        'ALAMAT_LENGKAP',
        'STATUS_HUNIAN',
        'NOP_PBB',
        'LUAS_BANGUNAN',
        'LUAS_TANAH',
        'STATUS_KEPEMILIKAN',
        'SUMBER_AIR_MINUM',
      ],
      [
        'Dawis Mawar 1',
        '01',
        '02',
        '1',
        'Rumah Pak Budi',
        'Jl. Melati No 10',
        'Milik Sendiri',
        '123456789',
        '100',
        '150',
        'SHM',
        'PDAM',
      ],
    ];
    return Csv().encode(rows);
  }

  /// Ekspor data Bangunan ke CSV
  Future<String> exportBangunanToCsv() async {
    final db = await LocalDbHelper.database;
    final result = await db.query('bangunan');

    List<List<dynamic>> rows = [
      [
        'ID_BANGUNAN',
        'KELOMPOK_DAWIS',
        'RT',
        'RW',
        'NOMOR_URUT_BANGUNAN',
        'NAMA_BANGUNAN',
        'ALAMAT_LENGKAP',
        'STATUS_HUNIAN',
        'NOP_PBB',
        'LUAS_BANGUNAN',
        'LUAS_TANAH',
        'STATUS_KEPEMILIKAN',
        'SUMBER_AIR_MINUM',
      ],
    ];

    for (var row in result) {
      rows.add([
        row['id'],
        row['kelompok_dawis'],
        row['rt'],
        row['rw'],
        row['nomor_urut_bangunan'] ?? '',
        row['nama_bangunan'],
        row['alamat_lengkap'],
        row['status_hunian'],
        row['nop_pbb'] ?? '',
        row['luas_bangunan'] ?? '',
        row['luas_tanah'] ?? '',
        row['status_kepemilikan'] ?? '',
        row['sumber_air_minum'] ?? '',
      ]);
    }

    return Csv().encode(rows);
  }

  /// Impor data CSV khusus Bangunan
  Future<ImportSummary> importBangunanCsv(String filePath) async {
    final file = File(filePath);
    String csvString;
    try {
      csvString = await file.readAsString();
    } catch (e) {
      final bytes = await file.readAsBytes();
      csvString = latin1.decode(bytes, allowInvalid: true);
    }
    final List<List<dynamic>> rows = Csv().decode(csvString);

    if (rows.isEmpty || rows.length == 1) {
      return ImportSummary(totalRows: 0, acceptedRows: 0, rejectedRows: 0);
    }

    final db = await LocalDbHelper.database;

    final existingData = await db.query('bangunan');
    Map<String, String> bangunanMap = {};
    for (var b in existingData) {
      String key = "${b['nama_bangunan']}-${b['rt']}-${b['rw']}";
      bangunanMap[key] = b['id'].toString();
    }

    bool isHeader = true;
    int colIdIndex = -1;
    int totalRows = 0;
    int acceptedRows = 0;
    int rejectedRows = 0;
    List<String> errors = [];

    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      if (isHeader) {
        isHeader = false;
        if (row.isNotEmpty && row[0].toString().trim() == 'ID_BANGUNAN') {
          colIdIndex = 0;
        }
        continue;
      }

      totalRows++;

      if (row.isEmpty || row.length < 5) {
        rejectedRows++;
        errors.add('Baris ${i + 1}: Format kolom tidak lengkap.');
        continue;
      }

      int offset = colIdIndex != -1 ? 1 : 0;

      String kelompokDawis = row[0 + offset]?.toString().trim() ?? '';
      String rt = row[1 + offset]?.toString().trim() ?? '';
      String rw = row[2 + offset]?.toString().trim() ?? '';
      String nomorUrutBangunan = row[3 + offset]?.toString().trim() ?? '';
      String namaBangunan = row[4 + offset]?.toString().trim() ?? '';
      String alamat = row[5 + offset]?.toString().trim() ?? '';

      String statusHunian = row.length > 6 + offset
          ? row[6 + offset]?.toString().trim() ?? 'Milik Sendiri'
          : 'Milik Sendiri';
      String nopPbb = row.length > 7 + offset
          ? row[7 + offset]?.toString().trim() ?? ''
          : '';
      String luasBangunan = row.length > 8 + offset
          ? row[8 + offset]?.toString().trim() ?? ''
          : '';
      String luasTanah = row.length > 9 + offset
          ? row[9 + offset]?.toString().trim() ?? ''
          : '';
      String statusKepemilikan = row.length > 10 + offset
          ? row[10 + offset]?.toString().trim() ?? ''
          : '';
      String sumberAirMinum = row.length > 11 + offset
          ? row[11 + offset]?.toString().trim() ?? ''
          : '';

      try {
        String bangunanKey = '$namaBangunan-$rt-$rw';
        String? idBangunan;

        if (colIdIndex != -1) {
          idBangunan = row[0].toString().trim();
          if (idBangunan.isEmpty) idBangunan = null;
        }

        if (idBangunan == null && bangunanMap.containsKey(bangunanKey)) {
          idBangunan = bangunanMap[bangunanKey]!;
        }

        Map<String, dynamic> data = {
          'nomor_urut_bangunan': nomorUrutBangunan,
          'nama_bangunan': namaBangunan,
          'kelompok_dawis': kelompokDawis.isEmpty
              ? 'Unassigned'
              : kelompokDawis,
          'alamat_lengkap': alamat,
          'rt': rt,
          'rw': rw,
          'status_hunian': statusHunian,
          'nop_pbb': nopPbb,
          'luas_bangunan': _parseDoubleRobust(luasBangunan),
          'luas_tanah': _parseDoubleRobust(luasTanah),
          'status_kepemilikan': statusKepemilikan,
          'sumber_air_minum': sumberAirMinum,
          'is_synced': 0,
        };

        if (idBangunan != null) {
          await db.update(
            'bangunan',
            data,
            where: 'id = ?',
            whereArgs: [idBangunan],
          );
        } else {
          idBangunan = _uuid.v4();
          data['id'] = idBangunan;
          await db.insert('bangunan', data);
          bangunanMap[bangunanKey] = idBangunan;
        }
        acceptedRows++;
      } catch (e) {
        rejectedRows++;
        errors.add('Baris ${i + 1}: Terjadi kesalahan internal ($e).');
      }
    }

    return ImportSummary(
      totalRows: totalRows,
      acceptedRows: acceptedRows,
      rejectedRows: rejectedRows,
      errors: errors,
    );
  }
}
