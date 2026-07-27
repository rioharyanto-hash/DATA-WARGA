import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawis/src/features/pendataan/domain/entities/keluarga.dart';
import 'package:dawis/src/features/pendataan/data/repositories/keluarga_repository.dart';
import 'package:dawis/core/database/local_db_helper.dart';

import 'package:dawis/src/features/pendataan/presentation/providers/bangunan_provider.dart';

final keluargaRepositoryProvider = Provider((ref) => KeluargaRepository());

final keluargaByKrtProvider = FutureProvider.family<List<Keluarga>, String>((
  ref,
  krtId,
) async {
  final repository = ref.read(keluargaRepositoryProvider);
  return repository.getKeluargaByKrtId(krtId);
});

final keluargaByIdProvider = FutureProvider.family<Keluarga?, String>((
  ref,
  id,
) async {
  final repository = ref.read(keluargaRepositoryProvider);
  return repository.getKeluargaById(id);
});

final idBangunanByKeluargaProvider = FutureProvider.family<String?, String>((
  ref,
  keluargaId,
) async {
  try {
    final db = await LocalDbHelper.database;
    final keluargaMaps = await db.query(
      'keluarga',
      where: 'id = ?',
      whereArgs: [keluargaId],
      limit: 1,
    );
    if (keluargaMaps.isNotEmpty) {
      final idKrt = keluargaMaps.first['id_krt'] as String;
      final krtMaps = await db.query(
        'krt',
        where: 'id = ?',
        whereArgs: [idKrt],
        limit: 1,
      );
      if (krtMaps.isNotEmpty) {
        final idBangunan = krtMaps.first['id_bangunan']?.toString();
        if (idBangunan != null && idBangunan.isNotEmpty) {
          return idBangunan;
        }
      }
    }
  } catch (_) {}

  try {
    final res = await Supabase.instance.client
        .from('keluarga')
        .select('id_krt, krt(id_bangunan)')
        .eq('id', keluargaId)
        .maybeSingle();
    if (res != null && res['krt'] != null) {
      final idBangunan = res['krt']['id_bangunan']?.toString();
      if (idBangunan != null && idBangunan.isNotEmpty) {
        return idBangunan;
      }
    }
  } catch (_) {}

  return null;
});

final searchKeluargaProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      query,
    ) async {
      final repository = ref.read(keluargaRepositoryProvider);
      final filter = ref.watch(selectedKelompokDawisFilterProvider);
      return repository.searchKeluargaWithKrtName(query, kelompokDawis: filter);
    });
