import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mutasi_model.dart';
import '../../domain/entities/mutasi.dart';

class MutasiRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertMutasi(Mutasi mutasi) async {
    final model = MutasiModel.fromEntity(mutasi);
    await _supabase.from('mutasi').upsert(model.toJson());
  }

  Future<List<Mutasi>> getMutasiByBangunan(String idBangunan) async {
    final response = await _supabase
        .from('mutasi')
        .select()
        .eq('id_bangunan', idBangunan)
        .order('tanggal_mutasi', ascending: false);
    return response.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Mutasi>> getMutasiByIndividuAsal(String idIndividuAsal) async {
    final response = await _supabase
        .from('mutasi')
        .select()
        .eq('id_individu_asal', idIndividuAsal)
        .order('tanggal_mutasi', ascending: false);
    return response.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Mutasi>> getAllMutasi() async {
    final response = await _supabase
        .from('mutasi')
        .select()
        .order('tanggal_mutasi', ascending: false);
    return response.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<void> deleteMutasi(String id) async {
    await _supabase.from('mutasi').delete().eq('id', id);
  }

  Future<List<Mutasi>> getMutasiByKelompokDawis(String kelompokDawis) async {
    final mutasiList = await _supabase
        .from('mutasi')
        .select()
        .order('tanggal_mutasi', ascending: false);
    final bIds = mutasiList
        .map((m) => m['id_bangunan'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .toList();

    if (bIds.isEmpty) return [];

    final bangunanList = await _supabase
        .from('bangunan')
        .select('id, kelompok_dawis')
        .inFilter('id', bIds);
    final bMap = {
      for (var b in bangunanList)
        b['id']: b['kelompok_dawis']?.toString() ?? '',
    };

    final normalizedName = kelompokDawis
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    final filtered = mutasiList.where((m) {
      final bId = m['id_bangunan'] as String?;
      final dbName = bMap[bId] ?? '';
      final normalizedDbName = dbName
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normalizedDbName == normalizedName;
    }).toList();

    return filtered.map((json) => MutasiModel.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getLampidReportData({
    String? kelompokDawis,
    String? bulan,
    String? tahun,
  }) async {
    List<dynamic> mutasiList;

    if (bulan != null && tahun != null) {
      final startDate = '$tahun-$bulan-01';
      final endDay = DateTime(int.parse(tahun), int.parse(bulan) + 1, 0).day;
      final endDate = '$tahun-$bulan-${endDay.toString().padLeft(2, '0')}';
      mutasiList = await _supabase
          .from('mutasi')
          .select()
          .gte('tanggal_mutasi', startDate)
          .lte('tanggal_mutasi', endDate)
          .order('tanggal_mutasi', ascending: true);
    } else {
      mutasiList = await _supabase
          .from('mutasi')
          .select()
          .order('tanggal_mutasi', ascending: true);
    }

    final bIds = mutasiList
        .map((m) => m['id_bangunan'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .toList();
    final iIds = mutasiList
        .map((m) => m['id_individu_asal'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .toList();

    List<dynamic> bangunanList = [];
    if (bIds.isNotEmpty) {
      bangunanList = await _supabase
          .from('bangunan')
          .select('id, nama_bangunan, alamat_lengkap, kelompok_dawis')
          .inFilter('id', bIds);
    }
    List<dynamic> individuList = [];
    if (iIds.isNotEmpty) {
      individuList = await _supabase
          .from('individu')
          .select('id, jenis_kelamin, tanggal_lahir')
          .inFilter('id', iIds);
    }

    final bMap = {for (var b in bangunanList) b['id']: b};
    final iMap = {for (var i in individuList) i['id']: i};

    List<Map<String, dynamic>> results = [];
    final normalizedDawis = kelompokDawis
        ?.replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();

    for (var m in mutasiList) {
      final bId = m['id_bangunan'] as String?;
      final iId = m['id_individu_asal'] as String?;

      final b = bMap[bId];
      final ind = iMap[iId];

      final bKelompokDawis = b?['kelompok_dawis']?.toString() ?? '';

      if (normalizedDawis != null &&
          normalizedDawis.isNotEmpty &&
          kelompokDawis != 'Semua Dawis') {
        final normDb = bKelompokDawis
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .toLowerCase();
        if (normDb != normalizedDawis) continue;
      }

      final map = Map<String, dynamic>.from(m);
      map['nama_bangunan'] = b?['nama_bangunan'];
      map['alamat_lengkap'] = b?['alamat_lengkap'];
      map['b_kelompok_dawis'] = bKelompokDawis;
      map['jenis_kelamin'] = ind?['jenis_kelamin'];
      map['tanggal_lahir'] = ind?['tanggal_lahir'];

      results.add(map);
    }

    return results;
  }
}
