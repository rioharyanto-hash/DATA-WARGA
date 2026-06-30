import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/report_provider.dart';
import 'report_preview_screen.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _namaKelompokController = TextEditingController(text: 'Mawar 1');
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  String? _selectedKelompok;
  bool _isRingkasan = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rtController.text = ref.read(reportRtProvider);
      _rwController.text = ref.read(reportRwProvider);
      _rtController.addListener(() {
        ref.read(reportRtProvider.notifier).update(_rtController.text);
      });
      _rwController.addListener(() {
        ref.read(reportRwProvider.notifier).update(_rwController.text);
      });
    });
  }

  @override
  void dispose() {
    _namaKelompokController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final kelompokDawisAsync = ref.watch(kelompokDawisListProvider);

    ref.listen<ReportState>(reportControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.successMessage != null &&
          previous?.successMessage != next.successMessage) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text(next.successMessage!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    final jenisLaporanField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<bool>(
          value: _isRingkasan,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(
                value: false,
                child: Text('1. Laporan Rincian (Per Kelompok Kader)')),
            DropdownMenuItem(
                value: true,
                child: Text('2. Laporan Ringkasan (Rekap Seluruh Kelompok)')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _isRingkasan = val;
              });
            }
          },
        ),
      ],
    );

    final kelompokDropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kelompok Dasawisma',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        kelompokDawisAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Text(
                'Belum ada data Kelompok Dasawisma.',
                style: TextStyle(color: Colors.red),
              );
            }
            final names = list.map((m) => m['kelompok_dawis']!).toList();
            if (_selectedKelompok != null &&
                !names.contains(_selectedKelompok)) {
              _selectedKelompok = null;
            }
            if (_selectedKelompok == null && list.isNotEmpty) {
              final first = list.first;
              _selectedKelompok = first['kelompok_dawis'];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _namaKelompokController.text = _selectedKelompok!;
                _rtController.text = first['rt'] ?? '01';
                _rwController.text = first['rw'] ?? '02';
              });
            }
            return DropdownButtonFormField<String>(
              initialValue: _selectedKelompok,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: list.map((map) {
                final name = map['kelompok_dawis']!;
                final rt = map['rt']!;
                final rw = map['rw']!;
                return DropdownMenuItem(
                  value: name,
                  child: Text(
                    '$name (RT $rt / RW $rw)',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                final selectedMap = list.firstWhere(
                  (m) => m['kelompok_dawis'] == val,
                );
                setState(() {
                  _selectedKelompok = val;
                  _namaKelompokController.text = val;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _rtController.text = selectedMap['rt'] ?? '01';
                  _rwController.text = selectedMap['rw'] ?? '02';
                });
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );

    String getFormattedTitle(String formName) {
      final kelompok = _namaKelompokController.text.trim();
      return kelompok.isNotEmpty ? '${formName}_$kelompok' : formName;
    }

    final rtField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RT', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _rtController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );

    final rwField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RW', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _rwController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );

    final bulan = ref.watch(reportBulanProvider);
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final bulanField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bulan Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: bulan,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: months.map((m) {
            return DropdownMenuItem(value: m, child: Text(m));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(reportBulanProvider.notifier).update(value);
            }
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan & Cetak PDF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Pratinjau dan cetak laporan Dasawisma',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (context.canPop())
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isDesktop
                  ? Column(
                      children: [
                        jenisLaporanField,
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isRingkasan) ...[
                              Expanded(flex: 3, child: kelompokDropdown),
                              const SizedBox(width: 16),
                            ],
                            Expanded(flex: 2, child: bulanField),
                            const SizedBox(width: 16),
                            Expanded(flex: 1, child: rtField),
                            const SizedBox(width: 16),
                            Expanded(flex: 1, child: rwField),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        jenisLaporanField,
                        const SizedBox(height: 16),
                        if (!_isRingkasan) ...[
                          kelompokDropdown,
                          const SizedBox(height: 16),
                        ],
                        bulanField,
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: rtField),
                            const SizedBox(width: 16),
                            Expanded(child: rwField),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aksi Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Action Cards
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                mainAxisExtent: 140,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              children: [
                _buildActionCard(
                  title: 'Cetak Form I & II (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Form I & II'),
                          generatePdf: () => ref
                              .read(reportControllerProvider.notifier)
                              .generateForm1And2Pdf(
                                _namaKelompokController.text,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Data Kuantitas (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Data Kuantitas'),
                          generatePdf: () => _isRingkasan
                              ? ref
                                    .read(reportControllerProvider.notifier)
                                    .generateForm3RingkasanPdf()
                              : ref
                                    .read(reportControllerProvider.notifier)
                                    .generateForm3Pdf(
                                      _namaKelompokController.text,
                                    ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Rekapitulasi (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Rekapitulasi'),
                          generatePdf: () => _isRingkasan
                              ? ref
                                    .read(reportControllerProvider.notifier)
                                    .generateRekapPkkRingkasanPdf()
                              : ref
                                    .read(reportControllerProvider.notifier)
                                    .generateRekapPkkPdf(
                                      _namaKelompokController.text,
                                    ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Profil Kependudukan (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Profil Kependudukan'),
                          generatePdf: () => _isRingkasan
                              ? ref
                                    .read(reportControllerProvider.notifier)
                                    .generateProfilPendudukRingkasanPdf()
                              : ref
                                    .read(reportControllerProvider.notifier)
                                    .generateProfilPendudukPdf(
                                      _namaKelompokController.text,
                                    ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Data Potensi Warga (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Data Potensi Warga'),
                          generatePdf: () => _isRingkasan
                              ? ref
                                    .read(reportControllerProvider.notifier)
                                    .generatePotensiWargaRingkasanPdf()
                              : ref
                                    .read(reportControllerProvider.notifier)
                                    .generatePotensiWargaPdf(
                                      _namaKelompokController.text,
                                    ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Form Ibu Hamil (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Form Ibu Hamil'),
                          generatePdf: () => _isRingkasan
                              ? ref
                                    .read(reportControllerProvider.notifier)
                                    .generateLampidRingkasanPdf()
                              : ref
                                    .read(reportControllerProvider.notifier)
                                    .generateLampidPdf(
                                      _namaKelompokController.text,
                                    ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Data Manual (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Data Manual'),
                          generatePdf: () => ref
                              .read(reportControllerProvider.notifier)
                              .generateFormDataManualPdf(
                                _namaKelompokController.text,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: 'Cetak Yatim Piatu (Terisi)',
                  icon: Icons.picture_as_pdf,
                  isLoading: state.isLoading,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                          title: getFormattedTitle('Data Yatim Piatu'),
                          generatePdf: () => ref
                              .read(reportControllerProvider.notifier)
                              .generateYatimPiatuPdf(
                                _namaKelompokController.text,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Unduh Form Kosong (Template Blanko)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Blank Template Cards
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 1,
                mainAxisExtent: 70,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              children: [
                _buildTemplateCard(
                  'Cetak Form I',
                  'Penetapan Sasaran',
                  Icons.insert_drive_file_outlined,
                  'form1',
                ),
                _buildTemplateCard(
                  'Cetak Form II',
                  'Kelompok Dasawisma',
                  Icons.insert_drive_file_outlined,
                  'form2',
                ),
                _buildTemplateCard(
                  'Cetak Data Kuantitas',
                  'Data Kuantitas',
                  Icons.insert_drive_file_outlined,
                  'form3',
                ),
                _buildTemplateCard(
                  'Cetak Rekapitulasi',
                  'Catatan Data Warga',
                  Icons.storage_outlined,
                  'rekap_pkk',
                ),
                _buildTemplateCard(
                  'Cetak Profil Kependudukan',
                  'Umur & Jenis Kelamin',
                  Icons.people_outline,
                  'profil_penduduk',
                ),
                _buildTemplateCard(
                  'Cetak Data Potensi Warga',
                  'Kelompok PKK RW',
                  Icons.group_outlined,
                  'potensi_warga',
                ),
                _buildTemplateCard(
                  'Cetak Form Ibu Hamil',
                  'Kelahiran & Kematian',
                  Icons.pregnant_woman,
                  'ibu_hamil',
                ),
                _buildTemplateCard(
                  'Cetak Data Manual',
                  'Target Sasaran Pendataan',
                  Icons.assignment_outlined,
                  'data_manual',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
            isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.download,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Lihat',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    String title,
    String subtitle,
    IconData icon,
    String formType,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportPreviewScreen(
              title: title.replaceAll('Cetak ', 'BLANKO_'),
              generatePdf: () => ref
                  .read(reportControllerProvider.notifier)
                  .generateBlankPdf(formType),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '($subtitle)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
