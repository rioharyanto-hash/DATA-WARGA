import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bangunan_model.dart';
import '../../domain/entities/bangunan.dart';

class BangunanRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertBangunan(Bangunan bangunan) async {
    final model = BangunanModel.fromEntity(bangunan);
    await _supabase.from('bangunan').upsert(model.toJson());
  }

  Future<List<Bangunan>> getAllBangunan() async {
    final response = await _supabase.from('bangunan').select();
    return response.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByKelompokDawis(String kelompok) async {
    final response = await _supabase.from('bangunan').select();

    final normalizedInput = kelompok
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final filteredMaps = response.where((row) {
      final dbKelompok = (row['kelompok_dawis'] as String?) ?? '';
      final normalizedDb = dbKelompok
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normalizedDb == normalizedInput;
    }).toList();

    return filteredMaps.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByRw(String rw) async {
    final response = await _supabase.from('bangunan').select();
    final irw = int.tryParse(rw) ?? 0;
    final filtered = response
        .where((b) => (int.tryParse(b['rw']?.toString() ?? '') ?? -1) == irw)
        .toList();
    return filtered.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<List<Bangunan>> getBangunanByRtRw(String rt, String rw) async {
    final response = await _supabase.from('bangunan').select();
    final irt = int.tryParse(rt) ?? 0;
    final irw = int.tryParse(rw) ?? 0;
    final filtered = response.where((b) {
      final brt = int.tryParse(b['rt']?.toString() ?? '') ?? -1;
      final brw = int.tryParse(b['rw']?.toString() ?? '') ?? -1;
      return brt == irt && brw == irw;
    }).toList();
    return filtered.map((json) => BangunanModel.fromJson(json)).toList();
  }

  Future<Bangunan?> getBangunanById(String id) async {
    final response = await _supabase
        .from('bangunan')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response != null) {
      return BangunanModel.fromJson(response);
    }
    return null;
  }

  Future<void> updateBangunan(Bangunan bangunan) async {
    final model = BangunanModel.fromEntity(bangunan);
    await _supabase
        .from('bangunan')
        .update(model.toJson())
        .eq('id', bangunan.id);
  }

  Future<void> deleteBangunan(String id) async {
    // Delete related records manually as cascade might not be configured
    final krtList = await _supabase
        .from('krt')
        .select('id')
        .eq('id_bangunan', id);
    for (var krt in krtList) {
      final krtId = krt['id'];
      final kelList = await _supabase
          .from('keluarga')
          .select('id')
          .eq('id_krt', krtId);
      for (var kel in kelList) {
        final kelId = kel['id'];
        await _supabase.from('individu').delete().eq('id_keluarga', kelId);
      }
      await _supabase.from('keluarga').delete().eq('id_krt', krtId);
    }
    await _supabase.from('krt').delete().eq('id_bangunan', id);

    // Delete bangunan
    await _supabase.from('bangunan').delete().eq('id', id);
  }

  Future<List<String>> getDistinctKelompokDawis() async {
    final response = await _supabase.from('bangunan').select('kelompok_dawis');
    final dawisSet = <String>{};
    for (var row in response) {
      final kd = row['kelompok_dawis']?.toString() ?? '';
      if (kd.isNotEmpty) {
        dawisSet.add(kd);
      }
    }
    final sortedList = dawisSet.toList()..sort();
    return sortedList;
  }
}
