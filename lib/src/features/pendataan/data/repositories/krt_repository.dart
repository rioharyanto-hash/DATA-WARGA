import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/krt_model.dart';
import '../../domain/entities/krt.dart';

class KrtRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertKrt(Krt krt) async {
    final model = KrtModel.fromEntity(krt);
    await _supabase.from('krt').upsert(model.toJson());
  }

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

  Future<List<Krt>> getKrtByBangunanId(String bangunanId) async {
    final response = await _supabase
        .from('krt')
        .select()
        .eq('id_bangunan', bangunanId)
        .order('created_at', ascending: true);
    if (response.isEmpty) return [];

    final krtIds = response.map((e) => e['id'] as String).toList();
    final kels = await _supabase
        .from('keluarga')
        .select('id, id_krt')
        .inFilter('id_krt', krtIds);
    final kelIds = kels.map((e) => e['id'] as String).toList();

    final excludedIds = await _getExcludedIndividuIds();
    final inds = kelIds.isEmpty
        ? []
        : await _supabase
              .from('individu')
              .select('id, id_keluarga')
              .inFilter('id_keluarga', kelIds);

    final activeKelIds = <String>{};
    for (var ind in inds) {
      if (!excludedIds.contains(ind['id']?.toString() ?? '')) {
        activeKelIds.add(ind['id_keluarga']?.toString() ?? '');
      }
    }

    final activeKrtIds = <String>{};
    for (var kel in kels) {
      if (activeKelIds.contains(kel['id']?.toString() ?? '')) {
        activeKrtIds.add(kel['id_krt']?.toString() ?? '');
      }
    }

    return response.map((json) {
      final mod = Map<String, dynamic>.from(json);
      final id = mod['id']?.toString() ?? '';
      if (!activeKrtIds.contains(id)) {
        final origName = mod['nama_krt']?.toString() ?? 'Tanpa Nama';
        if (!origName.contains('[Kosong')) {
          mod['nama_krt'] = '$origName [Kosong / Pindah]';
        }
      }
      return KrtModel.fromJson(mod);
    }).toList();
  }

  Future<Krt?> getKrtById(String id) async {
    final response = await _supabase
        .from('krt')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return KrtModel.fromJson(response);
  }

  Future<void> updateKrt(Krt krt) async {
    final model = KrtModel.fromEntity(krt);
    await _supabase.from('krt').update(model.toJson()).eq('id', krt.id);
  }

  Future<void> updateKrtNameAndNik(
    String krtId,
    String newName,
    String newNik,
  ) async {
    await _supabase
        .from('krt')
        .update({'nama_krt': newName, 'nik_krt': newNik, 'is_synced': 0})
        .eq('id', krtId);
  }

  Future<void> deleteKrt(String id) async {
    await _supabase.from('krt').delete().eq('id', id);
  }
}
