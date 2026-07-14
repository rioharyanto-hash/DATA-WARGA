import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class ReportPreviewScreen extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() generatePdf;
  final bool isRingkasan;

  const ReportPreviewScreen({
    super.key,
    required this.title,
    required this.generatePdf,
    this.isRingkasan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: $title'),
        backgroundColor: isRingkasan ? Colors.amber.shade700 : Colors.blue.shade700,
      ),
      body: PdfPreview(
        build: (format) => generatePdf(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '$title.pdf',
      ),
    );
  }
}
