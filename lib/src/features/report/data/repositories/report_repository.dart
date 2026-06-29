import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../../domain/repositories/i_report_repository.dart';

class ReportRepository implements IReportRepository {
  @override
  @override
  Future<Map<String, dynamic>> getRekapPKK(String kelompokName) async {
    final db = await LocalDbHelper.database;

    final normalizedName = kelompokName
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final bangunanListRaw = await db.query('bangunan');
    final bangunanListForKelompok = bangunanListRaw.where((b) {
      final name = (b['kelompok_dawis']?.toString() ?? '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return name == normalizedName;
    }).toList();

    List<Map<String, dynamic>> rows = [];

    for (var b in bangunanListForKelompok) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );

      for (var krt in krtList) {
        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [krt['id']],
        );

        int jiwaLaki = 0;
        int jiwaPerempuan = 0;
        int balitaLaki = 0;
        int balitaPerempuan = 0;
        int lansia = 0;
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
          final individuList = await _getIndividuAktif(db, kk['id']);

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
              try {
                final tglLahir = DateTime.parse(tglLahirStr);
                final umur = DateTime.now().year - tglLahir.year;

                if (umur < 5) {
                  if (jk == 'Laki-laki') {
                    balitaLaki++;
                  } else {
                    balitaPerempuan++;
                  }
                } else if (umur >= 60) {
                  lansia++;
                }

                if (jk == 'Perempuan' && umur >= 15 && umur <= 49) {
                  wus++;
                  final statusKawin = individu['status_perkawinan'] as String?;
                  final hubunganKeluarga =
                      (individu['hubungan_keluarga'] as String?)?.toUpperCase();

                  if (statusKawin == 'Kawin' ||
                      hubunganKeluarga == 'ISTRI' ||
                      hubunganKeluarga == 'KEPALA RUMAH TANGGA') {
                    pus++;
                  }
                }
              } catch (_) {}
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

    final kaderQuery = await db.query(
      'app_user',
      where:
          "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ? AND role = ?",
      whereArgs: [
        kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase(),
        'KADER',
      ],
      limit: 1,
    );

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
      SELECT m.*, i.jenis_kelamin, b.kelompok_dawis
      FROM mutasi m
      LEFT JOIN individu i ON m.id_individu_asal = i.id
      LEFT JOIN bangunan b ON m.id_bangunan = b.id
      ORDER BY m.tanggal_mutasi DESC
    ''';

    final List<Map<String, dynamic>> mutasiList = await db.rawQuery(query);

    if (kelompokName == 'Semua') {
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

    final bangunanList = await db.query(
      'bangunan',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    jumlahBangunan = bangunanList.length;

    // Group by kelompok_dawis
    Map<String, Map<String, dynamic>> kelompokMap = {};

    for (var b in bangunanList) {
      String kel = b['kelompok_dawis']?.toString() ?? 'Unassigned';
      if (kel.isEmpty) kel = 'Unassigned';

      if (!kelompokMap.containsKey(kel)) {
        kelompokMap[kel] = {
          'namaKelompok': kel,
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
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [idBangunan],
      );
      jumlahKrt += krtList.length;
      kelompokMap[kel]!['jumlahKrt'] =
          (kelompokMap[kel]!['jumlahKrt'] as int) + krtList.length;

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();

        // Get Keluarga
        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [idKrt],
        );
        jumlahKeluarga += kkList.length;
        kelompokMap[kel]!['jumlahKeluarga'] =
            (kelompokMap[kel]!['jumlahKeluarga'] as int) + kkList.length;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          // Get Individu
          final indList = await _getIndividuAktif(db, idKk);
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
      orderBy: 'CAST(nomor_urut_bangunan AS INTEGER) ASC',
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

    List<Map<String, dynamic>> bangunanDataList = [];
    int totalKrt = 0;
    int totalKeluarga = 0;
    int totalIndividu = 0;

    for (var b in bangunanList) {
      String idBangunan = b['id'].toString();

      int jKrt = 0;
      int jKeluarga = 0;
      int jIndividu = 0;

      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [idBangunan],
      );
      jKrt = krtList.length;
      totalKrt += jKrt;

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();

        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [idKrt],
        );
        jKeluarga += kkList.length;
        totalKeluarga += kkList.length;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          final indList = await _getIndividuAktif(db, idKk);
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

    final kaderQuery = await db.query(
      'app_user',
      where:
          "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ? AND role = ?",
      whereArgs: [
        kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase(),
        'KADER',
      ],
      limit: 1,
    );

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

    final bangunanListRaw = await db.query(
      'bangunan',
      orderBy: 'CAST(nomor_urut_bangunan AS INTEGER) ASC',
    );

    final bangunanList = bangunanListRaw.where((b) {
      final name = (b['kelompok_dawis']?.toString() ?? '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return name == normalizedName;
    }).toList();

    List<Map<String, dynamic>> rows = [];

    for (var b in bangunanList) {
      String idBangunan = b['id'].toString();
      String noUrutBgn = b['nomor_urut_bangunan']?.toString() ?? '';
      String namaBgn = b['nama_bangunan']?.toString() ?? '';
      String nop = b['nop_pbb']?.toString() ?? '';
      String lb = b['luas_bangunan']?.toString() ?? '';
      String ll = b['luas_tanah']?.toString() ?? '';

      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [idBangunan],
      );

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

        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [idKrt],
        );

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

          final indList = await _getIndividuAktif(db, idKk);

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
              try {
                DateTime tglLahir = DateTime.parse(tglLahirStr);
                int age = DateTime.now().year - tglLahir.year;
                if (DateTime.now().month < tglLahir.month ||
                    (DateTime.now().month == tglLahir.month &&
                        DateTime.now().day < tglLahir.day)) {
                  age--;
                }
                umur = age.toString();
              } catch (e) {
                // Ignore parse error
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

    final kaderQuery = await db.query(
      'app_user',
      where:
          "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ? AND role = ?",
      whereArgs: [
        kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase(),
        'KADER',
      ],
      limit: 1,
    );

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
    final bangunanListForKelompok = bangunanListRaw.where((b) {
      final name = (b['kelompok_dawis']?.toString() ?? '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return name == normalizedName;
    }).toList();

    List<Map<String, dynamic>> profil1KeluargaList = [];

    for (var b in bangunanListForKelompok) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );
      for (var krt in krtList) {
        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [krt['id']],
        );
        for (var kk in kkList) {
          final indList = await _getIndividuAktif(db, kk['id']);

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
              try {
                DateTime tglLahir = DateTime.parse(tglLahirStr);
                age = DateTime.now().year - tglLahir.year;
                if (DateTime.now().month < tglLahir.month ||
                    (DateTime.now().month == tglLahir.month &&
                        DateTime.now().day < tglLahir.day)) {
                  age--;
                }
              } catch (e) {
                // ignore
              }
            }

            String jk = ind['jenis_kelamin']?.toString() ?? '';
            String prefix = '';
            if (age >= 0 && age <= 4) {
              prefix = '0_4';
            } else if (age >= 5 && age <= 9)
              prefix = '5_9';
            else if (age >= 10 && age <= 14)
              prefix = '10_14';
            else if (age >= 15 && age <= 19)
              prefix = '15_19';
            else if (age >= 20 && age <= 24)
              prefix = '20_24';
            else if (age >= 25 && age <= 29)
              prefix = '25_29';
            else if (age >= 30 && age <= 34)
              prefix = '30_34';
            else if (age >= 35 && age <= 39)
              prefix = '35_39';
            else if (age >= 40 && age <= 44)
              prefix = '40_44';
            else if (age >= 45 && age <= 49)
              prefix = '45_49';
            else if (age >= 50 && age <= 54)
              prefix = '50_54';
            else if (age >= 55 && age <= 59)
              prefix = '55_59';
            else if (age >= 60 && age <= 64)
              prefix = '60_64';
            else if (age >= 65 && age <= 69)
              prefix = '65_69';
            else if (age >= 70 && age <= 74)
              prefix = '70_74';
            else if (age >= 75)
              prefix = '75_plus';

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

    final kaderQuery = await db.query(
      'app_user',
      where:
          "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ? AND role = ?",
      whereArgs: [
        kelompokName.replaceAll('.', '').replaceAll(' ', '').toLowerCase(),
        'KADER',
      ],
      limit: 1,
    );

    String rt = '';
    String rw = '';
    String namaKader = '';
    if (kaderQuery.isNotEmpty) {
      final kader = kaderQuery.first;
      rt = kader['rt']?.toString() ?? '';
      rw = kader['rw']?.toString() ?? '';
      namaKader = kader['nama']?.toString() ?? '';
    }

    return {
      'kelompokName': kelompokName,
      'rt': rt,
      'rw': rw,
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
    final kaderQuery = await db.query(
      'app_user',
      where:
          "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ? AND role = ?",
      whereArgs: [normalizedName, 'KADER'],
      limit: 1,
    );
    String namaKader = '';
    String pkkRw = rw;
    String pkkRt = rt;
    String kecamatan = '';
    String kelurahan = '';
    if (kaderQuery.isNotEmpty) {
      final k = kaderQuery.first;
      namaKader = k['nama']?.toString() ?? '';
      kecamatan = k['kecamatan']?.toString() ?? '';
      kelurahan = k['kelurahan']?.toString() ?? '';
    }

    // 1. Ambil semua bangunan yang sesuai kelompok
    final bgnList = await db.query(
      'bangunan',
      where: "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ?",
      whereArgs: [normalizedName],
    );

    final List<Map<String, dynamic>> krtRows = [];

    int no = 1;
    for (var bgn in bgnList) {
      String idBgn = bgn['id'].toString();

      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [idBgn],
      );

      for (var krt in krtList) {
        String idKrt = krt['id'].toString();
        String namaKrt = krt['nama_krt']?.toString() ?? '';

        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [idKrt],
        );

        List<String> namaKkList = [];

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
        int jumlahKeluarga = kkList.length;

        for (var kk in kkList) {
          String idKk = kk['id'].toString();

          final indList = await _getIndividuAktif(db, idKk);

          // Find Kepala Keluarga in this KK
          bool hasSuamiOrKk = false;
          String currentNamaKk = '';
          for (var ind in indList) {
            final hk = ind['hubungan_keluarga']?.toString() ?? '';

            final upperHk = hk.toUpperCase();

            if (upperHk == 'KEPALA KELUARGA' || upperHk == 'SUAMI') {
              hasSuamiOrKk = true;
            }
            if (upperHk == 'KEPALA KELUARGA' || upperHk == 'KK') {
              currentNamaKk = ind['nama_lengkap']?.toString() ?? '';
            }
          }

          if (currentNamaKk.isNotEmpty) {
            namaKkList.add(currentNamaKk);
          } else if (kkList.length == 1) {
            // fallback
            namaKkList.add(namaKrt);
          }

          for (var ind in indList) {
            final jk = ind['jenis_kelamin']?.toString() ?? '';
            if (jk == 'Laki-laki') countL++;
            if (jk == 'Perempuan') countP++;

            // Hitung umur
            String tglLahirStr = ind['tanggal_lahir']?.toString() ?? '';
            int age = -1;
            if (tglLahirStr.isNotEmpty) {
              try {
                DateTime tglLahir = DateTime.parse(tglLahirStr);
                age = DateTime.now().year - tglLahir.year;
                if (DateTime.now().month < tglLahir.month ||
                    (DateTime.now().month == tglLahir.month &&
                        DateTime.now().day < tglLahir.day)) {
                  age--;
                }
              } catch (_) {}
            }

            if (age >= 0) {
              if (age < 5) {
                balita++;
              } else if (age >= 5 && age < 10)
                anak++;
              else if (age >= 10 && age < 25)
                remaja++;
              else if (age >= 25 && age < 60)
                dewasa++;
              else if (age >= 60)
                lansia++;
            }

            // PUS
            final statKawin = ind['status_perkawinan']?.toString() ?? '';
            if (jk == 'Perempuan' &&
                (statKawin.toLowerCase() == 'kawin' ||
                    statKawin.toLowerCase() == 'menikah') &&
                age >= 15 &&
                age < 50 &&
                hasSuamiOrKk) {
              countPUS++;
            }

            // KB
            final kb = ind['metode_kb']?.toString() ?? '';
            if (kb == 'MOW/Steril Wanita') {
              mow++;
            } else if (kb == 'MOP/Steril Pria')
              mop++;
            else if (kb == 'IUD/Spiral/AKDR')
              iud++;
            else if (kb == 'Implant/Susuk')
              implant++;
            else if (kb == 'Suntik')
              suntik++;
            else if (kb == 'Pil')
              pil++;
            else if (kb == 'Kondom')
              kondom++;

            // Bukan KB
            final bukanKb = ind['alasan_bukan_kb']?.toString() ?? '';
            if (bukanKb == 'Hamil') {
              hamil++;
            } else if (bukanKb == 'IAS')
              ias++;
            else if (bukanKb == 'IAT')
              iat++;
            else if (bukanKb == 'TIAL')
              tial++;
          }
        }

        krtRows.add({
          'no': no++,
          'namaKrt': namaKrt,
          'namaKk': namaKkList.join(', '),
          'L': countL,
          'P': countP,
          'jumlah': countL + countP,
          'balita': balita,
          'anak': anak,
          'remaja': remaja,
          'dewasa': dewasa,
          'lansia': lansia,
          'jumlahKeluarga': jumlahKeluarga,
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

    final bgnList = await db.query(
      'bangunan',
      columns: ['id'],
      where: "LOWER(REPLACE(REPLACE(kelompok_dawis, '.', ''), ' ', '')) = ?",
      whereArgs: [normalizedName],
    );

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

    for (var kel in kelList) {
      final kelId = kel['id'];

      final individuList = await _getIndividuAktif(db, kelId);

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
          try {
            final birthDate = DateTime.parse(tglLahir);
            final today = DateTime.now();
            umur = today.year - birthDate.year;
            if (today.month < birthDate.month ||
                (today.month == birthDate.month && today.day < birthDate.day)) {
              umur--;
            }
          } catch (_) {}
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
    final List<Map<String, dynamic>> bangunanListRaw = await db.rawQuery(
      '''
      SELECT DISTINCT b.id, b.nama_bangunan 
      FROM bangunan b
      WHERE LOWER(REPLACE(REPLACE(b.kelompok_dawis, '.', ''), ' ', '')) = ?
      ORDER BY b.nama_bangunan ASC
    ''',
      [normalizedName],
    );

    List<Map<String, dynamic>> result = [];
    int no = 1;

    for (var bgnRow in bangunanListRaw) {
      final idBangunan = bgnRow['id']?.toString() ?? '';
      final namaBangunan = bgnRow['nama_bangunan']?.toString() ?? '';

      // Count KRT in this bangunan
      final krtRes = await db.rawQuery(
        '''
        SELECT COUNT(*) FROM krt k
        WHERE k.id_bangunan = ?
      ''',
        [idBangunan],
      );
      final krtCount = krtRes.isNotEmpty
          ? (krtRes.first.values.first as int? ?? 0)
          : 0;

      // Count KK in this bangunan
      final kkRes = await db.rawQuery(
        '''
        SELECT COUNT(DISTINCT kel.id) FROM keluarga kel
        JOIN krt k ON kel.id_krt = k.id
        WHERE k.id_bangunan = ?
      ''',
        [idBangunan],
      );
      final kkCount = kkRes.isNotEmpty
          ? (kkRes.first.values.first as int? ?? 0)
          : 0;

      // Demographics in this bangunan
      final individuList = await db.rawQuery(
        '''
        SELECT i.*, 
        CAST((julianday('now') - julianday(i.tanggal_lahir)) / 365.25 AS INTEGER) as umur
        FROM individu i
        JOIN keluarga kel ON i.id_keluarga = kel.id
        JOIN krt k ON kel.id_krt = k.id
        WHERE k.id_bangunan = ?
        AND i.id NOT IN (
            SELECT id_individu_asal FROM mutasi 
            WHERE id_individu_asal IS NOT NULL 
            AND jenis_mutasi IN ('Meninggal', 'Pindah')
          )
      ''',
        [idBangunan],
      );

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
        final umur = ind['umur'] as int? ?? 0;
        final isKawin =
            (ind['status_perkawinan']?.toString().toUpperCase() == 'KAWIN');
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

        // REMAJA (10-18)
        if (umur >= 10 && umur <= 18) {
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
        if (isP && umur >= 15 && umur <= 49 && isKawin) {
          pus++;
          final kb = ind['metode_kb']?.toString().toUpperCase() ?? '';
          if (kb.contains('PIL')) {
            kbPil++;
          } else if (kb.contains('IUD'))
            kbIud++;
          else if (kb.contains('IMPLAN'))
            kbImplan++;
          else if (kb.contains('SUNTIK'))
            kbSuntik++;
          else if (kb.contains('KONDOM'))
            kbKondom++;
          else if (kb.contains('MOW') ||
              kb.contains('MOP') ||
              kb.contains('STERIL'))
            kbSteril++;
          else if (kb.isNotEmpty &&
              !kb.contains('TIDAK') &&
              kb != 'N/A' &&
              kb != 'NULL')
            kbLainnya++;
          else
            tidakKb++;
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

      result.add({
        'no': no++,
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

        'ket': '',
      });
    }

    return result;
  }

  @override
  Future<List<Map<String, String>>> getAllKelompokDawisList() async {
    final db = await LocalDbHelper.database;
    final result = await db.query(
      'app_user',
      columns: ['kelompok_dawis', 'rt', 'rw', 'id_kader'],
      where: 'role = ?',
      whereArgs: ['KADER'],
      orderBy: 'kelompok_dawis ASC',
    );
    return result
        .map(
          (row) => {
            'kelompok_dawis': row['kelompok_dawis']?.toString() ?? '',
            'rt': row['rt']?.toString() ?? '',
            'rw': row['rw']?.toString() ?? '',
            'id_kader': row['id_kader']?.toString() ?? '',
          },
        )
        .where((map) => map['kelompok_dawis']!.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getIndividuAktif(
    Database db,
    Object? idKeluarga,
  ) async {
    return await db.rawQuery(
      '''
      SELECT * FROM individu 
      WHERE id_keluarga = ? 
      AND id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
    ''',
      [idKeluarga],
    );
  }
}

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepository();
});
