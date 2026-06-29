import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mutasi.dart';
import '../../data/repositories/mutasi_repository.dart';

final mutasiRepositoryProvider = Provider<MutasiRepository>((ref) {
  return MutasiRepository();
});

final mutasiByBangunanProvider = FutureProvider.family<List<Mutasi>, String>((
  ref,
  idBangunan,
) async {
  final repo = ref.watch(mutasiRepositoryProvider);
  return await repo.getMutasiByBangunan(idBangunan);
});

final mutasiByIndividuProvider = FutureProvider.family<List<Mutasi>, String>((
  ref,
  idIndividuAsal,
) async {
  final repo = ref.watch(mutasiRepositoryProvider);
  return await repo.getMutasiByIndividuAsal(idIndividuAsal);
});

final allMutasiProvider = FutureProvider<List<Mutasi>>((ref) async {
  final repo = ref.watch(mutasiRepositoryProvider);
  return await repo.getAllMutasi();
});
