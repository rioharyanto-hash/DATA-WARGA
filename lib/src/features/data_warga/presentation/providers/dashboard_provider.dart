import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

final dashboardAgregatProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return {};
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDemografiAgregat(user);
});

final detailBansosProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailPenerimaBansos(user);
});

final detailYatimProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailYatimPiatu(user);
});

final detailDisabilitasProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailDisabilitas(user);
});

final detailKkProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailKk(user);
});

final detailWargaProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(user);
});

final detailLakiProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(user, jenisKelamin: 'Laki-Laki');
});

final detailPerempuanProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(user, jenisKelamin: 'Perempuan');
});
