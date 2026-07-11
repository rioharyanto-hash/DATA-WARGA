import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mutasi.dart';
import '../providers/mutasi_provider.dart';
import '../providers/bangunan_provider.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

class LampidListScreen extends ConsumerStatefulWidget {
  const LampidListScreen({super.key});

  @override
  ConsumerState<LampidListScreen> createState() => _LampidListScreenState();
}

class _LampidListScreenState extends ConsumerState<LampidListScreen> {
  String? _selectedKelompokDawis;

  @override
  Widget build(BuildContext context) {
    final mutasiAsync = ref.watch(
      mutasiFilteredProvider(_selectedKelompokDawis),
    );
    final currentUser = ref.watch(loggedInUserProvider);
    final isAdmin = currentUser?.role == 'ADMIN';
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data LAMPID (Mutasi)',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          if (isAdmin)
            allUsersAsync.when(
              data: (users) {
                final kaderList = users
                    .where((u) => u.role == 'KADER')
                    .toList();
                if (kaderList.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: _selectedKelompokDawis,
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          color: Colors.white,
                        ),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return [null, ...kaderList].map((k) {
                            return Center(
                              child: Text(
                                k == null
                                    ? 'Semua Kader'
                                    : 'Dawis: ${k.kelompokDawis ?? "-"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Semua Kader'),
                          ),
                          ...kaderList.map((k) {
                            return DropdownMenuItem<String>(
                              value: k.kelompokDawis,
                              child: Text('Dawis: ${k.kelompokDawis ?? "-"}'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedKelompokDawis = val;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mutasiAsync.when(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mutasiList.length,
                  itemBuilder: (context, index) {
                    return _LampidListItem(mutasi: mutasiList[index]);
                  },
                );
              },
            ),
          ),
        ],
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
        onTap: () => _showDetailDialog(context, bangunanAsync.valueOrNull),
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
