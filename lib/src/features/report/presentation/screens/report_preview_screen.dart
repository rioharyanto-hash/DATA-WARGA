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
        backgroundColor: isRingkasan
            ? Colors.amber.shade700
            : Colors.blue.shade700,
      ),
      body: PdfPreview.builder(
        build: (format) => generatePdf(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '$title.pdf',
        pagesBuilder: (context, pages) {
          return ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: InteractiveViewer(
                  panAxis: PanAxis.free,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: page.aspectRatio,
                      child: Image(image: page.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
