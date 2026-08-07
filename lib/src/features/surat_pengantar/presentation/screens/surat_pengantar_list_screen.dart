import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/presentation/widgets/shared_app_bar_title.dart';
import '../../domain/entities/surat_pengantar.dart';
import '../../data/repositories/surat_pengantar_repository.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

class SelectedRtNotifier extends Notifier<String> {
  @override
  String build() => 'Semua RT';

  void updateRt(String newRt) => state = newRt;
}

final selectedRtProvider = NotifierProvider<SelectedRtNotifier, String>(
  SelectedRtNotifier.new,
);

final suratPengantarListProvider =
    FutureProvider.autoDispose<List<SuratPengantar>>((ref) async {
      final user = ref.watch(loggedInUserProvider);
      if (user == null) return [];

      final repo = ref.watch(suratPengantarRepositoryProvider);

      if (user.role == 'RW' || user.role == 'ADMIN') {
        final selectedRt = ref.watch(selectedRtProvider);
        return repo.getSuratPengantarList(rt: selectedRt, rw: user.rw);
      } else if (user.role == 'RT') {
        return repo.getSuratPengantarList(rt: user.rt, rw: user.rw);
      } else {
        return repo.getSuratPengantarList();
      }
    });

class SuratPengantarListScreen extends ConsumerWidget {
  const SuratPengantarListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(suratPengantarListProvider);
    final user = ref.watch(loggedInUserProvider);
    final isRW = user?.role == 'RW';
    final isAdmin = user?.role == 'ADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const SharedAppBarTitle(
          title: 'Surat Pengantar',
          subtitle: 'Rekapitulasi Surat Pengantar RT',
        ),
        backgroundColor: const Color(0xFF4338CA), // Indigo 700
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (isRW || isAdmin)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Filter RT:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final selectedRt = ref.watch(selectedRtProvider);
                        final rts = [
                          'Semua RT',
                          '001',
                          '002',
                          '003',
                          '004',
                          '005',
                          '006',
                          '007',
                          '008',
                          '009',
                          '010',
                        ];
                        return DropdownButton<String>(
                          value: selectedRt,
                          isExpanded: true,
                          items: rts.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              ref
                                  .read(selectedRtProvider.notifier)
                                  .updateRt(newValue);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: listAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data surat pengantar.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEEF2FF), // Indigo 50
                          child: Icon(
                            Icons.mark_email_read,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                        title: Text(
                          item.namaPemohon,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('NIK: ${item.nik}'),
                            Text('Alamat: ${item.alamat}'),
                            Text('No: ${item.noSurat}'),
                            Text('Tgl: ${item.tanggalSurat}'),
                            Text('Keperluan: ${item.keperluan}'),
                            if (item.rt != null)
                              Text('RT: ${item.rt} / RW: ${item.rw ?? '-'}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: (isRW || isAdmin)
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Surat'),
                                      content: const Text(
                                        'Yakin ingin menghapus rekap surat ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await ref
                                          .read(
                                            suratPengantarRepositoryProvider,
                                          )
                                          .deleteSuratPengantar(item.id);
                                      ref.invalidate(
                                        suratPengantarListProvider,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Surat berhasil dihapus',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Gagal menghapus: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Terjadi kesalahan: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: (isRW || isAdmin)
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF4338CA),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Buat Surat',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await context.push('/form-surat-pengantar');
                ref.invalidate(suratPengantarListProvider);
              },
            ),
    );
  }
}
