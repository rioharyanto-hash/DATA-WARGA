import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bangunan_provider.dart';
import '../providers/krt_provider.dart';
import '../providers/mutasi_provider.dart';
import '../../domain/entities/bangunan.dart';

class DetailBangunanScreen extends ConsumerStatefulWidget {
  final String bangunanId;

  const DetailBangunanScreen({super.key, required this.bangunanId});

  @override
  ConsumerState<DetailBangunanScreen> createState() =>
      _DetailBangunanScreenState();
}

class _DetailBangunanScreenState extends ConsumerState<DetailBangunanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daftarBangunan = ref.watch(daftarBangunanProvider);
    final krtList = ref.watch(krtByBangunanProvider(widget.bangunanId));
    final mutasiList = ref.watch(mutasiByBangunanProvider(widget.bangunanId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendataan  >  Detail Bangunan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Detail Bangunan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: _buildActionBtn(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.indigo.shade50,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.indigo.shade900,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Profil'),
                Tab(text: 'Daftar KRT'),
                Tab(text: 'Riwayat Mutasi'),
              ],
            ),
          ),
          Expanded(
            child: daftarBangunan.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Gagal memuat data bangunan: $error')),
              data: (bangunanList) {
                final bangunan = bangunanList
                    .where((b) => b.id == widget.bangunanId)
                    .firstOrNull;

                if (bangunan == null) {
                  return const Center(
                    child: Text('Data bangunan tidak ditemukan.'),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Detail Bangunan
                    _buildTabDetailBangunan(context, bangunan),

                    // Tab 2: Daftar KRT
                    _buildTabKrt(context, krtList),

                    // Tab 3: Riwayat Mutasi
                    _buildTabMutasi(context, mutasiList),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionBtn() {
    if (_tabController.index == 0) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/form-bangunan/${widget.bangunanId}'),
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Ubah Data'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } else if (_tabController.index == 1) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/form-krt/${widget.bangunanId}'),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Tambah KRT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } else if (_tabController.index == 2) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/form-mutasi/${widget.bangunanId}'),
        icon: const Icon(Icons.sync_alt, size: 16),
        label: const Text('Catat Mutasi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
    return null;
  }

  Widget _buildTabDetailBangunan(BuildContext context, Bangunan bangunan) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(bangunan),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildInformasiUmumCard(bangunan)),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildDataLingkunganCard(bangunan),
                      const SizedBox(height: 24),
                      _buildKriteriaRumahCard(bangunan),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInformasiUmumCard(bangunan),
                const SizedBox(height: 24),
                _buildDataLingkunganCard(bangunan),
                const SizedBox(height: 24),
                _buildKriteriaRumahCard(bangunan),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Bangunan bangunan) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KELOMPOK DAWIS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bangunan.kelompokDawis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALAMAT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bangunan.alamatLengkap,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'RT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        bangunan.rt,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      Text(
                        'RW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        bangunan.rw,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiUmumCard(Bangunan bangunan) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade900),
              const SizedBox(width: 8),
              const Text(
                'Informasi Umum',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Status Hunian', bangunan.statusHunian),
          _buildInfoRow('NOP PBB', bangunan.nopPbb ?? '-'),
          _buildInfoRow(
            'Status Kepemilikan',
            bangunan.statusKepemilikan ?? '-',
          ),
          _buildInfoRow('Kategori', _getKategori(bangunan.kategoriBangunan)),
          _buildInfoRow('Luas Bangunan', '${bangunan.luasBangunan ?? "-"} m²'),
          _buildInfoRow('Luas Tanah', '${bangunan.luasTanah ?? "-"} m²'),
          _buildInfoRow(
            'Sumber Air Minum',
            bangunan.sumberAirMinum ?? '-',
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDataLingkunganCard(Bangunan bangunan) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco_outlined, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                const Text(
                  'Data Lingkungan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Pemanfaatan Pekarangan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckmarkBox(
              'Rumah Sehat Layak Huni',
              bangunan.isSehatLayakHuni == 1,
            ),
            const SizedBox(height: 12),
            _buildCheckmarkBox(
              'Tidak Sehat Layak Huni',
              bangunan.isTidakSehatLayakHuni == 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckmarkBox(String title, bool isChecked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isChecked ? Colors.green.shade100 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isChecked ? Colors.black87 : Colors.grey.shade500,
              decoration: isChecked ? null : TextDecoration.lineThrough,
            ),
          ),
          Icon(
            isChecked ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isChecked ? Colors.green : Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildKriteriaRumahCard(Bangunan bangunan) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                const Text(
                  'Kriteria Rumah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildKriteriaRow(
              'Jamban',
              (bangunan.jumlahJambanKeluarga ?? 0) > 0,
            ),
            _buildKriteriaRow(
              'Tempat Sampah',
              (bangunan.jumlahTempatSampah ?? 0) > 0,
            ),
            _buildKriteriaRow('SPAL', (bangunan.jumlahSpal ?? 0) > 0),
            _buildKriteriaRow(
              'Stiker P4K',
              bangunan.hasStikerP4k == 1,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKriteriaRow(
    String label,
    bool isChecked, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Icon(
            isChecked ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isChecked ? Colors.green : Colors.red,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _getKategori(int? id) {
    switch (id) {
      case 1:
        return 'Rumah Tinggal';
      case 2:
        return 'Kontrakan';
      case 3:
        return 'Kos-kosan';
      case 4:
        return 'Asrama/Mess';
      case 5:
        return 'Rusun';
      case 6:
        return 'Tempat Usaha';
      case 7:
        return 'Kosong';
      case 8:
        return 'Bukan Rumah Tinggal';
      case 9:
        return 'Lainnya';
      default:
        return '-';
    }
  }

  Widget _buildTabKrt(BuildContext context, AsyncValue<List<dynamic>> krtList) {
    return krtList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Gagal memuat data KRT: $error')),
      data: (krtItems) {
        if (krtItems.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada data KRT.\nTekan tombol + untuk menambah.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: krtItems.length,
          itemBuilder: (context, index) {
            final krt = krtItems[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  krt.namaKrt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('NIK: ${krt.nikKrt}\nNo. KK: ${krt.noKkKrt}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6366F1)),
                      onPressed: () => context.push('/form-krt-edit/${krt.id}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Data'),
                            content: const Text(
                              'Anda yakin ingin menghapus data KRT ini? Seluruh data keluarga dan individu di dalamnya juga akan terhapus.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  context.pop();
                                  await ref
                                      .read(krtRepositoryProvider)
                                      .deleteKrt(krt.id);
                                  ref.invalidate(
                                    krtByBangunanProvider(widget.bangunanId),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Data KRT berhasil dihapus',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push('/detail-krt/${krt.id}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabMutasi(
    BuildContext context,
    AsyncValue<List<dynamic>> mutasiList,
  ) {
    return mutasiList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Gagal memuat data Mutasi: $error')),
      data: (mutasiItems) {
        if (mutasiItems.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada data mutasi.\nTekan tombol Catat Mutasi.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: mutasiItems.length,
          itemBuilder: (context, index) {
            final mutasi = mutasiItems[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      mutasi.jenisMutasi == 'Lahir' ||
                          mutasi.jenisMutasi == 'Datang'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    Icons.sync_alt,
                    color:
                        mutasi.jenisMutasi == 'Lahir' ||
                            mutasi.jenisMutasi == 'Datang'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  mutasi.namaOrang,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Jenis: ${mutasi.jenisMutasi}\nTanggal: ${mutasi.tanggalMutasi}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
