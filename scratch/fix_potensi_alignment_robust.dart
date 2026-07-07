import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart'
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // 1. Replace height: 20 with constraints
    if (content.contains('height: 20,')) {
      content = content.replaceAll(
        'height: 20,', 
        'constraints: const pw.BoxConstraints(minHeight: 20),'
      );
      print('Replaced height: 20 in \$path');
    } else {
      print('Could not find height: 20 in \$path');
    }

    // 2. Replace flex values in tableHeaderWidget
    // KRITERIA RUMAH: flex 12 -> 60
    content = content.replaceAll(
      "flex: 12,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('KRITERIA RUMAH', style: style),",
      "flex: 60,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('KRITERIA RUMAH', style: style),"
    );

    // SUMBER AIR KELUARGA: flex 18 -> 90
    content = content.replaceAll(
      "flex: 18,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('SUMBER AIR KELUARGA', style: style),",
      "flex: 90,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('SUMBER AIR KELUARGA', style: style),"
    );

    // MAKANAN POKOK: flex 12 -> 60
    content = content.replaceAll(
      "flex: 12,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('MAKANAN POKOK', style: style),",
      "flex: 60,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('MAKANAN POKOK', style: style),"
    );

    // WARGA MENGIKUTI KEGIATAN: flex 24 -> 120
    content = content.replaceAll(
      "flex: 24,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),",
      "flex: 120,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),"
    );

    file.writeAsStringSync(content);
  }
}
