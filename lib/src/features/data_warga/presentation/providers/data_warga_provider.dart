import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/data_warga_bangunan.dart';
import '../../domain/entities/data_warga_keluarga.dart';
import '../../domain/repositories/data_warga_repository.dart';
import '../../data/repositories/data_warga_repository_impl.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

final dataWargaRepositoryProvider = Provider<DataWargaRepository>((ref) {
  return DataWargaRepositoryImpl();
});

class DataWargaSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final dataWargaSearchQueryProvider = NotifierProvider<DataWargaSearchQuery, String>(
  DataWargaSearchQuery.new,
);

class DataWargaRtFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? rt) {
    state = rt;
  }
}

final dataWargaRtFilterProvider = NotifierProvider<DataWargaRtFilter, String?>(
  DataWargaRtFilter.new,
);

class SelectedBangunanId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedBangunanIdProvider = NotifierProvider<SelectedBangunanId, String?>(
  SelectedBangunanId.new,
);

final dataWargaRtListProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(dataWargaRepositoryProvider);
  final user = ref.watch(loggedInUserProvider);

  if (user == null) return [];

  return repository.getRtList(user);
});

final dataWargaBangunanListProvider = FutureProvider<List<DataWargaBangunan>>((ref) async {
  final repository = ref.watch(dataWargaRepositoryProvider);
  final user = ref.watch(loggedInUserProvider);
  final searchQuery = ref.watch(dataWargaSearchQueryProvider);
  final rtFilter = ref.watch(dataWargaRtFilterProvider);

  if (user == null) return [];

  return repository.getBangunanList(user, searchQuery: searchQuery, rtFilter: rtFilter);
});

final dataWargaSelectedBangunanProvider = Provider<DataWargaBangunan?>((ref) {
  final listAsync = ref.watch(dataWargaBangunanListProvider);
  final selectedId = ref.watch(selectedBangunanIdProvider);
  
  if (selectedId == null) return null;
  
  return listAsync.maybeWhen(
    data: (list) {
      try {
        return list.firstWhere((b) => b.id == selectedId);
      } catch (e) {
        return null;
      }
    },
    orElse: () => null,
  );
});

final dataWargaKeluargaListProvider = FutureProvider<List<DataWargaKeluarga>>((ref) async {
  final repository = ref.watch(dataWargaRepositoryProvider);
  final selectedId = ref.watch(selectedBangunanIdProvider);

  if (selectedId == null) return [];

  return repository.getKeluargaList(selectedId);
});
