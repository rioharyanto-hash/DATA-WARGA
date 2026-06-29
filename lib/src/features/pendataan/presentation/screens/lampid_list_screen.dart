import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mutasi.dart';
import '../providers/mutasi_provider.dart';
import '../providers/bangunan_provider.dart';

class LampidListScreen extends ConsumerWidget {
  const LampidListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutasiAsync = ref.watch(allMutasiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data LAMPID (Mutasi)',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: mutasiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Gagal memuat data LAMPID: $err')),
        data: (mutasiList) {
          if (mutasiList.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat mutasi (LAMPID).',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mutasiList.length,
            itemBuilder: (context, index) {
              return _LampidListItem(mutasi: mutasiList[index]);
            },
          );
        },
      ),
    );
  }
}

class _LampidListItem extends ConsumerWidget {
  final Mutasi mutasi;

  const _LampidListItem({required this.mutasi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangunanAsync = ref.watch(bangunanByIdProvider(mutasi.idBangunan));
    final isKeluar =
        mutasi.jenisMutasi == 'Meninggal' || mutasi.jenisMutasi == 'Pindah';

    final iconColor = isKeluar ? Colors.red : Colors.green;
    final icon = isKeluar
        ? (mutasi.jenisMutasi == 'Meninggal'
              ? Icons.heart_broken
              : Icons.logout)
        : (mutasi.jenisMutasi == 'Lahir' ? Icons.child_friendly : Icons.login);

    String dateStr = mutasi.tanggalMutasi;
    try {
      final date = DateTime.parse(mutasi.tanggalMutasi);
      dateStr = DateFormat('dd MMM yyyy').format(date);
    } catch (_) {}

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon, color: iconColor)),
        title: Text(
          mutasi.namaOrang,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mutasi.jenisMutasi,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tgl Kejadian: $dateStr',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            bangunanAsync.when(
              data: (bangunan) {
                if (bangunan != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bangunan: ${bangunan.namaBangunan}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Alamat: ${bangunan.alamatLengkap}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 6),
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (mutasi.keterangan != null && mutasi.keterangan!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Keterangan: ${mutasi.keterangan}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
          ],
        ),
        onTap: () {
          // Bisa navigasi ke detail mutasi jika diperlukan
        },
      ),
    );
  }
}
