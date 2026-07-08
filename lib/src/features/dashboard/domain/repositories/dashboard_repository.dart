import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary({
    String? rw,
    String? rt,
    String? kelompokDawis,
  });

  Future<Map<String, List<String>>> getFilterOptions();
}
