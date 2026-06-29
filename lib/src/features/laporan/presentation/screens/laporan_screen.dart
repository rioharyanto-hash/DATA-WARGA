import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:dawis/src/features/laporan/services/pdf_report_service.dart';
import 'package:dawis/src/features/laporan/services/excel_report_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _rtController = TextEditingController(text: '001');
  final _rwController = TextEditingController(text: '001');

  bool _isLoading = false;

  void _previewPdf() {
    final rt = _rtController.text.trim();
    final rw = _rwController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Pratinjau Laporan PDF')),
          body: PdfPreview(
            build: (format) async {
              final pdfService = PdfReportService();
              final doc = await pdfService.generateLaporanBulanan(rt, rw);
              return doc.save();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _downloadExcel() async {
    setState(() => _isLoading = true);
    try {
      final excelService = ExcelReportService();
      final bytes = await excelService.generateSummaryExcel(
        _rtController.text.trim(),
        _rwController.text.trim(),
      );

      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download Excel di web butuh implementasi khusus.'),
            ),
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/Laporan_Summary_${_rtController.text}_${_rwController.text}.xlsx',
      );
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil disimpan di: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan Excel: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur unduh template segera hadir.')),
    );
  }

  Future<void> _uploadData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload Data Warga (Import) segera hadir.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // _bgColor
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan & Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Unduh laporan dan rekapitulasi',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rtController,
                          decoration: const InputDecoration(
                            labelText: 'RT',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _rwController,
                          decoration: const InputDecoration(
                            labelText: 'RW',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Pratinjau & Cetak Laporan PDF (Form I & II)',
                      ),
                      onTap: _previewPdf,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.table_chart,
                        color: Colors.green,
                      ),
                      title: const Text('Unduh Laporan Excel (Summary)'),
                      onTap: _downloadExcel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.download, color: Colors.blue),
                      title: const Text('Unduh Template Import Excel'),
                      onTap: _downloadTemplate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.upload_file,
                        color: Colors.orange,
                      ),
                      title: const Text('Upload Data Warga (Import)'),
                      onTap: _uploadData,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
