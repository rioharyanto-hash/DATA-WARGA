import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/individu_model.dart';
import '../../domain/entities/individu.dart';

class IndividuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Set<String>> _getExcludedIndividuIds() async {
    final response = await _supabase
        .from('mutasi')
        .select('id_individu_asal')
        .inFilter('jenis_mutasi', ['Meninggal', 'Pindah']);
    return response
        .map((e) => e['id_individu_asal']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> insertIndividu(Individu individu) async {
    final model = IndividuModel.fromEntity(individu);
    await _supabase.from('individu').upsert(model.toJson());
  }

  Future<void> updateIndividu(Individu individu) async {
    final model = IndividuModel.fromEntity(individu);
    await _supabase
        .from('individu')
        .update(model.toJson())
        .eq('id', individu.id);
  }

  Future<void> deleteIndividu(String id) async {
    await _supabase.from('individu').delete().eq('id', id);
  }

  Future<List<Individu>> getIndividuByKeluargaId(String keluargaId) async {
    final excludedIds = await _getExcludedIndividuIds();
    final response = await _supabase
        .from('individu')
        .select()
        .eq('id_keluarga', keluargaId);

    final filtered = response
        .where((e) => !excludedIds.contains(e['id']))
        .toList();
    return filtered.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> getPenggantiKkCandidates(
    String keluargaId,
    String excludeId,
  ) async {
    final excludedIds = await _getExcludedIndividuIds();
    final response = await _supabase
        .from('individu')
        .select()
        .eq('id_keluarga', keluargaId);

    final filtered = response
        .where((e) => e['id'] != excludeId && !excludedIds.contains(e['id']))
        .toList();
    return filtered.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> getPenggantiKrtCandidates(
    String bangunanId,
    String excludeId,
  ) async {
    // 1. Get KRT for this bangunan
    final krts = await _supabase
        .from('krt')
        .select('id')
        .eq('id_bangunan', bangunanId);
    if (krts.isEmpty) return [];
    final krtIds = krts.map((k) => k['id'] as String).toList();

    // 2. Get Keluarga for these KRTs
    final kels = await _supabase
        .from('keluarga')
        .select('id')
        .inFilter('id_krt', krtIds);
    if (kels.isEmpty) return [];
    final kelIds = kels.map((k) => k['id'] as String).toList();

    // 3. Get Individu
    final response = await _supabase
        .from('individu')
        .select()
        .inFilter('id_keluarga', kelIds);

    final excludedIds = await _getExcludedIndividuIds();

    final filtered = response.where((e) {
      if (e['id'] == excludeId) return false;
      if (excludedIds.contains(e['id'])) return false;

      final hk = e['hubungan_keluarga']?.toString().toUpperCase() ?? '';
      return hk == 'KK' || hk == 'KEPALA KELUARGA';
    }).toList();

    return filtered.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<List<Individu>> searchIndividu(
    String query, {
    String? kelompokDawis,
  }) async {
    final excludedIds = await _getExcludedIndividuIds();

    List<Map<String, dynamic>> response;

    if (kelompokDawis != null &&
        kelompokDawis.isNotEmpty &&
        kelompokDawis != 'Semua') {
      // Need to filter by kelompok_dawis
      final bs = await _supabase.from('bangunan').select('id, kelompok_dawis');

      final normalizedDawis = kelompokDawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      final validBids = bs
          .where((b) {
            final kd = b['kelompok_dawis']?.toString() ?? '';
            return kd.replaceAll('.', '').replaceAll(' ', '').toLowerCase() ==
                normalizedDawis;
          })
          .map((b) => b['id'] as String)
          .toList();

      if (validBids.isEmpty) return [];

      final krts = await _supabase
          .from('krt')
          .select('id')
          .inFilter('id_bangunan', validBids);
      if (krts.isEmpty) return [];
      final krtIds = krts.map((k) => k['id'] as String).toList();

      final kels = await _supabase
          .from('keluarga')
          .select('id')
          .inFilter('id_krt', krtIds);
      if (kels.isEmpty) return [];
      final kelIds = kels.map((k) => k['id'] as String).toList();

      response = await _supabase
          .from('individu')
          .select()
          .inFilter('id_keluarga', kelIds);
    } else {
      response = await _supabase.from('individu').select();
    }

    final q = query.toLowerCase();
    final filtered = response.where((e) {
      if (excludedIds.contains(e['id'])) return false;
      final name = e['nama_lengkap']?.toString().toLowerCase() ?? '';
      if (q.isNotEmpty && !name.contains(q)) return false;
      return true;
    }).toList();

    return filtered.map((json) => IndividuModel.fromJson(json)).toList();
  }

  Future<Individu?> getIndividuById(String id) async {
    final response = await _supabase
        .from('individu')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response != null) {
      return IndividuModel.fromJson(response);
    }
    return null;
  }

  Future<Map<String, String?>> getParentsNames(String idKeluarga) async {
    final response = await _supabase
        .from('individu')
        .select('nama_lengkap, hubungan_keluarga, jenis_kelamin')
        .eq('id_keluarga', idKeluarga);

    String? namaAyah;
    String? namaIbu;

    for (var row in response) {
      final hk =
          row['hubungan_keluarga']
              ?.toString()
              .replaceAll('.', '')
              .toUpperCase() ??
          '';
      final jk = row['jenis_kelamin']?.toString().toUpperCase() ?? '';
      final nama = row['nama_lengkap']?.toString();

      final isKK =
          hk == 'KK' || hk == 'KEPALA KELUARGA' || hk == 'KEPALA RUMAH TANGGA';

      if (namaAyah == null && isKK && jk == 'LAKI-LAKI') {
        namaAyah = nama;
      }

      if (namaIbu == null) {
        if (hk == 'ISTRI' || (isKK && jk == 'PEREMPUAN')) {
          namaIbu = nama;
        }
      }
    }

    return {'nama_ayah': namaAyah, 'nama_ibu': namaIbu};
  }
}
