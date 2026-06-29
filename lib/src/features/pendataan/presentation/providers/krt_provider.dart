import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawis/src/features/pendataan/domain/entities/krt.dart';
import 'package:dawis/src/features/pendataan/data/repositories/krt_repository.dart';

final krtRepositoryProvider = Provider((ref) => KrtRepository());

final krtByBangunanProvider = FutureProvider.family<List<Krt>, String>((
  ref,
  bangunanId,
) async {
  final repository = ref.read(krtRepositoryProvider);
  return repository.getKrtByBangunanId(bangunanId);
});

final krtByIdProvider = FutureProvider.family<Krt?, String>((ref, id) async {
  final repository = ref.read(krtRepositoryProvider);
  return repository.getKrtById(id);
});
