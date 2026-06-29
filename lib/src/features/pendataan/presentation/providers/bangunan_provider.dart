import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawis/src/features/pendataan/domain/entities/bangunan.dart';
import 'package:dawis/src/features/pendataan/data/repositories/bangunan_repository.dart';
import 'package:dawis/src/features/settings/presentation/providers/app_user_provider.dart';

final bangunanRepositoryProvider = Provider((ref) => BangunanRepository());

final daftarBangunanProvider = FutureProvider<List<Bangunan>>((ref) async {
  final repository = ref.read(bangunanRepositoryProvider);
  final user = ref.watch(loggedInUserProvider);

  if (user == null) {
    return [];
  }

  switch (user.role) {
    case 'ADMIN':
      return repository.getAllBangunan();
    case 'RW':
      if (user.rw != null) {
        return repository.getBangunanByRw(user.rw!);
      }
      return [];
    case 'RT':
      if (user.rt != null && user.rw != null) {
        return repository.getBangunanByRtRw(user.rt!, user.rw!);
      }
      return [];
    case 'KADER':
    default:
      if (user.kelompokDawis != null) {
        return repository.getBangunanByKelompokDawis(user.kelompokDawis!);
      }
      return [];
  }
});

class SelectedKelompokDawisFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? value) {
    state = value;
  }
}

final selectedKelompokDawisFilterProvider =
    NotifierProvider<SelectedKelompokDawisFilter, String?>(
      SelectedKelompokDawisFilter.new,
    );

final filteredDaftarBangunanProvider = Provider<AsyncValue<List<Bangunan>>>((
  ref,
) {
  final asyncList = ref.watch(daftarBangunanProvider);
  final filter = ref.watch(selectedKelompokDawisFilterProvider);

  return asyncList.whenData((list) {
    if (filter == null || filter.isEmpty || filter == 'Semua') {
      return list;
    }
    final normalizedFilter = filter
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .toLowerCase();
    return list.where((b) {
      final normalizedName = b.kelompokDawis
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .toLowerCase();
      return normalizedName == normalizedFilter;
    }).toList();
  });
});

final uniqueKelompokDawisProvider = Provider<AsyncValue<List<String>>>((ref) {
  final asyncList = ref.watch(daftarBangunanProvider);
  return asyncList.whenData((list) {
    final set = <String>{};
    for (var b in list) {
      if (b.kelompokDawis.isNotEmpty) {
        set.add(b.kelompokDawis);
      }
    }
    final result = set.toList()..sort();
    result.insert(0, 'Semua');
    return result;
  });
});

final bangunanByIdProvider = FutureProvider.family<Bangunan?, String>((
  ref,
  id,
) async {
  final repository = ref.read(bangunanRepositoryProvider);
  return repository.getBangunanById(id);
});
