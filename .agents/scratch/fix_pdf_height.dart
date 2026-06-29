import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String content = await file.readAsString();

  // Find the exact line in generateLampidPdf

  final searchStr1 = '''                      // Data Rows
                      if (mutasiList.isEmpty)
                        for (int i = 1; i <= 10; i++)
                          pw.Container(
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))),''';
  final replaceStr1 = '''                      // Data Rows
                      if (mutasiList.isEmpty)
                        for (int i = 1; i <= 10; i++)
                          pw.Container(
                            constraints: const pw.BoxConstraints(minHeight: 18),
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))),''';
  content = content.replaceFirst(searchStr1, replaceStr1);

  final searchStr2 = '''                      else
                        ...mutasiList.asMap().entries.map((entry) {
                          final i = entry.key + 1;
                          final m = entry.value;

                          return pw.Container(
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))),''';
  final replaceStr2 = '''                      else
                        ...mutasiList.asMap().entries.map((entry) {
                          final i = entry.key + 1;
                          final m = entry.value;

                          return pw.Container(
                            constraints: const pw.BoxConstraints(minHeight: 18),
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5))),''';
  content = content.replaceFirst(searchStr2, replaceStr2);

  await file.writeAsString(content);
  print('Done applying BoxConstraints to pw.Container in generateLampidPdf.');
}
