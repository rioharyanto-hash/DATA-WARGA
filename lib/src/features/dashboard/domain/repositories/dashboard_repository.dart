import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary({
    String? rw,
    String? rt,
    String? kelompokDawis,
  });

  Future<Map<String, List<String>>> getFilterOptions({String? rw, String? rt});

  Future<List<Map<String, dynamic>>> getDemografiDetail({
    String? rw,
    String? rt,
    String? kelompokDawis,
    required String category,
  });
}
