import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

// Provider untuk Dependency Injection (Menggantikan GetIt)
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

// State providers for filters
class DashboardRwFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? val) => state = val;
}

final dashboardRwFilterProvider = NotifierProvider<DashboardRwFilter, String?>(
  DashboardRwFilter.new,
);

class DashboardRtFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? val) => state = val;
}

final dashboardRtFilterProvider = NotifierProvider<DashboardRtFilter, String?>(
  DashboardRtFilter.new,
);

class DashboardKaderFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? val) => state = val;
}

final dashboardKaderFilterProvider =
    NotifierProvider<DashboardKaderFilter, String?>(DashboardKaderFilter.new);

// Provider untuk mengambil opsi filter (RW, RT, Kader)
final dashboardFilterOptionsProvider =
    FutureProvider<Map<String, List<String>>>((ref) async {
      final repository = ref.watch(dashboardRepositoryProvider);
      final user = ref.watch(loggedInUserProvider);

      String? rw = ref.watch(dashboardRwFilterProvider);
      String? rt = ref.watch(dashboardRtFilterProvider);

      if (user?.role == 'RW') {
        rw = user?.rw;
      } else if (user?.role == 'RT') {
        rw = user?.rw;
        rt = user?.rt;
      } else if (user?.role == 'KADER') {
        rw = user?.rw;
        rt = user?.rt;
      }

      return await repository.getFilterOptions(rw: rw, rt: rt);
    });

// Provider untuk state management UI (memanggil data secara asynchronous)
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(loggedInUserProvider);

  String? rw = ref.watch(dashboardRwFilterProvider);
  String? rt = ref.watch(dashboardRtFilterProvider);
  String? kader = ref.watch(dashboardKaderFilterProvider);

  if (user?.role == 'RW') {
    rw = user?.rw;
  } else if (user?.role == 'RT') {
    rw = user?.rw;
    rt = user?.rt;
  } else if (user?.role == 'KADER') {
    rw = user?.rw;
    rt = user?.rt;
    kader = user?.kelompokDawis;
  }

  return await repository.getDashboardSummary(
    rw: rw,
    rt: rt,
    kelompokDawis: kader,
  );
});

final dashboardDemografiDetailProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      category,
    ) async {
      final repository = ref.watch(dashboardRepositoryProvider);
      final user = ref.watch(loggedInUserProvider);

      String? rw = ref.watch(dashboardRwFilterProvider);
      String? rt = ref.watch(dashboardRtFilterProvider);
      String? kader = ref.watch(dashboardKaderFilterProvider);

      if (user?.role == 'RW') {
        rw = user?.rw;
      } else if (user?.role == 'RT') {
        rw = user?.rw;
        rt = user?.rt;
      } else if (user?.role == 'KADER') {
        rw = user?.rw;
        rt = user?.rt;
        kader = user?.kelompokDawis;
      }

      return await repository.getDemografiDetail(
        rw: rw,
        rt: rt,
        kelompokDawis: kader,
        category: category,
      );
    });
