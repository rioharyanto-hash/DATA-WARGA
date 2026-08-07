import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../../domain/repositories/i_report_repository.dart';

class ReportRepository implements IReportRepository {
  Map<String, String> _resolveRtRw(
    String kelompokName,
    List<Map<String, dynamic>> kaders,
    List<Map<String, dynamic>> bangunanList,
    String defaultRt,
    String defaultRw,
  ) {
    String resRt = defaultRt;
    String resRw = defaultRw;
    if (kaders.isNotEmpty) {
      final k = kaders.first;
      final kRt = k['rt']?.toString() ?? '';
      if (kRt.isNotEmpty && kRt != 'Semua' && kRt != '...') resRt = kRt;
      final kRw = k['rw']?.toString() ?? '';
      if (kRw.isNotEmpty && kRw != 'Semua' && kRw != '...') resRw = kRw;
    }
    if ((resRt == 'Semua' || resRt.isEmpty || resRt == '...') &&
        bangunanList.isNotEmpty) {
      final bRt = bangunanList.first['rt']?.toString() ?? '';
      if (bRt.isNotEmpty && bRt != 'Semua' && bRt != '...') resRt = bRt;
    }
    if ((resRw == 'Semua' || resRw.isEmpty || resRw == '...') &&
        bangunanList.isNotEmpty) {
      final bRw = bangunanList.first['rw']?.toString() ?? '';
      if (bRw.isNotEmpty && bRw != 'Semua' && bRw != '...') resRw = bRw;
    }
    if (resRt == 'Semua' || resRt.isEmpty || resRt == '...') {
      final RegExp dRegex = RegExp(r'\.([0-9]{1,3})\.([0-9]{1,3})$');
      final dMatch = dRegex.firstMatch(kelompokName);
      if (dMatch != null) {
        resRt = dMatch.group(1)!;
      } else {
        final RegExp dRegex2 = RegExp(
          r'RT[\.\s]*([0-9]{1,3})',
          caseSensitive: false,
        );
        final dMatch2 = dRegex2.firstMatch(kelompokName);
        if (dMatch2 != null) resRt = dMatch2.group(1)!;
      }
    }
    if (resRw == 'Semua' || resRw.isEmpty || resRw == '...') {
      final RegExp rRegex = RegExp(
        r'RW[\.\s]*([0-9]{1,3})',
        caseSensitive: false,
      );
      final rMatch = rRegex.firstMatch(kelompokName);
      if (rMatch != null) {
        resRw = rMatch.group(1)!;
      } else {
        final RegExp dRegex = RegExp(
          r'[\s\.]([0-9]{3})\.([0-9]{1,3})\.([0-9]{1,3})$',
        );
        final dMatch = dRegex.firstMatch(kelompokName);
        if (dMatch != null) resRw = dMatch.group(1)!;
      }
    }
    return {'rt': resRt, 'rw': resRw};
  }

