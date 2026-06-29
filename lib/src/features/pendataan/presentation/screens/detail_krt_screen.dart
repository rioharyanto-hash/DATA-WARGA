import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/keluarga_provider.dart';
import '../providers/krt_provider.dart';

class DetailKrtScreen extends ConsumerWidget {
  final String krtId;

  const DetailKrtScreen({super.key, required this.krtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keluargaList = ref.watch(keluargaByKrtProvider(krtId));
    final krtData = ref.watch(krtByIdProvider(krtId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail KRT')),
      body: Column(
        children: [
          // ── Info KRT ──
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 40, color: Colors.blueGrey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kepala Rumah Tangga',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        krtData.when(
                          loading: () => const Text('Memuat...'),
                          error: (err, stack) => const Text('Error'),
                          data: (krt) {
                            final namaKrt =
                                krt?.namaKrt ?? 'Data tidak ditemukan';
                            final nikKrt = krt?.nikKrt ?? '-';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaKrt,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIK: $nikKrt',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Header Daftar Keluarga ──
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Daftar Keluarga (KK)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: keluargaList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Gagal memuat data keluarga: $error')),
              data: (keluargaItems) {
                if (keluargaItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data keluarga.\nTekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: keluargaItems.length,
                  itemBuilder: (context, index) {
                    final keluarga = keluargaItems[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.family_restroom),
                        ),
                        title: Text(
                          'No. KK: ${keluarga.noKk}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Status: ${keluarga.statusVisitasi}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF6366F1),
                              ),
                              onPressed: () => context.push(
                                '/form-keluarga-edit/${keluarga.id}',
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () =>
                            context.push('/detail-keluarga/${keluarga.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/form-keluarga/$krtId'),
        tooltip: 'Tambah Keluarga',
        child: const Icon(Icons.add),
      ),
    );
  }
}
