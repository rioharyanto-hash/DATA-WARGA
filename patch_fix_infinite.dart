import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  // Fix 1: Header Row in Landscape
  content = content.replaceFirst(
    '''
          // Header Row
          widgets.add(
            pw.Container(
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
''',
    '''
          // Header Row
          widgets.add(
            pw.Container(
              height: 30, // FIX: Bounded height
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
''',
  );

  // Fix 2: Data Rows in Landscape
  content = content.replaceFirst(
    '''
          // Data Rows
          for (int idx = 0; idx < data.length; idx++) {
            final row = data[idx];
            widgets.add(
              pw.Container(
                decoration: const pw.BoxDecoration(
''',
    '''
          // Data Rows
          for (int idx = 0; idx < data.length; idx++) {
            final row = data[idx];
            widgets.add(
              pw.Container(
                height: 20, // FIX: Bounded height
                decoration: const pw.BoxDecoration(
''',
  );

  // Fix 3: JUMLAH Row in Landscape
  content = content.replaceFirst(
    '''
          // JUMLAH Row
          widgets.add(
            pw.Container(
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
                border: pw.Border(
''',
    '''
          // JUMLAH Row
          widgets.add(
            pw.Container(
              height: 20, // FIX: Bounded height
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
                border: pw.Border(
''',
  );

  file.writeAsStringSync(content);
  print('Fixed unbounded container heights in Landscape table.');
}
