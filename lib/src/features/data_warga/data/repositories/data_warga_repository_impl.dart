import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/extensions/supabase_extensions.dart';
import '../../../settings/domain/entities/app_user.dart';
import '../../domain/entities/data_warga_bangunan.dart';
import '../../domain/entities/data_warga_keluarga.dart';
import '../../domain/repositories/data_warga_repository.dart';

class DataWargaRepositoryImpl implements DataWargaRepository {
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
  Future<List<String>> getRtList(AppUser user) async {
    final response = await _fetchAll('bangunan', 'rw, rt, kelompok_dawis');

    Iterable<dynamic> filteredResults = response.where((e) {
      final rt = e['rt']?.toString() ?? '';
      if (rt.isEmpty) return false;

      final bRw = int.tryParse(e['rw']?.toString() ?? '0') ?? 0;
      final bRt = int.tryParse(rt) ?? 0;

      final uRw = int.tryParse(user.rw ?? '0') ?? 0;
      final uRt = int.tryParse(user.rt ?? '0') ?? 0;

      if (user.role == 'RW') {
        if (bRw != uRw) return false;
      } else if (user.role == 'RT') {
        if (bRw != uRw || bRt != uRt) return false;
      }
      return true;
    });

    if (user.role == 'KADER' && user.kelompokDawis != null) {
      final normalizedName = user.kelompokDawis!
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      filteredResults = filteredResults.where((e) {
        final kd = e['kelompok_dawis']?.toString() ?? '';
        final normalizedKd = kd
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
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
    // 1. Fetch all Bangunan
    final allBangunan = await _fetchAll('bangunan');

    // 2. Filter Bangunan based on Role and RT Filter
    var filteredBangunan = allBangunan.where((b) {
      final bRw = int.tryParse(b['rw']?.toString() ?? '0') ?? 0;
      final bRt = int.tryParse(b['rt']?.toString() ?? '0') ?? 0;
      final uRw = int.tryParse(user.rw ?? '0') ?? 0;
      final uRt = int.tryParse(user.rt ?? '0') ?? 0;

      if (user.role == 'RW') {
        if (bRw != uRw) return false;
      } else if (user.role == 'RT') {
        if (bRw != uRw || bRt != uRt) return false;
      }

      if (rtFilter != null && rtFilter.isNotEmpty && rtFilter != 'Semua') {
        final rtF = int.tryParse(rtFilter) ?? 0;
        if (bRt != rtF) return false;
      }

      if (user.role == 'KADER' && user.kelompokDawis != null) {
        final normalizedName = user.kelompokDawis!
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        final kd = b['kelompok_dawis']?.toString() ?? '';
        final normalizedKd = kd
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (normalizedKd != normalizedName) return false;
      }

      return true;
    }).toList();

    if (filteredBangunan.isEmpty) return [];

    // 3. Fetch related data
    final krtList = await _fetchAll('krt', 'id, id_bangunan, nama_krt');
    final keluargaList = await _fetchAll('keluarga', 'id, id_krt');
    final individuList = await _fetchAll(
      'individu',
      'id, id_keluarga, jenis_kelamin, nama_lengkap',
    );

    // Map relationships
    Map<String, List<Map<String, dynamic>>> bToKrt = {};
    Map<String, List<Map<String, dynamic>>> krtToKel = {};
    Map<String, List<Map<String, dynamic>>> kelToInd = {};

    for (var krt in krtList) {
      final bId = krt['id_bangunan'] as String?;
      if (bId != null) {
        bToKrt.putIfAbsent(bId, () => []).add(krt);
      }
    }
    for (var kel in keluargaList) {
      final krtId = kel['id_krt'] as String?;
      if (krtId != null) {
        krtToKel.putIfAbsent(krtId, () => []).add(kel);
      }
    }
    for (var ind in individuList) {
      final kelId = ind['id_keluarga'] as String?;
      if (kelId != null) {
        kelToInd.putIfAbsent(kelId, () => []).add(ind);
      }
    }

    // 4. Aggregate & Apply Search Query
    List<DataWargaBangunan> result = [];
    final sq = searchQuery?.toLowerCase() ?? '';

    for (var b in filteredBangunan) {
      final bId = b['id'] as String;
      final krts = bToKrt[bId] ?? [];

      int totalKk = 0;
      int lakiLaki = 0;
      int perempuan = 0;
      int totalPenghuni = 0;

      bool searchMatch = false;

      if (sq.isNotEmpty) {
        if ((b['nama_bangunan']?.toString().toLowerCase().contains(sq) ??
                false) ||
            (b['alamat_lengkap']?.toString().toLowerCase().contains(sq) ??
                false)) {
          searchMatch = true;
        }
      } else {
        searchMatch = true; // no search query
      }

      for (var krt in krts) {
        if (!searchMatch && sq.isNotEmpty) {
          if (krt['nama_krt']?.toString().toLowerCase().contains(sq) ?? false) {
            searchMatch = true;
          }
        }

        final krtId = krt['id'] as String;
        final kels = krtToKel[krtId] ?? [];
        totalKk += kels.length;

        for (var kel in kels) {
          final kelId = kel['id'] as String;
          final inds = kelToInd[kelId] ?? [];
          totalPenghuni += inds.length;

          for (var ind in inds) {
            if (!searchMatch && sq.isNotEmpty) {
              if (ind['nama_lengkap']?.toString().toLowerCase().contains(sq) ??
                  false) {
                searchMatch = true;
              }
            }

            if (ind['jenis_kelamin'] == 'Laki-laki') lakiLaki++;
            if (ind['jenis_kelamin'] == 'Perempuan') perempuan++;
          }
        }
      }

      if (searchMatch) {
        result.add(
          DataWargaBangunan(
            id: bId,
            namaBangunan: b['nama_bangunan']?.toString() ?? '',
            nomorBangunan: b['nomor_urut_bangunan']?.toString(),
            alamat: b['alamat_lengkap']?.toString() ?? '',
            rt: b['rt']?.toString() ?? '',
            rw: b['rw']?.toString() ?? '',
            kelurahan: '', // unused in legacy
            totalPenghuni: totalPenghuni,
            totalKk: totalKk,
            lakiLaki: lakiLaki,
            perempuan: perempuan,
            kategoriBangunan: int.tryParse(
              b['kategori_bangunan']?.toString() ?? '',
            ),
          ),
        );
      }
    }

    result.sort((a, b) => a.namaBangunan.compareTo(b.namaBangunan));
    return result;
  }

  @override
  Future<List<DataWargaKeluarga>> getKeluargaList(String bangunanId) async {
    // 1. Fetch KRT for the Bangunan
    final krtList = await _supabase
        .from('krt')
        .select('id, id_bangunan, nama_krt')
        .eq('id_bangunan', bangunanId);
    if (krtList.isEmpty) return [];

    final krtIds = krtList.map((k) => k['id'] as String).toSet();

    // 2. Fetch Keluarga for these KRTs
    final kels = await _supabase
        .from('keluarga')
        .select('id, id_krt, no_kk, id_kepala_keluarga')
        .inFilter('id_krt', krtIds.toList());
    if (kels.isEmpty) return [];

    final kelIds = kels.map((k) => k['id'] as String).toSet();

    // 3. Fetch Individu
    final inds = await _supabase
        .from('individu')
        .select('id, id_keluarga, nama_lengkap, hubungan_keluarga')
        .inFilter('id_keluarga', kelIds.toList());

    // 4. Fetch Bangunan status_hunian
    final bangunan = await _supabase
        .from('bangunan')
        .select('status_hunian')
        .eq('id', bangunanId)
        .maybeSingle();
    final statusHunian =
        bangunan?['status_hunian']?.toString() ?? 'Tidak Diketahui';

    // Build Maps
    Map<String, Map<String, dynamic>> krtMap = {
      for (var k in krtList) k['id']: k,
    };
    Map<String, List<Map<String, dynamic>>> kelToInd = {};
    for (var ind in inds) {
      kelToInd.putIfAbsent(ind['id_keluarga'], () => []).add(ind);
    }

    // Map to Entities
    List<DataWargaKeluarga> result = [];
    for (var kel in kels) {
      final krt = krtMap[kel['id_krt']];
      final kelInds = kelToInd[kel['id']] ?? [];

      String namaKepala = '[KK Kosong / Pindah]';
      if (kelInds.isNotEmpty) {
        namaKepala = 'Tanpa Nama';
        final idKk = kel['id_kepala_keluarga']?.toString();
        if (idKk != null && idKk.isNotEmpty) {
          final matched = kelInds.cast<Map<String, dynamic>?>().firstWhere(
            (ind) => ind?['id'] == idKk,
            orElse: () => null,
          );
          if (matched != null) {
            namaKepala = matched['nama_lengkap']?.toString() ?? 'Tanpa Nama';
          }
        }

        if (namaKepala == 'Tanpa Nama') {
          for (var ind in kelInds) {
            final hk = ind['hubungan_keluarga']?.toString().toUpperCase() ?? '';
            if (hk == 'KK' ||
                hk == 'KEPALA KELUARGA' ||
                hk == 'KEPALA RUMAH TANGGA') {
              namaKepala = ind['nama_lengkap']?.toString() ?? 'Tanpa Nama';
              break;
            }
          }
        }
        if (namaKepala == 'Tanpa Nama' && kelInds.isNotEmpty) {
          namaKepala =
              kelInds.first['nama_lengkap']?.toString() ?? 'Tanpa Nama';
        }
      } else {
        namaKepala = krt?['nama_krt']?.toString() ?? 'Tanpa Nama';
      }

      result.add(
        DataWargaKeluarga(
          id: kel['id']?.toString() ?? '',
          idKrt: kel['id_krt']?.toString() ?? '',
          namaKepalaKeluarga: namaKepala,
          noKk: kel['no_kk']?.toString() ?? '-',
          jumlahAnggota: kelInds.length,
          statusHunian: statusHunian,
        ),
      );
    }

    result.sort((a, b) => a.namaKepalaKeluarga.compareTo(b.namaKepalaKeluarga));
    return result;
  }
}
