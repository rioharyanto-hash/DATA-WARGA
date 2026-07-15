import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/krt_model.dart';
import '../../domain/entities/krt.dart';

class KrtRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertKrt(Krt krt) async {
    final model = KrtModel.fromEntity(krt);
    await _supabase.from('krt').upsert(model.toJson());
  }

  Future<List<Krt>> getKrtByBangunanId(String bangunanId) async {
    final response = await _supabase
        .from('krt')
        .select()
        .eq('id_bangunan', bangunanId);
    return response.map((json) => KrtModel.fromJson(json)).toList();
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
