import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawis/src/features/pendataan/domain/entities/individu.dart';
import 'package:dawis/src/features/pendataan/data/repositories/individu_repository.dart';

final individuRepositoryProvider = Provider((ref) => IndividuRepository());

final individuByKeluargaProvider =
    FutureProvider.family<List<Individu>, String>((ref, keluargaId) async {
      final repository = ref.read(individuRepositoryProvider);
      return repository.getIndividuByKeluargaId(keluargaId);
    });

final searchIndividuProvider = FutureProvider.family<List<Individu>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final repository = ref.read(individuRepositoryProvider);
  return repository.searchIndividu(query);
});

final individuByIdProvider = FutureProvider.family<Individu?, String>((
  ref,
  id,
) async {
  final repository = ref.read(individuRepositoryProvider);
  return repository.getIndividuById(id);
});
