import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/individu_provider.dart';
import '../providers/keluarga_provider.dart';

class DetailKeluargaScreen extends ConsumerWidget {
  final String keluargaId;
  final String mode;

  const DetailKeluargaScreen({
    super.key,
    required this.keluargaId,
    this.mode = 'master',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuList = ref.watch(individuByKeluargaProvider(keluargaId));
    final keluargaData = ref.watch(keluargaByIdProvider(keluargaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Keluarga')),
      body: Column(
        children: [
          // ── Info Keluarga ──
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.family_restroom,
                    size: 40,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kartu Keluarga',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        keluargaData.when(
                          loading: () => const Text('Memuat...'),
                          error: (err, stack) => const Text('Error'),
                          data: (keluarga) {
                            final noKk =
                                keluarga?.noKk ?? 'Data tidak ditemukan';
                            return Text(
                              'NO. KK: $noKk',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

          // ── Header Daftar Individu ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Daftar Anggota Keluarga',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Daftar Individu ──
          Expanded(
            child: individuList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Gagal memuat data individu: $error')),
              data: (individuItems) {
                if (individuItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data anggota keluarga.\nTekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: individuItems.length,
                  itemBuilder: (context, index) {
                    final individu = individuItems[index];

                    // Hitung Usia
                    String ageText = '-';
                    if (individu.tanggalLahir.isNotEmpty) {
                      try {
                        final tglLahir = DateTime.parse(individu.tanggalLahir);
                        final today = DateTime.now();
                        int age = today.year - tglLahir.year;
                        if (today.month < tglLahir.month ||
                            (today.month == tglLahir.month &&
                                today.day < tglLahir.day)) {
                          age--;
                        }
                        ageText = '$age Tahun';
                      } catch (e) {
                        ageText = '-';
                      }
                    }

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            individu.jenisKelamin == 'Laki-laki'
                                ? Icons.person
                                : Icons.person_2,
                          ),
                        ),
                        title: Text(
                          individu.namaLengkap,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NIK: ${individu.nik}'),
                              if (individu.noTlp != null &&
                                  individu.noTlp!.isNotEmpty)
                                Text('No. Tlp: ${individu.noTlp}'),
                              Text('Status: ${individu.hubunganKeluarga}'),
                              const SizedBox(height: 4),
                              Text(
                                'TTL: ${individu.tempatLahir}, ${individu.tanggalLahir}',
                              ),
                              Text('Kelamin: ${individu.jenisKelamin}'),
                              Text('Usia: $ageText'),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                        trailing: mode == 'master'
                            ? const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              )
                            : Icon(
                                mode == 'catatan'
                                    ? Icons.edit_document
                                    : (mode == 'potensi'
                                          ? Icons.analytics_rounded
                                          : Icons.pregnant_woman_rounded),
                                color: const Color(0xFF4338CA),
                              ),
                        onTap: () async {
                          if (mode == 'master') {
                            context.push('/view-individu/${individu.id}');
                          } else if (mode == 'catatan') {
                            context
                                .push('/form-catatan-keluarga/${individu.id}')
                                .then((_) {
                                  ref.invalidate(
                                    individuByKeluargaProvider(keluargaId),
                                  );
                                });
                          } else if (mode == 'potensi') {
                            context
                                .push('/form-potensi-warga/${individu.id}')
                                .then((_) {
                                  ref.invalidate(
                                    individuByKeluargaProvider(keluargaId),
                                  );
                                });
                          } else if (mode == 'mutasi') {
                            final idBangunan = await ref.read(
                              idBangunanByKeluargaProvider(keluargaId).future,
                            );
                            if (idBangunan != null && context.mounted) {
                              context
                                  .push(
                                    Uri(
                                      path: '/form-mutasi/$idBangunan',
                                      queryParameters: {
                                        'idIndividuAsal': individu.id,
                                        'defaultNama': individu.namaLengkap,
                                        'defaultNik': individu.nik,
                                      },
                                    ).toString(),
                                  )
                                  .then((_) {
                                    ref.invalidate(
                                      individuByKeluargaProvider(keluargaId),
                                    );
                                  });
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal menemukan data Bangunan.',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
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
        onPressed: () => context.push('/form-individu/$keluargaId'),
        tooltip: 'Tambah Anggota',
        child: const Icon(Icons.add),
      ),
    );
  }
}
