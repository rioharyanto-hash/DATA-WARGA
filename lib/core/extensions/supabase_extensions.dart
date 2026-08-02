import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseExtensions on SupabaseClient {
  Future<List<Map<String, dynamic>>> fetchAll(
    String table, {
    String? columns,
    String? orderBy,
    bool ascending = true,
  }) async {
    List<Map<String, dynamic>> allData = [];
    int offset = 0;
    const int limit = 1000;

    while (true) {
      PostgrestTransformBuilder<PostgrestList> query = from(
        table,
      ).select(columns ?? '*');
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      final res = await query.range(offset, offset + limit - 1);
      allData.addAll(List<Map<String, dynamic>>.from(res));
      if (res.length < limit) break;
      offset += limit;
    }
    return allData;
  }
}
