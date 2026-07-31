import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import 'data_warga_provider.dart';

final dashboardAgregatProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return {};
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDemografiAgregat(user, rtFilter: rtFilter);
});

final detailBansosProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailPenerimaBansos(user, rtFilter: rtFilter);
});

final detailYatimProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailYatimPiatu(user, rtFilter: rtFilter);
});

final detailDisabilitasProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailDisabilitas(user, rtFilter: rtFilter);
});

final detailKkProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailKk(user, rtFilter: rtFilter);
});

final detailWargaProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(user, rtFilter: rtFilter);
});

final detailLakiProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(
    user,
    jenisKelamin: 'Laki-Laki',
    rtFilter: rtFilter,
  );
});

final detailPerempuanProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(loggedInUserProvider);
  if (user == null) return [];
  final rtFilter = ref.watch(dataWargaRtFilterProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return await repo.getDetailWarga(
    user,
    jenisKelamin: 'Perempuan',
    rtFilter: rtFilter,
  );
});
