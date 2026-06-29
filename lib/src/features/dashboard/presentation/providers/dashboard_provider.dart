import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

// Provider untuk Dependency Injection (Menggantikan GetIt)
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

// Provider untuk state management UI (memanggil data secara asynchronous)
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardSummary();
});
