import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchAll(
    String table, [
    String? columns,
  ]) async {
    List<Map<String, dynamic>> allData = [];
    int offset = 0;
    const int limit = 1000;
    while (true) {
      final res = await _supabase
          .from(table)
          .select(columns ?? '*')
          .range(offset, offset + limit - 1);
      allData.addAll(List<Map<String, dynamic>>.from(res));
      if (res.length < limit) break;
      offset += limit;
    }
    return allData;
  }

  @override
  Future<Map<String, List<String>>> getFilterOptions({
    String? rw,
    String? rt,
  }) async {
    final response = await _fetchAll('bangunan', 'rw, rt, kelompok_dawis');

    final rwSet = <String>{};
    final rtSet = <String>{};
    final kaderSet = <String>{};

    for (var b in response) {
      final bRw = b['rw']?.toString() ?? '';
      final bRt = b['rt']?.toString() ?? '';
      final bKd = b['kelompok_dawis']?.toString() ?? '';

      if (bRw.isNotEmpty) rwSet.add(bRw);

      bool matchRw = rw == null || rw.isEmpty || bRw == rw;
      if (matchRw && bRt.isNotEmpty) rtSet.add(bRt);

      bool matchRt = rt == null || rt.isEmpty || bRt == rt;
      if (matchRw && matchRt && bKd.isNotEmpty) kaderSet.add(bKd);
    }

    final rwList = rwSet.toList()..sort();
    final rtList = rtSet.toList()..sort();
    final kaderList = kaderSet.toList()..sort();

    return {'rw': rwList, 'rt': rtList, 'kader': kaderList};
  }

  int _calculateAge(String? tglLahir) {
    if (tglLahir == null || tglLahir.isEmpty) return -1;
    try {
      final birthDate = DateTime.parse(tglLahir);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      // If the date format is different (e.g. DD/MM/YYYY), handle it
      // Standard SQLite is YYYY-MM-DD
      return -1;
    }
  }

  @override
  Future<DashboardSummary> getDashboardSummary({
    String? rw,
    String? rt,
    String? kelompokDawis,
  }) async {
    final emptySummary = DashboardSummary(
      jumlahBangunan: 0,
      jumlahKk: 0,
      jumlahMutasi: 0,
      jumlahBalita: 0,
      jumlahLansia: 0,
      jumlahWus: 0,
      jumlahPus: 0,
      jumlahLakiLaki: 0,
      jumlahPerempuan: 0,
      pendidikanGrouping: {},
      pekerjaanGrouping: {},
      umurGrouping: {},
      jumlahDisabilitas: 0,
      jumlahLahir: 0,
      jumlahMeninggal: 0,
      jumlahPindah: 0,
      jumlahDatang: 0,
    );

    if (kelompokDawis == 'Semua') kelompokDawis = null;

    final allBangunan = await _fetchAll(
      'bangunan',
      'id, rw, rt, kelompok_dawis',
    );

    final filteredBangunan = allBangunan.where((b) {
      if (rw != null &&
          rw.isNotEmpty &&
          rw != 'Semua' &&
          b['rw']?.toString() != rw) {
        return false;
      }
      if (rt != null &&
          rt.isNotEmpty &&
          rt != 'Semua' &&
          b['rt']?.toString() != rt) {
        return false;
      }
      if (kelompokDawis != null && kelompokDawis.isNotEmpty) {
        final kd =
            b['kelompok_dawis']
                ?.toString()
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase() ??
            '';
        final nkd = kelompokDawis
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (kd != nkd) return false;
      }
      return true;
    }).toList();

    if (filteredBangunan.isEmpty) {
      return emptySummary;
    }

    final bIds = filteredBangunan.map((e) => e['id'] as String).toSet();

    final allKrt = await _fetchAll('krt', 'id, id_bangunan');
    final krtIds = allKrt
        .where((k) => bIds.contains(k['id_bangunan']))
        .map((k) => k['id'] as String)
        .toSet();

    final allKeluarga = await _fetchAll('keluarga', 'id, id_krt');
    final kelIds = allKeluarga
        .where((k) => krtIds.contains(k['id_krt']))
        .map((k) => k['id'] as String)
        .toSet();

    final allIndividu = await _fetchAll('individu');
    final filteredIndividu = allIndividu
        .where((i) => kelIds.contains(i['id_keluarga']))
        .toList();

    final allMutasi = await _fetchAll('mutasi', 'id_bangunan, jenis_mutasi');
    final filteredMutasi = allMutasi
        .where((m) => bIds.contains(m['id_bangunan']))
        .toList();

    // Counts
    int balitaCount = 0;
    int lansiaCount = 0;
    int wusCount = 0;
    int pusCount = 0;
    int lakiLakiCount = 0;
    int perempuanCount = 0;
    int anakCount = 0;
    int remajaCount = 0;
    int dewasaCount = 0;
    int disabilitasCount = 0;

    Map<String, int> pendidikanGrouping = {};
    Map<String, int> pekerjaanGrouping = {};

    for (var ind in filteredIndividu) {
      final jk = ind['jenis_kelamin']?.toString();
      final tglLahir = ind['tanggal_lahir']?.toString();
      final hub = ind['hubungan_keluarga']?.toString().toUpperCase();
      final pdd = ind['pendidikan_terakhir']?.toString() ?? 'Tidak Diketahui';
      final pkj = ind['pekerjaan']?.toString() ?? 'Tidak Diketahui';
      final disabilitas = ind['kriteria_berkebutuhan_khusus']?.toString();

      int age = _calculateAge(tglLahir);

      if (jk == 'Laki-laki') lakiLakiCount++;
      if (jk == 'Perempuan') perempuanCount++;

      if (age >= 0 && age <= 4) balitaCount++;
      if (age >= 5 && age <= 9) anakCount++;
      if (age >= 10 && age <= 24) remajaCount++;
      if (age >= 25 && age <= 59) dewasaCount++;
      if (age >= 60) lansiaCount++;

      if (jk == 'Perempuan' && age >= 15 && age <= 49) wusCount++;
      if (hub == 'ISTRI' && age >= 15 && age <= 49) pusCount++;

      if (disabilitas != null &&
          disabilitas.isNotEmpty &&
          disabilitas.toUpperCase() != 'TIDAK ADA' &&
          disabilitas.toUpperCase() != 'TIDAK') {
        disabilitasCount++;
      }

      pendidikanGrouping[pdd] = (pendidikanGrouping[pdd] ?? 0) + 1;
      pekerjaanGrouping[pkj] = (pekerjaanGrouping[pkj] ?? 0) + 1;
    }

    int lahirCount = 0;
    int matiCount = 0;
    int pindahCount = 0;
    int datangCount = 0;

    for (var m in filteredMutasi) {
      final type = m['jenis_mutasi']?.toString().toUpperCase() ?? '';
      if (type == 'LAHIR') lahirCount++;
      if (type == 'MENINGGAL') matiCount++;
      if (type == 'PINDAH') pindahCount++;
      if (type == 'DATANG') datangCount++;
    }

    return DashboardSummary(
      jumlahBangunan: bIds.length,
      jumlahKk: kelIds.length,
      jumlahMutasi: filteredMutasi.length,
      jumlahBalita: balitaCount,
      jumlahLansia: lansiaCount,
      jumlahWus: wusCount,
      jumlahPus: pusCount,
      jumlahLakiLaki: lakiLakiCount,
      jumlahPerempuan: perempuanCount,
      pendidikanGrouping: pendidikanGrouping,
      pekerjaanGrouping: pekerjaanGrouping,
      umurGrouping: {
        'Balita (0-4)': balitaCount,
        'Anak (5-9)': anakCount,
        'Remaja (10-24)': remajaCount,
        'Dewasa (25-59)': dewasaCount,
        'Lansia (>=60)': lansiaCount,
      },
      jumlahDisabilitas: disabilitasCount,
      jumlahLahir: lahirCount,
      jumlahMeninggal: matiCount,
      jumlahPindah: pindahCount,
      jumlahDatang: datangCount,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDemografiDetail({
    String? rw,
    String? rt,
    String? kelompokDawis,
    required String category,
  }) async {
    if (kelompokDawis == 'Semua') kelompokDawis = null;

    final allBangunan = await _supabase
        .from('bangunan')
        .select(
          'id, rw, rt, kelompok_dawis, nama_bangunan, alamat_lengkap, nomor_urut_bangunan',
        );

    final filteredBangunan = allBangunan.where((b) {
      if (rw != null &&
          rw.isNotEmpty &&
          rw != 'Semua' &&
          b['rw']?.toString() != rw) {
        return false;
      }
      if (rt != null &&
          rt.isNotEmpty &&
          rt != 'Semua' &&
          b['rt']?.toString() != rt) {
        return false;
      }
      if (kelompokDawis != null && kelompokDawis.isNotEmpty) {
        final kd =
            b['kelompok_dawis']
                ?.toString()
                .replaceAll('.', '')
                .replaceAll(' ', '')
                .toLowerCase() ??
            '';
        final nkd = kelompokDawis
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (kd != nkd) return false;
      }
      return true;
    }).toList();

    if (filteredBangunan.isEmpty) return [];

    final bIds = filteredBangunan.map((e) => e['id'] as String).toSet();
    final bMap = {for (var b in filteredBangunan) b['id']: b};

    final allKrt = await _supabase
        .from('krt')
        .select('id, id_bangunan, nama_krt');
    final filteredKrt = allKrt
        .where((k) => bIds.contains(k['id_bangunan']))
        .toList();
    final krtIds = filteredKrt.map((k) => k['id'] as String).toSet();
    final krtMap = {for (var k in filteredKrt) k['id']: k};

    final allKeluarga = await _supabase
        .from('keluarga')
        .select('id, id_krt, no_kk');
    final filteredKeluarga = allKeluarga
        .where((k) => krtIds.contains(k['id_krt']))
        .toList();
    final kelIds = filteredKeluarga.map((k) => k['id'] as String).toSet();
    final kelMap = {for (var k in filteredKeluarga) k['id']: k};

    if (category == 'Jumlah Bangunan') {
      final list = filteredBangunan
          .map(
            (b) => {
              'rw': b['rw'] ?? '-',
              'rt': b['rt'] ?? '-',
              'nama_bangunan': b['nama_bangunan'] ?? '-',
              'alamat_lengkap': b['alamat_lengkap'] ?? '-',
              'kelompok_dawis': b['kelompok_dawis'] ?? '-',
              'nomor_urut_bangunan': b['nomor_urut_bangunan'] ?? '-',
              'alamat':
                  '${b['alamat_lengkap'] ?? ''} RT ${b['rt'] ?? '-'}/${b['rw'] ?? '-'}',
            },
          )
          .toList();

      list.sort((a, b) {
        // 1. RT
        final rtA = a['rt']?.toString().toLowerCase() ?? '';
        final rtB = b['rt']?.toString().toLowerCase() ?? '';
        final rtCompare = rtA.compareTo(rtB);
        if (rtCompare != 0) return rtCompare;

        // 2. Kelompok Dawis
        final kdWA = a['kelompok_dawis']?.toString().toLowerCase() ?? '';
        final kdWB = b['kelompok_dawis']?.toString().toLowerCase() ?? '';
        final kdCompare = kdWA.compareTo(kdWB);
        if (kdCompare != 0) return kdCompare;

        // 3. Abjad (Nama Bangunan)
        final nameA = a['nama_bangunan']?.toString().toLowerCase() ?? '';
        final nameB = b['nama_bangunan']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return list;
    }

    if (category == 'Jumlah KK') {
      final allIndividu = await _supabase
          .from('individu')
          .select(
            'id_keluarga, nama_lengkap, hubungan_keluarga, status_dgn_krt',
          );
      final filteredIndividu = allIndividu
          .where((i) => kelIds.contains(i['id_keluarga']))
          .toList();

      final list = filteredKeluarga.map((k) {
        final krt = krtMap[k['id_krt']];
        final b = krt != null ? bMap[krt['id_bangunan']] : null;

        var namaKk = krt != null ? krt['nama_krt'] : '-';
        try {
          final ind = filteredIndividu.firstWhere((i) {
            if (i['id_keluarga'] != k['id']) return false;
            final hub = i['hubungan_keluarga']?.toString().toUpperCase() ?? '';
            final stat = i['status_dgn_krt']?.toString().toUpperCase() ?? '';
            return hub == 'KK' ||
                hub == 'KEPALA KELUARGA' ||
                hub == 'KEPALA RUMAH TANGGA' ||
                stat == 'KK' ||
                stat == 'KEPALA KELUARGA' ||
                stat == 'KEPALA RUMAH TANGGA';
          });
          if (ind['nama_lengkap'] != null &&
              ind['nama_lengkap'].toString().isNotEmpty) {
            namaKk = ind['nama_lengkap'];
          }
        } catch (_) {}

        return {
          'no_kk': k['no_kk'] ?? '-',
          'nama_krt': krt != null ? krt['nama_krt'] : '-',
          'nama_kk': namaKk,
          'rt': b != null ? b['rt'] : '-',
          'rw': b != null ? b['rw'] : '-',
          'kelompok_dawis': b != null ? b['kelompok_dawis'] : '-',
          'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',
          'alamat': b != null
              ? '${b['alamat_lengkap'] ?? ''} RT ${b['rt'] ?? '-'}/${b['rw'] ?? '-'}'
              : '-',
        };
      }).toList();

      list.sort((a, b) {
        // 1. RT
        final rtA = a['rt']?.toString().toLowerCase() ?? '';
        final rtB = b['rt']?.toString().toLowerCase() ?? '';
        final rtCompare = rtA.compareTo(rtB);
        if (rtCompare != 0) return rtCompare;

        // 2. Kelompok Dawis
        final kdWA = a['kelompok_dawis']?.toString().toLowerCase() ?? '';
        final kdWB = b['kelompok_dawis']?.toString().toLowerCase() ?? '';
        final kdCompare = kdWA.compareTo(kdWB);
        if (kdCompare != 0) return kdCompare;

        // 3. Abjad (Nama KK)
        final nameA = a['nama_kk']?.toString().toLowerCase() ?? '';
        final nameB = b['nama_kk']?.toString().toLowerCase() ?? '';
        final nameCompare = nameA.compareTo(nameB);
        if (nameCompare != 0) return nameCompare;

        // 4. No KK
        final kkA = a['no_kk']?.toString().toLowerCase() ?? '';
        final kkB = b['no_kk']?.toString().toLowerCase() ?? '';
        return kkA.compareTo(kkB);
      });

      return list;
    }

    if ([
      'Total Mutasi',
      'Lahir',
      'Meninggal',
      'Pindah',
      'Datang',
    ].contains(category)) {
      final allMutasi = await _fetchAll('mutasi');
      final filteredMutasi = allMutasi
          .where((m) => bIds.contains(m['id_bangunan']))
          .toList();

      return filteredMutasi
          .where((m) {
            final type = m['jenis_mutasi']?.toString().toUpperCase() ?? '';
            if (category == 'Total Mutasi') return true;
            if (category == 'Lahir' && type == 'LAHIR') return true;
            if (category == 'Meninggal' && type == 'MENINGGAL') return true;
            if (category == 'Pindah' && type == 'PINDAH') return true;
            if (category == 'Datang' && type == 'DATANG') return true;
            return false;
          })
          .map((m) {
            final b = bMap[m['id_bangunan']];
            return {
              'nama_orang': m['nama_orang'] ?? '-',
              'jenis_mutasi': m['jenis_mutasi'],
              'keterangan_mutasi': m['keterangan_mutasi'],
              'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',
              'nama_krt': '-',
              'no_kk': '-',
              'rt': b != null ? b['rt'] : '-',
              'rw': b != null ? b['rw'] : '-',
              'alamat': b != null
                  ? '${b['alamat_lengkap'] ?? ''} RT ${b['rt'] ?? '-'}/${b['rw'] ?? '-'}'
                  : '-',
            };
          })
          .toList();
    }

    // the rest are individu-based categories
    final allIndividu = await _fetchAll('individu');
    final filteredIndividu = allIndividu
        .where((i) => kelIds.contains(i['id_keluarga']))
        .toList();

    final result = filteredIndividu
        .where((ind) {
          final jk = ind['jenis_kelamin']?.toString();
          final tglLahir = ind['tanggal_lahir']?.toString();
          final hub = ind['hubungan_keluarga']?.toString().toUpperCase();
          final disabilitas = ind['kriteria_berkebutuhan_khusus']?.toString();
          int age = _calculateAge(tglLahir);

          if (category == 'Total Penduduk') return true;
          if (category == 'Balita (0-4 thn)' && age >= 0 && age <= 4) {
            return true;
          }
          if (category == 'Anak (5-9 thn)' && age >= 5 && age <= 9) return true;
          if (category == 'Remaja (10-24 thn)' && age >= 10 && age <= 24) {
            return true;
          }
          if (category == 'Dewasa (25-59 thn)' && age >= 25 && age <= 59) {
            return true;
          }
          if (category == 'Lansia (>=60 thn)' && age >= 60) return true;
          if (category == 'Laki-laki' && jk == 'Laki-laki') return true;
          if (category == 'Perempuan' && jk == 'Perempuan') return true;
          if (category == 'WUS' &&
              jk == 'Perempuan' &&
              age >= 15 &&
              age <= 49) {
            return true;
          }
          if (category == 'PUS' && hub == 'ISTRI' && age >= 15 && age <= 49) {
            return true;
          }
          if (category == 'Disabilitas' &&
              disabilitas != null &&
              disabilitas.isNotEmpty) {
            return true;
          }

          return false;
        })
        .map((ind) {
          final k = kelMap[ind['id_keluarga']];
          final krt = k != null ? krtMap[k['id_krt']] : null;
          final b = krt != null ? bMap[krt['id_bangunan']] : null;

          final tglLahir = ind['tanggal_lahir']?.toString();
          final age = _calculateAge(tglLahir);

          String namaTampil = ind['nama_lengkap']?.toString() ?? '';
          String umurTampil = age >= 0 ? age.toString() : '-';

          if (category == 'PUS') {
            final suami = filteredIndividu.firstWhere((s) {
              final hub =
                  s['hubungan_keluarga']?.toString().toUpperCase() ?? '';
              final status =
                  s['status_dgn_krt']?.toString().toUpperCase() ?? '';
              return s['id_keluarga'] == ind['id_keluarga'] &&
                  s['id'] != ind['id'] &&
                  (hub == 'SUAMI' ||
                      hub == 'KK' ||
                      hub == 'KEPALA KELUARGA' ||
                      status == 'KK' ||
                      status == 'KEPALA KELUARGA');
            }, orElse: () => <String, dynamic>{});

            if (suami.isNotEmpty) {
              final umurSuami = _calculateAge(
                suami['tanggal_lahir']?.toString(),
              );
              final strUmurSuami = umurSuami >= 0 ? umurSuami.toString() : '-';
              namaTampil = '${suami['nama_lengkap'] ?? '-'} / $namaTampil';
              umurTampil = '$strUmurSuami / $umurTampil';
            }
          }

          return {
            'nama_lengkap': namaTampil,
            'umur': umurTampil,
            'umur_int': age,
            'nik': ind['nik'],
            'jenis_kelamin': ind['jenis_kelamin'],
            'tanggal_lahir': ind['tanggal_lahir'],
            'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',
            'nama_krt': krt != null ? krt['nama_krt'] : '-',
            'no_kk': k != null ? k['no_kk'] : '-',
            'rt': b != null ? b['rt'] : '-',
            'rw': b != null ? b['rw'] : '-',
            'alamat': b != null
                ? '${b['alamat_lengkap'] ?? ''} RT ${b['rt'] ?? '-'}/${b['rw'] ?? '-'}'
                : '-',
          };
        })
        .toList();

    result.sort((a, b) {
      final rtA = int.tryParse(a['rt']?.toString() ?? '') ?? 99999;
      final rtB = int.tryParse(b['rt']?.toString() ?? '') ?? 99999;
      final rtCompare = rtA.compareTo(rtB);
      if (rtCompare != 0) return rtCompare;

      final umurA = a['umur_int'] as int? ?? 99999;
      final umurB = b['umur_int'] as int? ?? 99999;
      final umurCompare = umurA.compareTo(umurB);
      if (umurCompare != 0) return umurCompare;

      final nameA = a['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nameB = b['nama_lengkap']?.toString().toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });

    return result;
  }
}
