import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/surat_pengantar_model.dart';
import '../../domain/entities/surat_pengantar.dart';

final suratPengantarRepositoryProvider = Provider<SuratPengantarRepository>((
  ref,
) {
  return SuratPengantarRepository();
});

class SuratPengantarRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  SuratPengantarRepository();

  static const String tableName = 'surat_pengantar';

  Future<List<SuratPengantar>> getSuratPengantarList({
    String? rt,
    String? rw,
  }) async {
    try {
      var query = _supabase.from(tableName).select();

      if (rw != null && rw.isNotEmpty) {
        query = query.eq('rw', rw);
      }
      if (rt != null && rt.isNotEmpty && rt != 'Semua RT') {
        query = query.eq('rt', rt);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => SuratPengantarModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data surat pengantar: $e');
    }
  }

  Future<SuratPengantar?> getSuratPengantarById(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return SuratPengantarModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil data surat pengantar: $e');
    }
  }

  Future<SuratPengantar> saveSuratPengantar(SuratPengantar surat) async {
    try {
      final model = SuratPengantarModel.fromEntity(surat);
      final data = model.toJson();

      // Jika ID tidak kosong, lakukan update (meskipun form umumnya create only,
      // namun praktik baik jika kita sediakan update juga).
      if (surat.id.isNotEmpty) {
        final response = await _supabase
            .from(tableName)
            .update(data)
            .eq('id', surat.id)
            .select()
            .single();
        return SuratPengantarModel.fromJson(response);
      } else {
        final response = await _supabase
            .from(tableName)
            .insert(data)
            .select()
            .single();
        return SuratPengantarModel.fromJson(response);
      }
    } catch (e) {
      throw Exception('Gagal menyimpan data surat pengantar: $e');
    }
  }

  Future<void> deleteSuratPengantar(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus surat pengantar: $e');
    }
  }
}
