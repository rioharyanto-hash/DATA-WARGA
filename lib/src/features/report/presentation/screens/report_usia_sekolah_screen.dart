import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/report_provider.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import '../../../laporan/services/excel_report_service.dart';
import '../../data/services/pdf_report_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:go_router/go_router.dart';
import '../../../../../core/database/local_db_helper.dart';

class ReportUsiaSekolahScreen extends ConsumerStatefulWidget {
  const ReportUsiaSekolahScreen({super.key});

  @override
  ConsumerState<ReportUsiaSekolahScreen> createState() =>
      _ReportUsiaSekolahScreenState();
}

class _ReportUsiaSekolahScreenState
    extends ConsumerState<ReportUsiaSekolahScreen> {
  String? _selectedKelompok;
  bool _isExporting = false;

  Future<void> _exportToExcel(List<Map<String, dynamic>> data) async {
    setState(() => _isExporting = true);
    try {
      final excelService = ExcelReportService();
      final bulan = ref.read(reportBulanProvider);

      final bytes = await excelService.generateUsiaSekolahExcel(
        data,
        _selectedKelompok ?? 'SEMUA',
        bulan,
      );

      if (kIsWeb) {
        final blob = html.Blob([
          bytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'Laporan_Usia_Sekolah_${_selectedKelompok ?? "Semua"}.xlsx',
          )
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/Laporan_Usia_Sekolah_${_selectedKelompok ?? "Semua"}.xlsx',
        );
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tersimpan di ${file.path}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export excel: $e')));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPdf(List<Map<String, dynamic>> data) async {
    setState(() => _isExporting = true);
    try {
      final pdfService = ref.read(pdfReportServiceProvider);
      final bulan = ref.read(reportBulanProvider);

      final bytes = await pdfService.generateUsiaSekolahPdf(
        data: data,
        kelompok: _selectedKelompok ?? 'SEMUA',
        bulan: bulan,
      );

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'Laporan_Usia_Sekolah_${_selectedKelompok ?? "Semua"}.pdf',
          )
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/Laporan_Usia_Sekolah_${_selectedKelompok ?? "Semua"}.pdf',
        );
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tersimpan di ${file.path}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export pdf: $e')));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Map<String, dynamic> item,
    WidgetRef ref,
  ) async {
    final isSekolah =
        item['pendidikan_terakhir'] != 'Tidak/Belum Sekolah' &&
        item['pendidikan_terakhir'] != null &&
        item['pendidikan_terakhir'] != '-';

    final title = isSekolah ? 'Nama Sekolah' : 'Alasan Belum Sekolah';
    final currentVal = item['alasan_belum_sekolah']?.toString() == '-'
        ? ''
        : item['alasan_belum_sekolah']?.toString() ?? '';
    final controller = TextEditingController(text: currentVal);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await LocalDbHelper.database;
              await db.update(
                'individu',
                {'alasan_belum_sekolah': controller.text},
                where: 'id = ?',
                whereArgs: [item['individu_id']],
              );
              ref.invalidate(usiaSekolahReportProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil diupdate')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);
    final kelompokDawisAsync = ref.watch(kelompokDawisListProvider);
    final bulanStr = ref.watch(reportBulanProvider);

    final bulanField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periode Laporan (Bulan)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(bulanStr),
          initialValue: bulanStr,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              const [
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
                  ]
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.toUpperCase()),
                    ),
                  )
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(reportBulanProvider.notifier).update(val);
            }
          },
        ),
      ],
    );

    final kelompokDropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kelompok Dasawisma (Kader)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        kelompokDawisAsync.when(
          data: (listData) {
            final list = List<Map<String, String>>.from(listData);

            if (list.isEmpty) {
              return const Text(
                'Belum ada data Kelompok Dasawisma.',
                style: TextStyle(color: Colors.red),
              );
            }

            final isAdmin = user?.role == 'ADMIN';
            final dropdownItems = <DropdownMenuItem<String>>[];

            if (isAdmin) {
              dropdownItems.add(
                const DropdownMenuItem(
                  value: 'SEMUA',
                  child: Text(
                    'SEMUA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            for (final map in list) {
              final name = map['kelompok_dawis']!;
              final rt = (map['rt'] ?? '').padLeft(3, '0');
              final rw = (map['rw'] ?? '').padLeft(3, '0');
              dropdownItems.add(
                DropdownMenuItem(
                  value: name,
                  child: Text('$name (RT $rt / RW $rw)'),
                ),
              );
            }

            if (_selectedKelompok == null) {
              _selectedKelompok = isAdmin
                  ? 'SEMUA'
                  : list.first['kelompok_dawis'];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
            }

            return DropdownButtonFormField<String>(
              key: ValueKey(_selectedKelompok),
              initialValue: _selectedKelompok,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: dropdownItems,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedKelompok = val;
                  });
                }
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Anak Usia Sekolah (5-6 Tahun)'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            Consumer(
              builder: (context, ref, child) {
                final reportAsync = ref.watch(
                  usiaSekolahReportProvider(_selectedKelompok ?? ''),
                );
                return reportAsync.maybeWhen(
                  data: (data) => Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        tooltip: 'Export ke PDF',
                        onPressed: data.isEmpty
                            ? null
                            : () => _exportToPdf(data),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.table_chart,
                          color: Colors.green,
                        ),
                        tooltip: 'Export ke Excel',
                        onPressed: data.isEmpty
                            ? null
                            : () => _exportToExcel(data),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox(),
                );
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: kelompokDropdown),
                    const SizedBox(width: 16),
                    Expanded(child: bulanField),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedKelompok == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final reportAsync = ref.watch(
      usiaSekolahReportProvider(_selectedKelompok ?? ''),
    );

    return reportAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(
            child: Text('Tidak ada data anak usia sekolah (5-6 tahun).'),
          );
        }

        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = data[index];

                    String usia = '';
                    if (item['tanggal_lahir'] != null) {
                      try {
                        final dob = DateTime.parse(item['tanggal_lahir']);
                        final reportMonth =
                            [
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
                            ].indexOf(ref.read(reportBulanProvider)) +
                            1;

                        final now = DateTime.now();
                        DateTime periodEnd = DateTime(
                          now.year,
                          reportMonth + 1,
                          0,
                        );

                        int ageYears = periodEnd.year - dob.year;
                        int ageMonths = periodEnd.month - dob.month;
                        if (periodEnd.day < dob.day) {
                          ageMonths--;
                        }
                        if (ageMonths < 0) {
                          ageYears--;
                          ageMonths += 12;
                        }
                        usia = '$ageYears Tahun, $ageMonths Bulan';
                      } catch (_) {
                        usia = '-';
                      }
                    }

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama_anak'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nik: ${item['nik_anak'] ?? '-'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Lihat Profil',
                                  onPressed: () {
                                    context.push(
                                      '/view-individu/${item['individu_id']}',
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        item['pendidikan_terakhir'] !=
                                                'Tidak/Belum Sekolah' &&
                                            item['pendidikan_terakhir'] !=
                                                null &&
                                            item['pendidikan_terakhir'] != '-'
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          item['pendidikan_terakhir'] !=
                                                  'Tidak/Belum Sekolah' &&
                                              item['pendidikan_terakhir'] !=
                                                  null &&
                                              item['pendidikan_terakhir'] != '-'
                                          ? Colors.green.shade200
                                          : Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    item['pendidikan_terakhir'] ??
                                        'Tidak/Belum Sekolah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          item['pendidikan_terakhir'] !=
                                                  'Tidak/Belum Sekolah' &&
                                              item['pendidikan_terakhir'] !=
                                                  null &&
                                              item['pendidikan_terakhir'] != '-'
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Orang Tua',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['nama_orang_tua'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Usia',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        usia,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kelompok Dawis',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['nama_kelompok'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nama Bangunan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['nama_bangunan'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alamat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['alamat'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showEditDialog(context, item, ref),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (item['pendidikan_terakhir'] ==
                                              'Tidak/Belum Sekolah' ||
                                          item['pendidikan_terakhir'] == null ||
                                          item['pendidikan_terakhir'] == '-')
                                      ? Colors.orange.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color:
                                          (item['pendidikan_terakhir'] ==
                                                  'Tidak/Belum Sekolah' ||
                                              item['pendidikan_terakhir'] ==
                                                  null ||
                                              item['pendidikan_terakhir'] ==
                                                  '-')
                                          ? Colors.orange.shade700
                                          : Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        (item['pendidikan_terakhir'] ==
                                                    'Tidak/Belum Sekolah' ||
                                                item['pendidikan_terakhir'] ==
                                                    null ||
                                                item['pendidikan_terakhir'] ==
                                                    '-')
                                            ? 'Alasan Belum Sekolah: ${item['alasan_belum_sekolah']?.toString().isNotEmpty == true && item['alasan_belum_sekolah'] != '-' ? item['alasan_belum_sekolah'] : 'Belum diisi (Klik untuk mengisi)'}'
                                            : 'Nama Sekolah: ${item['alasan_belum_sekolah']?.toString().isNotEmpty == true && item['alasan_belum_sekolah'] != '-' ? item['alasan_belum_sekolah'] : 'Belum diisi (Klik untuk mengisi)'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              (item['pendidikan_terakhir'] ==
                                                      'Tidak/Belum Sekolah' ||
                                                  item['pendidikan_terakhir'] ==
                                                      null ||
                                                  item['pendidikan_terakhir'] ==
                                                      '-')
                                              ? Colors.orange.shade800
                                              : Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
