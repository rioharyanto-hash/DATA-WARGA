import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class ReportPreviewScreen extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() generatePdf;

  const ReportPreviewScreen({
    super.key,
    required this.title,
    required this.generatePdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview: $title')),
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