  int _calculateAge(String tglLahirStr) {
    if (tglLahirStr.isEmpty) return -1;
    DateTime? tglLahir;
    try {
      if (tglLahirStr.contains('-') &&
          tglLahirStr.split('-').first.length == 2) {
        final parts = tglLahirStr.split('-');
        tglLahir = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else if (tglLahirStr.contains('/') &&
          tglLahirStr.split('/').first.length == 2) {
        final parts = tglLahirStr.split('/');
        tglLahir = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        tglLahir = DateTime.parse(tglLahirStr);
      }
    } catch (_) {
      return -1;
    }

    int age = DateTime.now().year - tglLahir.year;
    if (DateTime.now().month < tglLahir.month ||
        (DateTime.now().month == tglLahir.month &&
            DateTime.now().day < tglLahir.day)) {
      age--;
    }
    return age;
  }

  @override
  @override
  Future<Map<String, dynamic>> getRekapPKK(String kelompokName) async {
    final db = await LocalDbHelper.database;

    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final bangunanListRaw = await db.query('bangunan');
    final bangunanListForKelompok = kelompokName == 'SEMUA KADER'
        ? bangunanListRaw
        : bangunanListRaw.where((b) {
            final name = (b['kelompok_dawis']?.toString() ?? '')
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return name == normalizedName;
          }).toList();

    bangunanListForKelompok.sort((a, b) {
      final intA =
          int.tryParse(a['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      final intB =
          int.tryParse(b['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      return intA.compareTo(intB);
    });

    List<Map<String, dynamic>> rows = [];

    final bIds = bangunanListForKelompok.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk =
        memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bangunanListForKelompok) {
      final krtList = krtByB[b['id'].toString()] ?? [];

      for (var krt in krtList) {
        final kkList = kkByKrt[krt['id'].toString()] ?? [];

        int jiwaLaki = 0;
        int jiwaPerempuan = 0;
        int balitaLaki = 0;
        int balitaPerempuan = 0;
        int remaja = 0;
        int lansia = 0;
        int praLansia = 0;
        int pus = 0;
        int wus = 0;
        int ibuHamil = 0;
        int ibuMenyusui = 0;
        int buta = 0;
        int berkebutuhanKhusus = 0;

        int makananBeras = 0;
        int makananNonBeras = 0;
        int ikutUp2k = 0;
        int pekarangan = 0;
        int industriRT = 0;
        int kerjaBakti = 0;

        int rumahSehat = b['is_sehat_layak_huni'] == 1 ? 1 : 0;
        int rumahTidakSehat = b['is_tidak_sehat_layak_huni'] == 1 ? 1 : 0;
        int punyaTempatSampah = (b['jumlah_tempat_sampah'] as int? ?? 0) > 0
            ? 1
            : 0;
        int punyaSpal = (b['jumlah_spal'] as int? ?? 0) > 0 ? 1 : 0;
        int punyaJamban = (b['jumlah_jamban_keluarga'] as int? ?? 0) > 0
            ? 1
            : 0;
        int tempelStiker = b['has_stiker_p4k'] == 1 ? 1 : 0;

        int sumberAirPdam = 0;
        int sumberAirSumur = 0;
        int sumberAirLainnya = 0;
        final air = b['sumber_air_minum'] as String?;
        if (air == 'PDAM') {
          sumberAirPdam = 1;
        } else if (air == 'Sumur Pompa' || air == 'Sumur Galian') {
          sumberAirSumur = 1;
        } else if (air != null && air.isNotEmpty) {
          sumberAirLainnya = 1;
        }

        final pemanfaatanPekarangan = b['pemanfaatan_pekarangan'] as String?;
        if (pemanfaatanPekarangan != null && pemanfaatanPekarangan.isNotEmpty) {
          pekarangan = 1;
        }

        for (final kk in kkList) {
          final individuList = indByKk[kk['id'].toString()] ?? [];

          for (final individu in individuList) {
            final jk = individu['jenis_kelamin'] as String?;
            final tglLahirStr = individu['tanggal_lahir'] as String?;
            final isButaHuruf = individu['is_buta_huruf'] == 1;
            final isButaAngka = individu['is_buta_angka'] == 1;
            final isButaBahasa = individu['is_buta_bahasa'] == 1;

            if (jk == 'Laki-laki') {
              jiwaLaki++;
            } else {
              jiwaPerempuan++;
            }
            if (isButaHuruf || isButaAngka || isButaBahasa) buta++;

            if (individu['kriteria_berkebutuhan_khusus'] != null &&
                individu['kriteria_berkebutuhan_khusus']
                    .toString()
                    .isNotEmpty) {
              berkebutuhanKhusus++;
            }
            if (individu['is_ibu_menyusui'] == 1) ibuMenyusui++;
            if (individu['is_ikut_up2k'] == 1) ikutUp2k++;
            if (individu['is_industri_rumah_tangga'] == 1) industriRT++;
            if (individu['ikut_kerja_bakti'] == 1) kerjaBakti++;

            final makanan = individu['makanan_pokok'] as String?;
            if (makanan != null &&
                makanan.toLowerCase().contains('beras') &&
                !makanan.toLowerCase().contains('non')) {
              makananBeras++;
            } else if (makanan != null && makanan.isNotEmpty) {
              makananNonBeras++;
            }

            if (tglLahirStr != null && tglLahirStr.isNotEmpty) {
              int umur = _calculateAge(tglLahirStr);
              if (umur >= 0) {
                if (umur < 5) {
                  if (jk == 'Laki-laki') {
                    balitaLaki++;
                  } else {
                    balitaPerempuan++;
                  }
                } else if (umur >= 10 && umur < 25) {
                  remaja++;
                } else if (umur >= 45 && umur < 60) {
                  praLansia++;
                } else if (umur >= 60) {
                  lansia++;
                }

                if (jk == 'Perempuan' && umur >= 15 && umur <= 49) {
                  wus++;
                  final hubunganKeluarga =
                      (individu['hubungan_keluarga'] as String?)?.toUpperCase();

                  if (hubunganKeluarga == 'ISTRI') {
                    pus++;
                  }
                }
              }
            }
          }
        }

        rows.add({
          'namaKrt': krt['nama_krt'],
          'jmlKk': kkList.length,
          'jiwaLaki': jiwaLaki,
          'jiwaPerempuan': jiwaPerempuan,
          'balitaLaki': balitaLaki,
          'balitaPerempuan': balitaPerempuan,
          'remaja': remaja,
          'praLansia': praLansia,
          'pus': pus,
          'wus': wus,
          'ibuHamil': ibuHamil,
          'ibuMenyusui': ibuMenyusui,
          'lansia': lansia,
          'buta': buta,
          'berkebutuhanKhusus': berkebutuhanKhusus,
          'rumahSehat': rumahSehat,
          'rumahTidakSehat': rumahTidakSehat,
          'punyaTempatSampah': punyaTempatSampah,
          'punyaSpal': punyaSpal,
          'punyaJamban': punyaJamban,
          'tempelStiker': tempelStiker,
          'sumberAirPdam': sumberAirPdam,
          'sumberAirSumur': sumberAirSumur,
          'sumberAirLainnya': sumberAirLainnya,
          'makananBeras': makananBeras,
          'makananNonBeras': makananNonBeras,
          'ikutUp2k': ikutUp2k > 0 ? 1 : 0,
          'pekarangan': pekarangan,
          'industriRT': industriRT > 0 ? 1 : 0,
          'kerjaBakti': kerjaBakti > 0 ? 1 : 0,
          'keterangan': '',
        });
      }
    }

    final allKader = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );
    final kaderQuery = kelompokName == 'SEMUA KADER'
        ? []
        : allKader.where((k) {
            final dawis = k['kelompok_dawis']?.toString() ?? '';
            final normDawis = dawis
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return normDawis ==
                (kelompokName
                    .replaceAll('.', '')
                    .replaceAll(' ', '')
                    .toLowerCase());
          }).toList();

    String namaKader = '';
    if (kaderQuery.isNotEmpty) {
      final kader = kaderQuery.first;
      namaKader = kader['nama']?.toString() ?? '';
    }

    return {'kelompokName': kelompokName, 'namaKader': namaKader, 'rows': rows};
  }

  @override
  Future<List<Map<String, dynamic>>> getLampidData(String kelompokName) async {
    final db = await LocalDbHelper.database;

    // We do a raw query to join mutasi and individu (for jenis_kelamin).
    // If we want to filter by kelompok_dawis, we should also join bangunan.
    String query = '''
      SELECT m.*, i.jenis_kelamin, COALESCE(i.nik, m.nik) AS nik, i.tanggal_lahir, i.status_dgn_krt, i.hubungan_keluarga, b.kelompok_dawis
      FROM mutasi m
      LEFT JOIN individu i ON m.id_individu_asal = i.id
      LEFT JOIN bangunan b ON m.id_bangunan = b.id
      ORDER BY m.tanggal_mutasi DESC
    ''';

    final List<Map<String, dynamic>> mutasiList = await db.rawQuery(query);

    if (kelompokName == 'Semua' || kelompokName == 'SEMUA KADER') {
      return mutasiList;
    }

    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    return mutasiList.where((m) {
      final kDawis = m['kelompok_dawis']?.toString() ?? '';
      final normKDawis = kDawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normKDawis == normalizedName;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getForm1Data(String rt, String rw) async {
    final db = await LocalDbHelper.database;

    // Summary values
    int jumlahKelompok = 0;
    int jumlahBangunan = 0;
    int jumlahKrt = 0;
    int jumlahKeluarga = 0;
    int jumlahIndividu = 0;

    final parsedRt = int.tryParse(rt) ?? 0;
    final parsedRw = int.tryParse(rw) ?? 0;

    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (rt != 'Semua' && rw != 'Semua') {
      whereClause = 'CAST(rt AS INTEGER) = ? AND CAST(rw AS INTEGER) = ?';
      whereArgs = [parsedRt, parsedRw];
    } else if (rw != 'Semua') {
      whereClause = 'CAST(rw AS INTEGER) = ?';
      whereArgs = [parsedRw];
    }

    final krtMap = await _prefetchKrt(db);
    final kkMap = await _prefetchKeluarga(db);
    final indMap = await _prefetchIndividuAktif(db);

    final bangunanList = await db.query(
      'bangunan',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    jumlahBangunan = bangunanList.length;

    // Group by kelompok_dawis
    Map<String, Map<String, dynamic>> kelompokMap = {};

    for (var b in bangunanList) {
      String rawKel = b['kelompok_dawis']?.toString() ?? 'Unassigned';
      if (rawKel.isEmpty) rawKel = 'Unassigned';

      String kel = rawKel.replaceAll('.', '').replaceAll(' ', '').toLowerCase();

      if (!kelompokMap.containsKey(kel)) {
        kelompokMap[kel] = {
          'namaKelompok': rawKel,
          'rt': rt,
          'namaKordinator': '', // Could be filled manually later
          'jumlahBangunan': 0,
          'jumlahKrt': 0,
          'jumlahKeluarga': 0,
          'jumlahIndividu': 0,
        };
      }

      kelompokMap[kel]!['jumlahBangunan'] =
          (kelompokMap[kel]!['jumlahBangunan'] as int) + 1;

      String idBangunan = b['id'].toString();

      // Get KRT
      final krtList = krtMap[idBangunan] ?? [];
      jumlahKrt += krtList.length;
      kelompokMap[kel]!['jumlahKrt'] =
          (kelompokMap[kel]!['jumlahKrt'] as int) + krtList.length;

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();

        // Get Keluarga
        final kkList = kkMap[idKrt] ?? [];
        jumlahKeluarga += kkList.length;
        kelompokMap[kel]!['jumlahKeluarga'] =
            (kelompokMap[kel]!['jumlahKeluarga'] as int) + kkList.length;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          // Get Individu
          final indList = indMap[idKk] ?? [];
          jumlahIndividu += indList.length;
          kelompokMap[kel]!['jumlahIndividu'] =
              (kelompokMap[kel]!['jumlahIndividu'] as int) + indList.length;
        }
      }
    }
    final allKaders = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );

    for (var kel in kelompokMap.keys) {
      final normalizedKel = kel
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();

      final matchedKader = allKaders.where((k) {
        final kaderName = (k['kelompok_dawis']?.toString() ?? '')
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        return kaderName == normalizedKel;
      });

      if (matchedKader.isNotEmpty) {
        kelompokMap[kel]!['idKader'] =
            matchedKader.first['id_kader']?.toString() ?? '';
        kelompokMap[kel]!['namaKordinator'] =
            matchedKader.first['nama']?.toString() ?? '';
      } else {
        kelompokMap[kel]!['idKader'] = '';
        kelompokMap[kel]!['namaKordinator'] = '';
      }

      final resolved = _resolveRtRw(
        kelompokMap[kel]!['namaKelompok']?.toString() ?? kel,
        matchedKader.toList(),
        [],
        kelompokMap[kel]!['rt']?.toString() ?? rt,
        rw,
      );
      kelompokMap[kel]!['rt'] = resolved['rt']!;
    }

    jumlahKelompok = kelompokMap.keys.length;
    List<Map<String, dynamic>> kelompokList = kelompokMap.values.toList();

    // Sort kelompok by name
    kelompokList.sort(
      (a, b) =>
          (a['namaKelompok'] as String).compareTo(b['namaKelompok'] as String),
    );

    return {
      'jumlahKelompok': jumlahKelompok,
      'jumlahBangunan': jumlahBangunan,
      'jumlahKrt': jumlahKrt,
      'jumlahKeluarga': jumlahKeluarga,
      'jumlahIndividu': jumlahIndividu,
      'kelompokList': kelompokList,
    };
  }

  @override
  Future<Map<String, dynamic>> getForm2Data(
    String kelompokName,
    String rt,
    String rw,
  ) async {
    final db = await LocalDbHelper.database;

    final parsedRt = int.tryParse(rt) ?? 0;
    final parsedRw = int.tryParse(rw) ?? 0;

    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (rt != 'Semua' && rw != 'Semua') {
      whereClause = 'CAST(rt AS INTEGER) = ? AND CAST(rw AS INTEGER) = ?';
      whereArgs = [parsedRt, parsedRw];
    } else if (rw != 'Semua') {
      whereClause = 'CAST(rw AS INTEGER) = ?';
      whereArgs = [parsedRw];
    }

    final bangunanListRaw = await db.query(
      'bangunan',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();
    final bangunanList = bangunanListRaw.where((b) {
      final name = (b['kelompok_dawis']?.toString() ?? '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return name == normalizedName;
    }).toList();

    final krtMap = await _prefetchKrt(db);
    final kkMap = await _prefetchKeluarga(db);
    final indMap = await _prefetchIndividuAktif(db);

    List<Map<String, dynamic>> bangunanDataList = [];
    int totalKrt = 0;
    int totalKeluarga = 0;
    int totalIndividu = 0;

    for (var b in bangunanList) {
      String idBangunan = b['id'].toString();

      int jKrt = 0;
      int jKeluarga = 0;
      int jIndividu = 0;

      final krtList = krtMap[idBangunan] ?? [];
      jKrt = krtList.length;
      totalKrt += jKrt;

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();

        final kkList = kkMap[idKrt] ?? [];
        jKeluarga += kkList.length;
        totalKeluarga += kkList.length;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          final indList = indMap[idKk] ?? [];
          jIndividu += indList.length;
          totalIndividu += indList.length;
        }
      }

      String kodeBgn = b['kategori_bangunan']?.toString() ?? '';
      if (kodeBgn == '0') kodeBgn = '';

      bangunanDataList.add({
        'noUrutBangunan': b['nomor_urut_bangunan']?.toString() ?? '',
        'namaBangunan': b['nama_bangunan']?.toString() ?? '',
        'kodeBangunan': kodeBgn,
        'jumlahKrt': jKrt,
        'jumlahKeluarga': jKeluarga,
        'jumlahIndividu': jIndividu,
      });
    }

    final allKader = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );
    final kaderQuery = allKader.where((k) {
      final dawis = k['kelompok_dawis']?.toString() ?? '';
      final normDawis = dawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normDawis ==
          (kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase());
    }).toList();

    String namaKordinator = '';
    if (kaderQuery.isNotEmpty) {
      final kader = kaderQuery.first;
      namaKordinator = '${kader['id_kader'] ?? ''} / ${kader['nama'] ?? ''}';
    }

    return {
      'namaKelompok': kelompokName,
      'namaKordinator': namaKordinator,
      'jumlahBangunan': bangunanList.length,
      'bangunanList': bangunanDataList,
      'totalKrt': totalKrt,
      'totalKeluarga': totalKeluarga,
      'totalIndividu': totalIndividu,
    };
  }

  @override
  Future<Map<String, dynamic>> getFormDataManual(
    String kelompokName,
    String rt,
    String rw,
  ) async {
    final db = await LocalDbHelper.database;

    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final bangunanListRaw = await db.query('bangunan');

    final bangunanList = kelompokName == 'SEMUA KADER'
        ? bangunanListRaw
        : bangunanListRaw.where((b) {
            final name = (b['kelompok_dawis']?.toString() ?? '')
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return name == normalizedName;
          }).toList();

    final krtMap = await _prefetchKrt(db);
    final kkMap = await _prefetchKeluarga(db);
    final indMap = await _prefetchIndividuAktif(db);

    List<Map<String, dynamic>> rows = [];

    for (var b in bangunanList) {
      String idBangunan = b['id'].toString();
      String noUrutBgn = b['nomor_urut_bangunan']?.toString() ?? '';
      String namaBgn = b['nama_bangunan']?.toString() ?? '';
      String nop = b['nop_pbb']?.toString() ?? '';
      String lb = b['luas_bangunan']?.toString() ?? '';
      String ll = b['luas_tanah']?.toString() ?? '';

      final krtList = krtMap[idBangunan] ?? [];

      if (krtList.isEmpty) {
        // If building has no KRT, still show the building? Maybe not needed for individu list, but let's show an empty row for building.
        rows.add({
          'noUrutBangunan': noUrutBgn,
          'namaBangunan': namaBgn,
          'nop': nop,
          'lb': lb,
          'll': ll,
          'noTlp': '',
        });
        continue;
      }

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();
        String namaKrt = krt['nama_krt']?.toString() ?? '';
        String nikKrt = krt['nik_krt']?.toString() ?? '';

        final kkList = kkMap[idKrt] ?? [];

        if (kkList.isEmpty) {
          rows.add({
            'noUrutBangunan': noUrutBgn,
            'namaBangunan': namaBgn,
            'namaKrt': namaKrt,
            'nikKrt': nikKrt,
            'nop': nop,
            'lb': lb,
            'll': ll,
            'noTlp': '',
          });
          continue;
        }

        for (var kk in kkList) {
          String idKk = kk['id'].toString();
          String noKk = kk['no_kk']?.toString() ?? '';

          final indList = indMap[idKk] ?? [];

          // Find Kepala Keluarga name
          String namaKepalaKeluarga = '';
          for (var ind in indList) {
            final upperHub = ind['hubungan_keluarga']?.toString().toUpperCase();
            if (upperHub == 'KEPALA KELUARGA' || upperHub == 'KK') {
              namaKepalaKeluarga = ind['nama_lengkap']?.toString() ?? '';
              break;
            }
          }
          if (namaKepalaKeluarga.isEmpty) {
            namaKepalaKeluarga = namaKrt; // Fallback
          }

          if (indList.isEmpty) {
            rows.add({
              'noUrutBangunan': noUrutBgn,
              'namaBangunan': namaBgn,
              'namaKrt': namaKrt,
              'nikKrt': nikKrt,
              'namaKepalaKeluarga': namaKepalaKeluarga,
              'noKk': noKk,
              'nop': nop,
              'lb': lb,
              'll': ll,
              'noTlp': '',
            });
            continue;
          }

          for (var ind in indList) {
            // Calculate age
            String tglLahirStr = ind['tanggal_lahir']?.toString() ?? '';
            String umur = '';
            if (tglLahirStr.isNotEmpty) {
              int age = _calculateAge(tglLahirStr);
              if (age >= 0) {
                umur = age.toString();
              }
            }

            String jk = ind['jenis_kelamin']?.toString() ?? '';
            String lp = jk == 'Laki-laki'
                ? 'L'
                : (jk == 'Perempuan' ? 'P' : '');

            rows.add({
              'noUrutBangunan': noUrutBgn,
              'namaBangunan': namaBgn,
              'namaKrt': namaKrt,
              'nikKrt': nikKrt,
              'namaKepalaKeluarga': namaKepalaKeluarga,
              'noKk': noKk,
              'individu': ind['nama_lengkap']?.toString() ?? '',
              'noTlp': ind['no_tlp']?.toString() ?? '',
              'lp': lp,
              'nikIndividu': ind['nik']?.toString() ?? '',
              'tglLahir': tglLahirStr,
              'umur': umur,
              'sttsKrt': ind['status_dgn_krt']?.toString() ?? '',
              'sttsKk': ind['hubungan_keluarga']?.toString() ?? '',
              'nop': nop,
              'lb': lb,
              'll': ll,
            });
          }
        }
      }
    }

    final allKader = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );
    final kaderQuery = kelompokName == 'SEMUA KADER'
        ? []
        : allKader.where((k) {
            final dawis = k['kelompok_dawis']?.toString() ?? '';
            final normDawis = dawis
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return normDawis ==
                (kelompokName
                    .replaceAll('.', '')
                    .replaceAll(' ', '')
                    .toLowerCase());
          }).toList();

    String namaKordinator = '';
    if (kaderQuery.isNotEmpty) {
      final kader = kaderQuery.first;
      namaKordinator = '${kader['id_kader'] ?? ''} / ${kader['nama'] ?? ''}';
    }

    return {
      'kelompokName': kelompokName,
      'namaKordinator': namaKordinator,
      'rt': rt,
      'rw': rw,
      'rows': rows,
    };
  }

  @override
  Future<Map<String, dynamic>> getProfilPendudukData(
    String kelompokName,
  ) async {
    final db = await LocalDbHelper.database;
    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final bangunanListRaw = await db.query('bangunan');
    final bangunanListForKelompok = kelompokName == 'SEMUA KADER'
        ? List<Map<String, dynamic>>.from(bangunanListRaw)
        : bangunanListRaw.where((b) {
            final name = (b['kelompok_dawis']?.toString() ?? '')
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return name == normalizedName;
          }).toList();

    bangunanListForKelompok.sort((a, b) {
      final intA =
          int.tryParse(a['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      final intB =
          int.tryParse(b['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      return intA.compareTo(intB);
    });

    List<Map<String, dynamic>> profil1KeluargaList = [];

    final bIds = bangunanListForKelompok.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk =
        memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bangunanListForKelompok) {
      final krtList = krtByB[b['id'].toString()] ?? [];
      for (var krt in krtList) {
        final kkList = kkByKrt[krt['id'].toString()] ?? [];
        for (var kk in kkList) {
          final indList = indByKk[kk['id'].toString()] ?? [];

          if (indList.isEmpty) continue; // Skip empty families

          String namaKeluarga = '';
          for (var ind in indList) {
            final upperHub = ind['hubungan_keluarga']?.toString().toUpperCase();
            if (upperHub == 'KEPALA KELUARGA' || upperHub == 'KK') {
              namaKeluarga = ind['nama_lengkap']?.toString() ?? '';
              break;
            }
          }
          if (namaKeluarga.isEmpty) {
            namaKeluarga =
                indList.first['nama_lengkap']?.toString() ?? 'Tanpa Nama';
          }

          Map<String, int> ageCounts = {
            '0_4_P': 0,
            '0_4_W': 0,
            '5_9_P': 0,
            '5_9_W': 0,
            '10_14_P': 0,
            '10_14_W': 0,
            '15_19_P': 0,
            '15_19_W': 0,
            '20_24_P': 0,
            '20_24_W': 0,
            '25_29_P': 0,
            '25_29_W': 0,
            '30_34_P': 0,
            '30_34_W': 0,
            '35_39_P': 0,
            '35_39_W': 0,
            '40_44_P': 0,
            '40_44_W': 0,
            '45_49_P': 0,
            '45_49_W': 0,
            '50_54_P': 0,
            '50_54_W': 0,
            '55_59_P': 0,
            '55_59_W': 0,
            '60_64_P': 0,
            '60_64_W': 0,
            '65_69_P': 0,
            '65_69_W': 0,
            '70_74_P': 0,
            '70_74_W': 0,
            '75_plus_P': 0,
            '75_plus_W': 0,
          };

          int totalP = 0;
          int totalW = 0;

          for (var ind in indList) {
            String tglLahirStr = ind['tanggal_lahir']?.toString() ?? '';
            int age = 0;
            if (tglLahirStr.isNotEmpty) {
              int parsedAge = _calculateAge(tglLahirStr);
              if (parsedAge >= 0) age = parsedAge;
            }

            String jk = ind['jenis_kelamin']?.toString() ?? '';
            String prefix = '';
            if (age >= 0 && age <= 4) {
              prefix = '0_4';
            } else if (age >= 5 && age <= 9) {
              prefix = '5_9';
            } else if (age >= 10 && age <= 14) {
              prefix = '10_14';
            } else if (age >= 15 && age <= 19) {
              prefix = '15_19';
            } else if (age >= 20 && age <= 24) {
              prefix = '20_24';
            } else if (age >= 25 && age <= 29) {
              prefix = '25_29';
            } else if (age >= 30 && age <= 34) {
              prefix = '30_34';
            } else if (age >= 35 && age <= 39) {
              prefix = '35_39';
            } else if (age >= 40 && age <= 44) {
              prefix = '40_44';
            } else if (age >= 45 && age <= 49) {
              prefix = '45_49';
            } else if (age >= 50 && age <= 54) {
              prefix = '50_54';
            } else if (age >= 55 && age <= 59) {
              prefix = '55_59';
            } else if (age >= 60 && age <= 64) {
              prefix = '60_64';
            } else if (age >= 65 && age <= 69) {
              prefix = '65_69';
            } else if (age >= 70 && age <= 74) {
              prefix = '70_74';
            } else if (age >= 75) {
              prefix = '75_plus';
            }

            if (jk == 'Laki-laki') {
              ageCounts['${prefix}_P'] = (ageCounts['${prefix}_P'] ?? 0) + 1;
              totalP++;
            } else if (jk == 'Perempuan') {
              ageCounts['${prefix}_W'] = (ageCounts['${prefix}_W'] ?? 0) + 1;
              totalW++;
            }
          }

          profil1KeluargaList.add({
            'namaKeluarga': namaKeluarga,
            ...ageCounts,
            'total_P': totalP,
            'total_W': totalW,
          });
        }
      }
    }

    final allKader = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );
    final kaderQuery = allKader.where((k) {
      final dawis = k['kelompok_dawis']?.toString() ?? '';
      final normDawis = dawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normDawis ==
          (kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase());
    }).toList();

    String namaKader = '';
    if (kaderQuery.isNotEmpty) {
      final kader = kaderQuery.first;
      namaKader = kader['nama']?.toString() ?? '';
    }
    final allBgn = await db.query('bangunan');
    final bgnList = allBgn.where((b) {
      final dawis = b['kelompok_dawis']?.toString() ?? '';
      final normDawis = dawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normDawis == normalizedName;
    }).toList();

    final resolved = _resolveRtRw(kelompokName, kaderQuery, bgnList, '', '');

    return {
      'kelompokName': kelompokName,
      'rt': resolved['rt']!,
      'rw': resolved['rw']!,
      'namaKader': namaKader,
      'keluargaList': profil1KeluargaList,
    };
  }

  @override
  Future<Map<String, dynamic>> getForm3Data(
    String kelompokName,
    String rt,
    String rw,
  ) async {
    final db = await LocalDbHelper.database;
    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    // Get Kader
    final allKader = await db.query(
      'app_user',
      where: 'role = ?',
      whereArgs: ['KADER'],
    );
    final kaderQuery = allKader.where((k) {
      final dawis = k['kelompok_dawis']?.toString() ?? '';
      final normDawis = dawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normDawis ==
          (kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase());
    }).toList();
    String namaKader = '';
    String kecamatan = '';
    String kelurahan = '';
    if (kaderQuery.isNotEmpty) {
      final k = kaderQuery.first;
      namaKader = k['nama']?.toString() ?? '';
      kecamatan = k['kecamatan']?.toString() ?? '';
      kelurahan = k['kelurahan']?.toString() ?? '';
    }

    // 1. Ambil semua bangunan yang sesuai kelompok
    final allBgn = await db.query('bangunan');
    final bgnList = allBgn.where((b) {
      final dawis = b['kelompok_dawis']?.toString() ?? '';
      final normDawis = dawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normDawis == normalizedName;
    }).toList();

    final resolved = _resolveRtRw(kelompokName, kaderQuery, bgnList, rt, rw);
    String pkkRt = resolved['rt']!;
    String pkkRw = resolved['rw']!;

    bgnList.sort((a, b) {
      final intA =
          int.tryParse(a['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      final intB =
          int.tryParse(b['nomor_urut_bangunan']?.toString() ?? '') ?? 0;
      return intA.compareTo(intB);
    });

    final krtMap = await _prefetchKrt(db);
    final kkMap = await _prefetchKeluarga(db);
    final indMap = await _prefetchIndividuAktif(db);

    final List<Map<String, dynamic>> krtRows = [];

    int no = 1;
    for (var bgn in bgnList) {
      String idBgn = bgn['id'].toString();

      final krtList = krtMap[idBgn] ?? [];

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();
        String namaKrt = krt['nama_krt']?.toString() ?? '';

        final kkList = kkMap[idKrt] ?? [];

        bool isFirstKk = true;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          int countL = 0, countP = 0;
          int balita = 0, anak = 0, remaja = 0, dewasa = 0, lansia = 0;
          int countPUS = 0;
          int mow = 0,
              mop = 0,
              iud = 0,
              implant = 0,
              suntik = 0,
              pil = 0,
              kondom = 0;
          int hamil = 0, ias = 0, iat = 0, tial = 0;

          final indList = indMap[idKk] ?? [];

          // Find Kepala Keluarga in this KK
          String currentNamaKk = '';
          for (var ind in indList) {
            final hk = ind['hubungan_keluarga']?.toString() ?? '';
            final upperHk = hk.toUpperCase();

            if (upperHk == 'KEPALA KELUARGA' ||
                upperHk == 'KK' ||
                upperHk == 'KEPALA RUMAH TANGGA') {
              currentNamaKk = ind['nama_lengkap']?.toString() ?? '';
            }
          }

          if (currentNamaKk.isEmpty && isFirstKk) {
            // fallback
            currentNamaKk = namaKrt;
          }

          for (var ind in indList) {
            final jk = ind['jenis_kelamin']?.toString() ?? '';
            if (jk == 'Laki-laki') countL++;
            if (jk == 'Perempuan') countP++;

            // Hitung umur
            String tglLahirStr = ind['tanggal_lahir']?.toString() ?? '';
            int age = -1;
            if (tglLahirStr.isNotEmpty) {
              age = _calculateAge(tglLahirStr);
            }

            if (age >= 0) {
              if (age < 5) {
                balita++;
              } else if (age >= 5 && age < 10) {
                anak++;
              } else if (age >= 10 && age < 25) {
                remaja++;
              } else if (age >= 25 && age < 60) {
                dewasa++;
              } else if (age >= 60) {
                lansia++;
              }
            }

            // PUS
            final hubKelPUS =
                ind['hubungan_keluarga']?.toString().toUpperCase() ?? '';
            if (hubKelPUS == 'ISTRI' && age >= 15 && age < 50) {
              countPUS++;
            }

            // KB
            final kb = ind['metode_kb']?.toString() ?? '';
            if (kb == 'MOW/Steril Wanita') {
              mow++;
            } else if (kb == 'MOP/Steril Pria') {
              mop++;
            } else if (kb == 'IUD/Spiral/AKDR') {
              iud++;
            } else if (kb == 'Implant/Susuk') {
              implant++;
            } else if (kb == 'Suntik') {
              suntik++;
            } else if (kb == 'Pil') {
              pil++;
            } else if (kb == 'Kondom') {
              kondom++;
            }

            // Bukan KB
            final bukanKb = ind['alasan_bukan_kb']?.toString() ?? '';
            if (bukanKb == 'Hamil') {
              hamil++;
            } else if (bukanKb == 'IAS') {
              ias++;
            } else if (bukanKb == 'IAT') {
              iat++;
            } else if (bukanKb == 'TIAL') {
              tial++;
            }
          }

          krtRows.add({
            'no': isFirstKk ? (no++).toString() : '',
            'namaKrt': isFirstKk ? namaKrt : '',
            'namaKk': currentNamaKk,
            'L': countL,
            'P': countP,
            'jumlah': countL + countP,
            'balita': balita,
            'anak': anak,
            'remaja': remaja,
            'dewasa': dewasa,
            'lansia': lansia,
            'jumlahKeluarga': 1,
            'pus': countPUS,
            'mow': mow,
            'mop': mop,
            'iud': iud,
            'implant': implant,
            'suntik': suntik,
            'pil': pil,
            'kondom': kondom,
            'jumlahKb': mow + mop + iud + implant + suntik + pil + kondom,
            'tial': tial,
            'iat': iat,
            'ias': ias,
            'hamil': hamil,
            'jumlahBukanKb': tial + iat + ias + hamil,
          });

          isFirstKk = false;
        }
      }
    }

    return {
      'namaKader': namaKader,
      'kelompokName': kelompokName,
      'rt': pkkRt,
      'rw': pkkRw,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      'kota': 'Jakarta Timur',
      'rows': krtRows,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getYatimPiatuData(
    String kelompokName,
  ) async {
    final db = await LocalDbHelper.database;
    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final result = <Map<String, dynamic>>[];

    final allBgn = await db.query(
      'bangunan',
      columns: ['id', 'kelompok_dawis'],
    );
    final bgnList = kelompokName == 'SEMUA KADER'
        ? allBgn
        : allBgn.where((b) {
            final dawis = b['kelompok_dawis']?.toString() ?? '';
            final normDawis = dawis
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return normDawis == normalizedName;
          }).toList();

    if (bgnList.isEmpty) return result;

    final bgnIds = bgnList.map((e) => e['id']).toList();
    final bgnPlaceholders = List.filled(bgnIds.length, '?').join(',');

    final krtList = await db.query(
      'krt',
      columns: ['id'],
      where: 'id_bangunan IN ($bgnPlaceholders)',
      whereArgs: bgnIds,
    );
    if (krtList.isEmpty) return result;
    final krtIds = krtList.map((e) => e['id']).toList();
    final krtPlaceholders = List.filled(krtIds.length, '?').join(',');

    final kelList = await db.query(
      'keluarga',
      columns: ['id'],
      where: 'id_krt IN ($krtPlaceholders)',
      whereArgs: krtIds,
    );
    if (kelList.isEmpty) return result;

    final indMap = await _prefetchIndividuAktif(db);

    for (var kel in kelList) {
      final kelId = kel['id']?.toString() ?? '';

      final individuList = indMap[kelId] ?? [];

      final kkList = individuList.where((i) {
        final upperHub = (i['hubungan_keluarga']?.toString() ?? '')
            .toUpperCase();
        return upperHub == 'KEPALA KELUARGA' || upperHub == 'KK';
      }).toList();

      bool isKkPerempuan = false;
      String namaWali = '';
      if (kkList.isNotEmpty) {
        final kk = kkList.first;
        final jkKk = (kk['jenis_kelamin']?.toString() ?? '').toUpperCase();
        isKkPerempuan = (jkKk == 'PEREMPUAN');
        namaWali = kk['nama_lengkap']?.toString() ?? '';
      }

      for (var ind in individuList) {
        String nama = ind['nama_lengkap']?.toString() ?? '';
        String nik = ind['nik']?.toString() ?? '';
        String jk = ind['jenis_kelamin']?.toString() ?? '';
        String tglLahir = ind['tanggal_lahir']?.toString() ?? '';
        String alamat = ind['alamat_ktp']?.toString() ?? '';
        if (alamat.isEmpty) alamat = ind['alamat_domisili']?.toString() ?? '';
        String pekerjaan = (ind['pekerjaan']?.toString() ?? '').toUpperCase();
        String hub = (ind['hubungan_keluarga']?.toString() ?? '').toUpperCase();
        String statusYp = '';
        if (ind.containsKey('status_yatim_piatu')) {
          statusYp = ind['status_yatim_piatu']?.toString() ?? '';
        }

        if (statusYp == 'Tidak') statusYp = '';

        int umur = 0;
        if (tglLahir.isNotEmpty) {
          int parsedAge = _calculateAge(tglLahir);
          if (parsedAge >= 0) umur = parsedAge;
        }

        bool isYatimPiatuExplicit = (statusYp.isNotEmpty);

        bool isAnakYatimAuto = false;
        if (hub == 'ANAK' &&
            umur <= 18 &&
            (pekerjaan.contains('BELUM') ||
                pekerjaan.contains('TIDAK') ||
                pekerjaan.contains('PELAJAR'))) {
          if (isKkPerempuan) {
            isAnakYatimAuto = true;
          }
        }

        if (isYatimPiatuExplicit || isAnakYatimAuto) {
          if (statusYp.isEmpty && isAnakYatimAuto) {
            statusYp = 'Yatim (Auto)';
          }

          result.add({
            'nama': nama,
            'nik': nik,
            'umur': umur.toString(),
            'jk': jk,
            'alamat': alamat,
            'nama_wali': namaWali,
            'status_yatim_piatu': statusYp,
          });
        }
      }
    }

    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getPotensiWargaData(
    String kelompokName,
  ) async {
    final db = await LocalDbHelper.database;
    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    // First, let's get all Bangunan in the selected kelompok
    final List<Map<String, dynamic>> allBgnRaw = await db.rawQuery('''
        SELECT b.* 
        FROM bangunan b
        ORDER BY CAST(b.nomor_urut_bangunan AS INTEGER) ASC, b.nama_bangunan ASC
      ''');
    final bangunanListRaw = kelompokName == 'SEMUA KADER'
        ? allBgnRaw
        : allBgnRaw.where((b) {
            final dawis = b['kelompok_dawis']?.toString() ?? '';
            final normDawis = dawis
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase();
            return normDawis == normalizedName;
          }).toList();

    final krtMap = await _prefetchKrt(db);
    final kkMap = await _prefetchKeluarga(db);
    final indMap = await _prefetchIndividuAktif(db);

    List<Map<String, dynamic>> result = [];
    int no = 1;

    for (var bgnRow in bangunanListRaw) {
      final idBangunan = bgnRow['id']?.toString() ?? '';
      final namaBangunan = bgnRow['nama_bangunan']?.toString() ?? '';

      final krtList = krtMap[idBangunan] ?? [];
      final krtCount = krtList.length;
      int kkCount = 0;
      List<Map<String, dynamic>> individuList = [];

      for (var krt in krtList) {
        final idKrt = krt['id']?.toString() ?? '';
        final kkList = kkMap[idKrt] ?? [];
        kkCount += kkList.length;

        for (var kk in kkList) {
          final idKk = kk['id']?.toString() ?? '';
          individuList.addAll(indMap[idKk] ?? []);
        }
      }

      int l = 0;
      int p = 0;

      int balitaL = 0;
      int balitaP = 0;
      int balitaAktifL = 0;
      int balitaAktifP = 0;

      int pus = 0;

      int tidakKb = 0;
      int kbPil = 0;
      int kbIud = 0;
      int kbImplan = 0;
      int kbSuntik = 0;
      int kbKondom = 0;
      int kbSteril = 0;
      int kbLainnya = 0;

      int remajaL = 0;
      int remajaP = 0;
      int remajaAktifL = 0;
      int remajaAktifP = 0;

      int lansiaL = 0;
      int lansiaP = 0;
      int lansiaAktifL = 0;
      int lansiaAktifP = 0;

      int berkebutuhanL = 0;
      int berkebutuhanP = 0;

      for (var ind in individuList) {
        final jk = ind['jenis_kelamin']?.toString().toUpperCase() ?? '';
        int umur = 0;
        int parsedAge = _calculateAge(ind['tanggal_lahir']?.toString() ?? '');
        if (parsedAge >= 0) umur = parsedAge;
        final isIstri =
            (ind['hubungan_keluarga']?.toString().toUpperCase() == 'ISTRI');
        final isAktif = ind['aktif_posyandu']?.toString() == '1';
        final isL = (jk == 'L' || jk == 'LAKI-LAKI');
        final isP = (jk == 'P' || jk == 'PEREMPUAN');

        if (isL) l++;
        if (isP) p++;

        // BALITA (< 5)
        if (umur < 5) {
          if (isL) {
            balitaL++;
            if (isAktif) balitaAktifL++;
          }
          if (isP) {
            balitaP++;
            if (isAktif) balitaAktifP++;
          }
        }

        // REMAJA (10-24)
        if (umur >= 10 && umur < 25) {
          if (isL) {
            remajaL++;
            if (isAktif) remajaAktifL++;
          }
          if (isP) {
            remajaP++;
            if (isAktif) remajaAktifP++;
          }
        }

        // LANSIA (>= 60)
        if (umur >= 60) {
          if (isL) {
            lansiaL++;
            if (isAktif) lansiaAktifL++;
          }
          if (isP) {
            lansiaP++;
            if (isAktif) lansiaAktifP++;
          }
        }

        // PUS & KB
        if (isIstri && umur >= 15 && umur <= 49) {
          pus++;
          final kb = ind['metode_kb']?.toString().toUpperCase() ?? '';
          if (kb.contains('PIL')) {
            kbPil++;
          } else if (kb.contains('IUD')) {
            kbIud++;
          } else if (kb.contains('IMPLAN')) {
            kbImplan++;
          } else if (kb.contains('SUNTIK')) {
            kbSuntik++;
          } else if (kb.contains('KONDOM')) {
            kbKondom++;
          } else if (kb.contains('MOW') ||
              kb.contains('MOP') ||
              kb.contains('STERIL')) {
            kbSteril++;
          } else if (kb.isNotEmpty &&
              !kb.contains('TIDAK') &&
              kb != 'N/A' &&
              kb != 'NULL') {
            kbLainnya++;
          } else {
            tidakKb++;
          }
        }

        // BERKEBUTUHAN KHUSUS
        if (ind['kriteria_berkebutuhan_khusus'] != null &&
            ind['kriteria_berkebutuhan_khusus'].toString().trim().isNotEmpty &&
            ind['kriteria_berkebutuhan_khusus'].toString().toUpperCase() !=
                'TIDAK ADA') {
          if (isL) berkebutuhanL++;
          if (isP) berkebutuhanP++;
        }
      }

      // Extract housing data from bangunan
      int rumahSehat = bgnRow['is_sehat_layak_huni'] == 1 ? 1 : 0;
      int rumahTidakSehat = bgnRow['is_tidak_sehat_layak_huni'] == 1 ? 1 : 0;
      int punyaTempatSampah = (bgnRow['jumlah_tempat_sampah'] as int? ?? 0) > 0
          ? 1
          : 0;
      int punyaSpal = (bgnRow['jumlah_spal'] as int? ?? 0) > 0 ? 1 : 0;
      int punyaJamban = (bgnRow['jumlah_jamban_keluarga'] as int? ?? 0) > 0
          ? 1
          : 0;
      int tempelStiker = bgnRow['has_stiker_p4k'] == 1 ? 1 : 0;

      int sumberAirPdam = 0;
      int sumberAirSumur = 0;
      int sumberAirLainnya = 0;
      final air = bgnRow['sumber_air_minum'] as String?;
      if (air == 'PDAM') {
        sumberAirPdam = 1;
      } else if (air == 'Sumur Pompa' || air == 'Sumur Galian') {
        sumberAirSumur = 1;
      } else if (air != null && air.isNotEmpty) {
        sumberAirLainnya = 1;
      }

      int makananBeras = 0;
      int makananNonBeras = 0;
      int ikutUp2k = 0;
      int pekarangan = 0;
      int industriRT = 0;
      int kerjaBakti = 0;

      final pemanfaatanPekarangan = bgnRow['pemanfaatan_pekarangan'] as String?;
      if (pemanfaatanPekarangan != null && pemanfaatanPekarangan.isNotEmpty) {
        pekarangan = 1;
      }

      // Count activity/food data from individu
      for (var ind in individuList) {
        if (ind['is_ikut_up2k'] == 1) ikutUp2k++;
        if (ind['is_industri_rumah_tangga'] == 1) industriRT++;
        if (ind['ikut_kerja_bakti'] == 1) kerjaBakti++;
        final makanan = ind['makanan_pokok'] as String?;
        if (makanan != null &&
            makanan.toLowerCase().contains('beras') &&
            !makanan.toLowerCase().contains('non')) {
          makananBeras++;
        } else if (makanan != null && makanan.isNotEmpty) {
          makananNonBeras++;
        }
      }

      result.add({
        'no': no++,
        'rt': bgnRow['rt']?.toString() ?? '',
        'dasawisma': namaBangunan,
        'namaBangunan': namaBangunan,
        'jmlKrt': krtCount,
        'jmlKk': kkCount,
        'L': l,
        'P': p,

        'balitaL': balitaL,
        'balitaP': balitaP,
        'balitaAktifL': balitaAktifL,
        'balitaAktifP': balitaAktifP,

        'pus': pus,

        'tidakKb': tidakKb,
        'kbPil': kbPil,
        'kbIud': kbIud,
        'kbImplan': kbImplan,
        'kbSuntik': kbSuntik,
        'kbKondom': kbKondom,
        'kbSteril': kbSteril,
        'kbLainnya': kbLainnya,

        'remajaL': remajaL,
        'remajaP': remajaP,
        'remajaAktifL': remajaAktifL,
        'remajaAktifP': remajaAktifP,

        'lansiaL': lansiaL,
        'lansiaP': lansiaP,
        'lansiaAktifL': lansiaAktifL,
        'lansiaAktifP': lansiaAktifP,

        'berkebutuhanL': berkebutuhanL,
        'berkebutuhanP': berkebutuhanP,

        // Housing / Infrastructure fields
        'rumahSehat': rumahSehat,
        'rumahTidakSehat': rumahTidakSehat,
        'punyaTempatSampah': punyaTempatSampah,
        'punyaSpal': punyaSpal,
        'punyaJamban': punyaJamban,
        'tempelStiker': tempelStiker,
        'sumberAirPdam': sumberAirPdam,
        'sumberAirSumur': sumberAirSumur,
        'sumberAirLainnya': sumberAirLainnya,
        'makananBeras': makananBeras > 0 ? 1 : 0,
        'makananNonBeras': makananNonBeras > 0 ? 1 : 0,
        'ikutUp2k': ikutUp2k > 0 ? 1 : 0,
        'pekarangan': pekarangan,
        'industriRT': industriRT > 0 ? 1 : 0,
        'kerjaBakti': kerjaBakti > 0 ? 1 : 0,

        'ket': '',
      });
    }

    return result;
  }

  String _pad3(String? val) {
    final s = (val ?? '').trim();
    if (s.isEmpty) return '';
    final n = int.tryParse(s);
    if (n != null) return n.toString().padLeft(3, '0');
    return s.padLeft(3, '0');
  }

  @override
  Future<List<Map<String, String>>> getAllKelompokDawisList() async {
    final db = await LocalDbHelper.database;
    final result = await db.query(
      'app_user',
      columns: ['kelompok_dawis', 'rt', 'rw', 'id_kader', 'nama'],
      where: 'role = ?',
      whereArgs: ['KADER'],
    );

    final bangunanGroups = await db.query(
      'bangunan',
      columns: ['kelompok_dawis', 'rt', 'rw'],
      distinct: true,
    );

    final Map<String, Map<String, String>> combined = {};

    for (var row in result) {
      final k = row['kelompok_dawis']?.toString() ?? '';
      if (k.isNotEmpty) {
        final normalized = k
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        combined[normalized] = {
          'kelompok_dawis': k,
          'rt': _pad3(row['rt']?.toString()),
          'rw': _pad3(row['rw']?.toString()),
          'id_kader': row['id_kader']?.toString() ?? '',
          'nama': row['nama']?.toString() ?? '',
        };
      }
    }

    for (var row in bangunanGroups) {
      final k = row['kelompok_dawis']?.toString() ?? '';
      if (k.isNotEmpty) {
        final normalized = k
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (combined.containsKey(normalized)) {
          combined[normalized]!['rt'] = _pad3(row['rt']?.toString());
          combined[normalized]!['rw'] = _pad3(row['rw']?.toString());
        } else {
          combined[normalized] = {
            'kelompok_dawis': k,
            'rt': _pad3(row['rt']?.toString()),
            'rw': _pad3(row['rw']?.toString()),
            'id_kader': '',
            'nama': '',
          };
        }
      }
    }

    final list = combined.values.toList();
    list.sort((a, b) => a['kelompok_dawis']!.compareTo(b['kelompok_dawis']!));
    return list;
  }

  Future<Map<String, dynamic>> _fetchInMemoryData(
    Database db,
    Set<String> bangunanIds,
  ) async {
    final Map<String, List<Map<String, dynamic>>> krtByBangunan = {};
    final Map<String, List<Map<String, dynamic>>> kkByKrt = {};
    final Map<String, List<Map<String, dynamic>>> individuByKeluarga = {};

    if (bangunanIds.isEmpty) {
      return {
        'krt': krtByBangunan,
        'kk': kkByKrt,
        'individu': individuByKeluarga,
      };
    }

    final krtMapAll = await _prefetchKrt(db);
    final kkMapAll = await _prefetchKeluarga(db);
    final indMapAll = await _prefetchIndividuAktif(db);

    final krtIds = <String>{};
    for (var bId in bangunanIds) {
      if (krtMapAll.containsKey(bId)) {
        krtByBangunan[bId] = krtMapAll[bId]!;
        for (var krt in krtMapAll[bId]!) {
          krtIds.add(krt['id'].toString());
        }
      }
    }

    final kelIds = <String>{};
    for (var krtId in krtIds) {
      if (kkMapAll.containsKey(krtId)) {
        kkByKrt[krtId] = kkMapAll[krtId]!;
        for (var kk in kkMapAll[krtId]!) {
          kelIds.add(kk['id'].toString());
        }
      }
    }

    for (var kelId in kelIds) {
      if (indMapAll.containsKey(kelId)) {
        individuByKeluarga[kelId] = indMapAll[kelId]!;
      }
    }

    return {
      'krt': krtByBangunan,
      'kk': kkByKrt,
      'individu': individuByKeluarga,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getUsiaSekolahData(
    String kelompokName,
    int month,
    int year,
  ) async {
    final db = await LocalDbHelper.database;
    final List<Map<String, dynamic>> results = [];

    // Hitung range tanggal lahir untuk usia 5 - 6 tahun di akhir bulan periode laporan
    DateTime periodEnd = DateTime(year, month + 1, 0);
    DateTime minDate = DateTime(
      periodEnd.year - 7,
      periodEnd.month,
      periodEnd.day,
    );
    DateTime maxDate = DateTime(
      periodEnd.year - 5,
      periodEnd.month,
      periodEnd.day,
    );

    String minDateStr =
        "${minDate.year.toString().padLeft(4, '0')}-${minDate.month.toString().padLeft(2, '0')}-${minDate.day.toString().padLeft(2, '0')}";
    String maxDateStr =
        "${maxDate.year.toString().padLeft(4, '0')}-${maxDate.month.toString().padLeft(2, '0')}-${maxDate.day.toString().padLeft(2, '0')}";

    // Tarik raw data yang DIBATASI berdasarkan rentang tanggal_lahir
    final rawData = await db.rawQuery(
      '''
      SELECT 
        b.alamat_lengkap AS alamat, b.rt, b.rw,
        b.kelompok_dawis AS nama_kelompok,
        b.nama_bangunan,
        kel.id AS keluarga_id,
        ind.id AS individu_id,
        ind.nama_lengkap AS nama_anak,
        ind.nik AS nik_anak,
        ind.tanggal_lahir,
        ind.pendidikan_terakhir,
        ind.alasan_belum_sekolah
      FROM bangunan b
      JOIN krt ON krt.id_bangunan = b.id
      JOIN keluarga kel ON kel.id_krt = krt.id
      JOIN individu ind ON ind.id_keluarga = kel.id
      WHERE NOT EXISTS (
        SELECT 1 FROM mutasi m
        WHERE m.id_individu_asal = ind.id 
        AND m.jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      AND ind.tanggal_lahir > ? AND ind.tanggal_lahir <= ?
      ''',
      [minDateStr, maxDateStr],
    );

    // Lakukan filter manual kelompok_dawis di Dart (Sesuai AGENTS.md)
    String normalizedTarget = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final indMap = await _prefetchIndividuAktif(db);

    for (var row in rawData) {
      // Filter Kelompok Dawis di memori
      if (kelompokName != 'SEMUA') {
        final rowKelompok = row['nama_kelompok']?.toString() ?? '';
        final normalizedRowKelompok = rowKelompok
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (normalizedRowKelompok != normalizedTarget) {
          continue;
        }
      }

      // Pastikan validasi umur secara persis menggunakan logika Dart
      final String tglLahir = row['tanggal_lahir']?.toString() ?? '';
      if (tglLahir.isEmpty) continue;

      int ageYears = 0;
      int ageMonths = 0;
      try {
        final dob = DateTime.parse(tglLahir);
        ageYears = periodEnd.year - dob.year;
        ageMonths = periodEnd.month - dob.month;
        if (periodEnd.day < dob.day) {
          ageMonths--;
        }
        if (ageMonths < 0) {
          ageYears--;
          ageMonths += 12;
        }
        if (ageYears < 5 || ageYears > 6) {
          continue;
        }
      } catch (_) {
        continue;
      }

      // Ambil data orang tua
      final String kelId = row['keluarga_id'].toString();
      final familyMembers = indMap[kelId] ?? [];
      final ortuList = familyMembers.where((ind) {
        final hub = (ind['hubungan_keluarga']?.toString() ?? '').toUpperCase();
        final stat = (ind['status_dgn_krt']?.toString() ?? '').toUpperCase();
        return hub == 'KK' ||
            hub == 'KEPALA KELUARGA' ||
            hub == 'KEPALA RUMAH TANGGA' ||
            hub == 'ISTRI' ||
            hub == 'ORANG TUA' ||
            stat == 'KK' ||
            stat == 'KEPALA KELUARGA' ||
            stat == 'KEPALA RUMAH TANGGA' ||
            stat == 'ISTRI' ||
            stat == 'ORANG TUA';
      }).toList();

      String namaOrtu = '-';
      String nikOrtu = '-';
      String noHp = '-';

      if (ortuList.isNotEmpty) {
        var ortu = ortuList.firstWhere((e) {
          final hub = e['hubungan_keluarga']?.toString().toUpperCase() ?? '';
          final stat = e['status_dgn_krt']?.toString().toUpperCase() ?? '';
          return hub == 'KK' ||
              hub == 'KEPALA KELUARGA' ||
              hub == 'KEPALA RUMAH TANGGA' ||
              stat == 'KK' ||
              stat == 'KEPALA KELUARGA' ||
              stat == 'KEPALA RUMAH TANGGA';
        }, orElse: () => ortuList.first);
        namaOrtu = ortu['nama_lengkap']?.toString() ?? '-';
        nikOrtu = ortu['nik']?.toString() ?? '-';
        noHp = ortu['no_tlp']?.toString() ?? '-';
      }

      String pendTerakhir = row['pendidikan_terakhir']?.toString() ?? '';
      bool sudahSekolah = pendTerakhir.toUpperCase() != 'TIDAK/BELUM SEKOLAH';

      results.add({
        'individu_id': row['individu_id'],
        'nama_orang_tua': namaOrtu,
        'nik_orang_tua': nikOrtu,
        'nama_anak': row['nama_anak'],
        'nik_anak': row['nik_anak'],
        'tanggal_lahir': tglLahir,
        'usia': '$ageYears Tahun, $ageMonths Bulan',
        'alamat':
            '${row['alamat'] ?? ''} RT ${row['rt'] ?? ''} / RW ${row['rw'] ?? ''}',
        'no_hp': noHp.isEmpty ? '-' : noHp,
        'pendidikan_terakhir': pendTerakhir,
        'sudah_sekolah': sudahSekolah ? 'Sudah' : 'Belum',
        'alasan_belum_sekolah': row['alasan_belum_sekolah'] ?? '-',
        'rt': row['rt'],
        'nama_kelompok': row['nama_kelompok'],
        'nama_bangunan': row['nama_bangunan'],
      });
    }

    // Urutkan berdasarkan RT lalu Usia lalu Nama
    results.sort((a, b) {
      int parseRt(String? rtStr) {
        if (rtStr == null || rtStr.isEmpty) return 0;
        final parts = rtStr.split('/');
        final rt = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(rt) ?? 0;
      }

      final rtA = parseRt(a['rt']?.toString());
      final rtB = parseRt(b['rt']?.toString());
      if (rtA != rtB) return rtA.compareTo(rtB);

      // Extract usia from string "X Tahun, Y Bulan"
      int ageA = 0, ageB = 0;
      int monthA = 0, monthB = 0;
      try {
        var pA = a['usia']
            .toString()
            .replaceAll(' Tahun', '')
            .replaceAll(' Bulan', '')
            .split(', ');
        ageA = int.tryParse(pA[0]) ?? 0;
        monthA = int.tryParse(pA.length > 1 ? pA[1] : '0') ?? 0;

        var pB = b['usia']
            .toString()
            .replaceAll(' Tahun', '')
            .replaceAll(' Bulan', '')
            .split(', ');
        ageB = int.tryParse(pB[0]) ?? 0;
        monthB = int.tryParse(pB.length > 1 ? pB[1] : '0') ?? 0;
      } catch (_) {}

      // Usia: younger first or older first?
      // Older first would be b.compareTo(a) but we will use ascending age (younger first) because it's standard, wait, if ageA != ageB return ageA.compareTo(ageB)
      if (ageA != ageB) return ageA.compareTo(ageB);
      if (monthA != monthB) return monthA.compareTo(monthB);

      final nameA = a['nama_anak']?.toString().toLowerCase() ?? '';
      final nameB = b['nama_anak']?.toString().toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });

    return results;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _prefetchKrt(
    Database db,
  ) async {
    final list = await db.query('krt');
    final map = <String, List<Map<String, dynamic>>>{};
    for (var k in list) {
      final idBgn = k['id_bangunan']?.toString() ?? '';
      if (idBgn.isNotEmpty) {
        map.putIfAbsent(idBgn, () => []).add(k);
      }
    }
    return map;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _prefetchKeluarga(
    Database db,
  ) async {
    final list = await db.query('keluarga');
    final map = <String, List<Map<String, dynamic>>>{};
    for (var k in list) {
      final idKrt = k['id_krt']?.toString() ?? '';
      if (idKrt.isNotEmpty) {
        map.putIfAbsent(idKrt, () => []).add(k);
      }
    }
    return map;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _prefetchIndividuAktif(
    Database db,
  ) async {
    final list = await db.rawQuery('''
      SELECT * FROM individu 
      WHERE NOT EXISTS (
        SELECT 1 FROM mutasi m
        WHERE m.id_individu_asal = individu.id 
        AND m.jenis_mutasi IN ('Meninggal', 'Pindah')
      )
      ''');
    final map = <String, List<Map<String, dynamic>>>{};
    for (var ind in list) {
      final idKk = ind['id_keluarga']?.toString() ?? '';
      if (idKk.isNotEmpty) {
        map.putIfAbsent(idKk, () => []).add(ind);
      }
    }
    for (var v in map.values) {
      v.sort((a, b) {
        int getPriority(Map<String, dynamic> ind) {
          final hub = (ind['hubungan_keluarga']?.toString() ?? '')
              .toUpperCase()
              .trim();
          final sttsKrt = (ind['status_dgn_krt']?.toString() ?? '')
              .toUpperCase()
              .trim();
          if (sttsKrt == 'KRT' ||
              sttsKrt == 'KEPALA RUMAH TANGGA' ||
              hub == 'KRT' ||
              hub == 'KEPALA RUMAH TANGGA')
            return 1;
          if (sttsKrt == 'KK' ||
              sttsKrt == 'KEPALA KELUARGA' ||
              hub == 'KK' ||
              hub == 'KEPALA KELUARGA')
            return 2;
          if (sttsKrt == 'ISTRI' || hub == 'ISTRI') return 3;
          if (sttsKrt == 'ANAK' || hub == 'ANAK') return 4;
          return 5;
        }

        final prioA = getPriority(a);
        final prioB = getPriority(b);
        if (prioA != prioB) return prioA.compareTo(prioB);

        final tglAStr = a['tanggal_lahir']?.toString() ?? '';
        final tglBStr = b['tanggal_lahir']?.toString() ?? '';
        if (tglAStr.isNotEmpty && tglBStr.isNotEmpty) {
          try {
            final dateA = DateTime.parse(tglAStr);
            final dateB = DateTime.parse(tglBStr);
            final cmp = dateA.compareTo(dateB);
            if (cmp != 0) return cmp;
          } catch (_) {}
        }
        final idA = int.tryParse(a['id']?.toString() ?? '') ?? 0;
        final idB = int.tryParse(b['id']?.toString() ?? '') ?? 0;
        return idA.compareTo(idB);
      });
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> _getIndividuAktif(
    Database db,
    Object? idKeluarga,
  ) async {
    final rawList = await db.rawQuery(
      '''
      SELECT * FROM individu 
      WHERE id_keluarga = ? 
      AND NOT EXISTS (
        SELECT 1 FROM mutasi m
        WHERE m.id_individu_asal = individu.id 
        AND m.jenis_mutasi IN ('Meninggal', 'Pindah')
      )
    ''',
      [idKeluarga],
    );

    final sortedList = List<Map<String, dynamic>>.from(rawList);
    sortedList.sort((a, b) {
      int getPriority(Map<String, dynamic> ind) {
        final hub = (ind['hubungan_keluarga']?.toString() ?? '')
            .toUpperCase()
            .trim();
        final sttsKrt = (ind['status_dgn_krt']?.toString() ?? '')
            .toUpperCase()
            .trim();

        if (sttsKrt == 'KRT' ||
            sttsKrt == 'KEPALA RUMAH TANGGA' ||
            hub == 'KRT' ||
            hub == 'KEPALA RUMAH TANGGA') {
          return 1;
        }
        if (sttsKrt == 'KK' ||
            sttsKrt == 'KEPALA KELUARGA' ||
            hub == 'KK' ||
            hub == 'KEPALA KELUARGA') {
          return 2;
        }
        if (sttsKrt == 'ISTRI' || hub == 'ISTRI') {
          return 3;
        }
        if (sttsKrt == 'ANAK' || hub == 'ANAK') {
          return 4;
        }
        return 5;
      }

      final prioA = getPriority(a);
      final prioB = getPriority(b);
      if (prioA != prioB) {
        return prioA.compareTo(prioB);
      }

      // Secondary sort: tanggal lahir ascending (oldest first)
      final tglAStr = a['tanggal_lahir']?.toString() ?? '';
      final tglBStr = b['tanggal_lahir']?.toString() ?? '';
      if (tglAStr.isNotEmpty && tglBStr.isNotEmpty) {
        try {
          final dateA = DateTime.parse(tglAStr);
          final dateB = DateTime.parse(tglBStr);
          final cmp = dateA.compareTo(dateB);
          if (cmp != 0) return cmp;
        } catch (_) {}
      }

      // Tertiary sort: id
      final idA = int.tryParse(a['id']?.toString() ?? '') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '') ?? 0;
      return idA.compareTo(idB);
    });

    return sortedList;
  }

  @override
  Future<List<Map<String, dynamic>>> getRekapanLpjDasawismaData(
    dynamic user,
    String rw,
    String rt,
  ) async {
    final db = await LocalDbHelper.database;
    final List<Map<String, dynamic>> results = [];

    List<Map<String, dynamic>> kaders = [];
    if (user.role == 'KADER') {
      kaders = await db.query(
        'app_user',
        where: 'id_kader = ?',
        whereArgs: [user.idKader],
      );
    } else {
      String whereClause = 'role = "KADER" AND rw = ?';
      List<String> whereArgs = [rw];
      if (rt != 'Semua' && rt != '...' && rt.isNotEmpty) {
        whereClause += ' AND rt = ?';
        whereArgs.add(rt);
      }
      kaders = await db.query(
        'app_user',
        where: whereClause,
        whereArgs: whereArgs,
      );
    }

    for (var kader in kaders) {
      final kelompokName = kader['kelompok_dawis']?.toString() ?? '';
      if (kelompokName.isEmpty) continue;

      final normalizedKelompok = kelompokName
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();

      // Get bangunan
      final bList = await db.query('bangunan');
      final bangunanList = bList.where((b) {
        final n =
            b['nama_kelompok']?.toString() ??
            b['kelompok_dawis']?.toString() ??
            '';
        return n.replaceAll('.', '').replaceAll(' ', '').toLowerCase() ==
            normalizedKelompok;
      }).toList();

      if (bangunanList.isEmpty) continue;

      int jmlRumah = bangunanList.length;
      int jmlKeluarga = 0;
      int jmlWargaL = 0;
      int jmlWargaP = 0;
      int jmlBayiL = 0;
      int jmlBayiP = 0;
      int jmlMeninggal = 0;
      int jmlPindah = 0;
      int jmlPindahan = 0;

      for (var b in bangunanList) {
        final bId = b['id'];
        final krts = await db.query(
          'krt',
          where: 'id_bangunan = ?',
          whereArgs: [bId],
        );

        final mutasis = await db.query(
          'mutasi',
          where: 'id_bangunan = ?',
          whereArgs: [bId],
        );
        for (var m in mutasis) {
          final j = m['jenis_mutasi']?.toString().toLowerCase() ?? '';
          if (j == 'meninggal')
            jmlMeninggal++;
          else if (j == 'pindah')
            jmlPindah++;
          else if (j == 'datang')
            jmlPindahan++;
        }

        for (var krt in krts) {
          final krtId = krt['id'];
          final kels = await db.query(
            'keluarga',
            where: 'id_krt = ?',
            whereArgs: [krtId],
          );
          jmlKeluarga += kels.length;

          for (var kel in kels) {
            final kelId = kel['id'];
            final inds = await _getIndividuAktif(db, kelId);

            for (var ind in inds) {
              final jk = ind['jenis_kelamin']?.toString().toUpperCase() ?? '';
              final tgl = ind['tanggal_lahir']?.toString() ?? '';
              int umur = 99;
              if (tgl.isNotEmpty) {
                try {
                  final dt = DateTime.parse(tgl);
                  final now = DateTime.now();
                  umur = now.year - dt.year;
                  if (now.month < dt.month ||
                      (now.month == dt.month && now.day < dt.day)) {
                    umur--;
                  }
                } catch (_) {}
              }

              if (jk == 'L') {
                jmlWargaL++;
                if (umur < 5) jmlBayiL++;
              } else if (jk == 'P') {
                jmlWargaP++;
                if (umur < 5) jmlBayiP++;
              }
            }
          }
        }
      }

      results.add({
        'nama_kader': kader['nama']?.toString() ?? '',
        'nama_kelompok': kelompokName,
        'rt': kader['rt']?.toString() ?? rt,
        'jml_rumah': jmlRumah,
        'jml_keluarga': jmlKeluarga,
        'jml_warga_l': jmlWargaL,
        'jml_warga_p': jmlWargaP,
        'jml_bayi_l': jmlBayiL,
        'jml_bayi_p': jmlBayiP,
        'jml_meninggal': jmlMeninggal,
        'jml_pindah': jmlPindah,
        'jml_pindahan': jmlPindahan,
      });
    }

    return results;
  }
}

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepository();
});
