import 'package:flutter_riverpod/flutter_riverpod.dart';
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
final dashboardRwFilterProvider = NotifierProvider<DashboardRwFilter, String?>(DashboardRwFilter.new);

class DashboardRtFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? val) => state = val;
}
final dashboardRtFilterProvider = NotifierProvider<DashboardRtFilter, String?>(DashboardRtFilter.new);

class DashboardKaderFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? val) => state = val;
}
final dashboardKaderFilterProvider = NotifierProvider<DashboardKaderFilter, String?>(DashboardKaderFilter.new);

// Provider untuk mengambil opsi filter (RW, RT, Kader)
final dashboardFilterOptionsProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getFilterOptions();
});

// Provider untuk state management UI (memanggil data secara asynchronous)
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  
  final rw = ref.watch(dashboardRwFilterProvider);
  final rt = ref.watch(dashboardRtFilterProvider);
  final kader = ref.watch(dashboardKaderFilterProvider);
  
  return await repository.getDashboardSummary(
    rw: rw,
    rt: rt,
    kelompokDawis: kader,
  );
});
