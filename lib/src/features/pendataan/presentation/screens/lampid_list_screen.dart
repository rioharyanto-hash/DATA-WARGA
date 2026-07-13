import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mutasi.dart';
import '../providers/mutasi_provider.dart';
import '../providers/bangunan_provider.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../report/data/services/pdf_lampid_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class LampidListScreen extends ConsumerStatefulWidget {
  const LampidListScreen({super.key});

  @override
  ConsumerState<LampidListScreen> createState() => _LampidListScreenState();
}

class _LampidListScreenState extends ConsumerState<LampidListScreen> {
  String? _selectedKelompokDawis;

  Future<void> _showPrintDialog(BuildContext context) async {
    final allUsersAsync = ref.read(allUsersProvider);
    final kaderList = allUsersAsync.value?.where((u) => u.role == 'KADER').toList() ?? [];
    
    DateTime selectedDate = DateTime.now();
    String? selectedDawis = _selectedKelompokDawis;

    const List<String> monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (setStateContext, setState) {
            return AlertDialog(
              title: const Text('Export Laporan LAMPID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDawis,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Kelompok Kader'),
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
                    onChanged: (newValue) {
                      setState(() => selectedDawis = newValue);
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: setStateContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDatePickerMode: DatePickerMode.year,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Bulan & Tahun',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${monthNames[selectedDate.month - 1]} ${selectedDate.year}'),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sedang mengekspor PDF...')),
                    );

                    final bulanStr = selectedDate.month.toString().padLeft(2, '0');
                    final tahunStr = selectedDate.year.toString();

                    try {
                      final mutasiRepo = ref.read(mutasiRepositoryProvider);
                      final data = await mutasiRepo.getLampidReportData(
                        kelompokDawis: selectedDawis,
                        bulan: bulanStr,
                        tahun: tahunStr,
                      );
                      
                      final pdfService = PdfLampidService();
                      final bytes = await pdfService.generateLampidPdf(
                        kelompokDawis: selectedDawis,
                        bulan: bulanStr,
                        tahun: tahunStr,
                        data: data,
                      );

                      final String? outputFile = await FilePicker.saveFile(
                        dialogTitle: 'Simpan Laporan PDF',
                        fileName: 'Laporan_LAMPID_${selectedDawis ?? "Semua"}_${bulanStr}_${tahunStr}.pdf',
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (outputFile != null) {
                        final file = File(outputFile);
                        await file.writeAsBytes(bytes);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Berhasil diekspor ke $outputFile'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } catch (e, stack) {
                      print('Error exporting PDF: $e');
                      print(stack);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal mengekspor: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Export'),
                ),
              ],
            );
          }
        );
      },
    );
  }

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
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _showPrintDialog(context),
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
          if (mutasi.idIndividuAsal != null && mutasi.idIndividuAsal!.isNotEmpty) {
            context.push('/view-individu/${mutasi.idIndividuAsal}?isReadOnly=true');
          } else {
            _showDetailDialog(context, bangunanAsync.value);
          }
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, dynamic bangunan) {
    String dateStr = mutasi.tanggalMutasi;
    try {
      final date = DateTime.parse(mutasi.tanggalMutasi);
      dateStr = DateFormat('dd MMMM yyyy').format(date);
    } catch (_) {}

    final bangunanStr = bangunan != null ? '\${bangunan.namaKepalaKeluarga}' : '-';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mutasi.jenisMutasi == 'Meninggal' || mutasi.jenisMutasi == 'Pindah'
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      mutasi.jenisMutasi == 'Meninggal' || mutasi.jenisMutasi == 'Pindah'
                          ? (mutasi.jenisMutasi == 'Meninggal' ? Icons.heart_broken : Icons.logout)
                          : (mutasi.jenisMutasi == 'Lahir' ? Icons.child_friendly : Icons.login),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detail ${mutasi.jenisMutasi}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Data ini ditambahkan secara manual dan tidak terhubung dengan Profil Warga secara spesifik.',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDetailRow('Nama', mutasi.namaOrang),
                      if (mutasi.nik != null && mutasi.nik!.isNotEmpty) _buildDetailRow('NIK', mutasi.nik!),
                      _buildDetailRow('Tanggal', dateStr),
                      _buildDetailRow('Bangunan (KK)', bangunanStr),
                      if (mutasi.asal != null && mutasi.asal!.isNotEmpty) _buildDetailRow('Asal', mutasi.asal!),
                      if (mutasi.tujuan != null && mutasi.tujuan!.isNotEmpty) _buildDetailRow('Tujuan', mutasi.tujuan!),
                      if (mutasi.sebabKematian != null && mutasi.sebabKematian!.isNotEmpty) _buildDetailRow('Sebab Kematian', mutasi.sebabKematian!),
                      if (mutasi.namaIbu != null && mutasi.namaIbu!.isNotEmpty) _buildDetailRow('Nama Ibu', mutasi.namaIbu!),
                      if (mutasi.namaSuami != null && mutasi.namaSuami!.isNotEmpty) _buildDetailRow('Nama Suami', mutasi.namaSuami!),
                      if (mutasi.statusIbu != null && mutasi.statusIbu!.isNotEmpty) _buildDetailRow('Status Ibu', mutasi.statusIbu!),
                      if (mutasi.keterangan != null && mutasi.keterangan!.isNotEmpty) _buildDetailRow('Keterangan', mutasi.keterangan!),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
