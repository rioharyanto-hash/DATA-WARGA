import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/keluarga_model.dart';
import '../../domain/entities/keluarga.dart';

class KeluargaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertKeluarga(Keluarga keluarga) async {
    final model = KeluargaModel.fromEntity(keluarga);
    await _supabase.from('keluarga').upsert(model.toJson());
  }

  Future<List<Keluarga>> getKeluargaByKrtId(String krtId) async {
    final response = await _supabase
        .from('keluarga')
        .select()
        .eq('id_krt', krtId);
    if (response.isEmpty) return [];

    final kelIds = response.map((e) => e['id'] as String).toList();
    final individuList = await _supabase
        .from('individu')
        .select('id_keluarga, nama_lengkap, hubungan_keluarga')
        .inFilter('id_keluarga', kelIds);

    Map<String, List<dynamic>> kelToInds = {};
    for (var ind in individuList) {
      kelToInds.putIfAbsent(ind['id_keluarga'], () => []).add(ind);
    }

    List<Keluarga> results = [];
    for (var kel in response) {
      final iList = kelToInds[kel['id']] ?? [];
      String namaKepala = 'Tanpa Nama';
      for (var ind in iList) {
        final hk = ind['hubungan_keluarga']?.toString().toUpperCase() ?? '';
        if (hk == 'KK' ||
            hk == 'KEPALA KELUARGA' ||
            hk == 'KEPALA RUMAH TANGGA') {
          namaKepala = ind['nama_lengkap']?.toString() ?? 'Tanpa Nama';
          break;
        }
      }

      final mod = Map<String, dynamic>.from(kel);
      mod['nama_kepala_keluarga'] = namaKepala;
      results.add(KeluargaModel.fromJson(mod));
    }
    return results;
  }

  Future<Keluarga?> getKeluargaById(String id) async {
    final response = await _supabase
        .from('keluarga')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return KeluargaModel.fromJson(response);
  }

  Future<bool> isNoKkExists(String noKk, {String? excludeId}) async {
    // If no_kk is empty or just a placeholder like '-', we can optionally allow it,
    // but typically we should check if it's identical unless it's '-'
    if (noKk.trim().isEmpty || noKk.trim() == '-') return false;

    var query = _supabase
        .from('keluarga')
        .select('id')
        .eq('no_kk', noKk.trim());

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final response = await query.limit(1);
    return response.isNotEmpty;
  }

  Future<void> updateKeluarga(Keluarga keluarga) async {
    final model = KeluargaModel.fromEntity(keluarga);
    await _supabase
        .from('keluarga')
        .update(model.toJson())
        .eq('id', keluarga.id);
  }

  Future<void> deleteKeluarga(String id) async {
    await _supabase.from('keluarga').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> searchKeluargaWithKrtName(
    String query, {
    String? kelompokDawis,
  }) async {
    final kels = await _supabase.from('keluarga').select();
    final krts = await _supabase.from('krt').select();
    final bs = await _supabase.from('bangunan').select();
    final inds = await _supabase.from('individu').select();

    final krtMap = {for (var x in krts) x['id']: x};
    final bMap = {for (var x in bs) x['id']: x};
    final kelToInds = <String, List<dynamic>>{};
    for (var ind in inds) {
      kelToInds
          .putIfAbsent(ind['id_keluarga']?.toString() ?? '', () => [])
          .add(ind);
    }

    final String q = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    for (var kel in kels) {
      final kId = kel['id'] as String;
      final krtId = kel['id_krt'];
      final krt = krtMap[krtId];
      final b = bMap[krt?['id_bangunan']];

      final kDawis = b?['kelompok_dawis']?.toString() ?? '';

      if (kelompokDawis != null &&
          kelompokDawis != 'Semua' &&
          kelompokDawis.isNotEmpty) {
        final normReq = kelompokDawis
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        final normAct = kDawis
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (normReq != normAct) continue;
      }

      final iList = kelToInds[kId] ?? [];

      dynamic kkInd;
      for (var ind in iList) {
        final hk = ind['hubungan_keluarga']?.toString().toUpperCase() ?? '';
        if (hk == 'KEPALA KELUARGA' ||
            hk == 'KK' ||
            hk == 'KEPALA RUMAH TANGGA' ||
            hk.startsWith('KK ')) {
          kkInd = ind;
          break;
        }
      }

      final namaKrt =
          kkInd?['nama_lengkap'] ?? krt?['nama_krt'] ?? 'Tanpa Nama';
      final noKk = kel['no_kk']?.toString() ?? '';

      bool isMatch = false;
      if (q.isEmpty) {
        isMatch = true;
      } else {
        if (noKk.toLowerCase().contains(q) ||
            namaKrt.toString().toLowerCase().contains(q)) {
          isMatch = true;
        } else {
          for (var ind in iList) {
            if (ind['nama_lengkap']?.toString().toLowerCase().contains(q) ==
                true) {
              isMatch = true;
              break;
            }
          }
        }
      }

      if (!isMatch) continue;

      final anggota = iList
          .map((i) => i['nama_lengkap'])
          .where((n) => n != null && n.toString().isNotEmpty)
          .join(', ');

      results.add({
        'keluarga_id': kId,
        'no_kk': noKk,
        'nama_krt': namaKrt,
        'individu_krt_id': kkInd?['id'],
        'kelompok_dawis': kDawis,
        'anggota_keluarga': anggota,
      });
    }

    results.sort((a, b) {
      int c1 = (a['kelompok_dawis'] ?? '').compareTo(b['kelompok_dawis'] ?? '');
      if (c1 != 0) return c1;
      int c2 = (a['nama_krt'] ?? '').compareTo(b['nama_krt'] ?? '');
      if (c2 != 0) return c2;
      return (a['no_kk'] ?? '').compareTo(b['no_kk'] ?? '');
    });

    return results.take(50).toList();
  }
}
