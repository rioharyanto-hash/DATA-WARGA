import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  // Find pw.Container with color and decoration: pw.BoxDecoration
  // We'll just replace "color: PdfColors.yellow," and add it into the decoration instead.
  
  // Pattern 1: color is before decoration
  content = content.replaceAll(
    'color: PdfColors.yellow,\n      decoration: pw.BoxDecoration(\n        border: pw.Border.all(width: 0.5),\n      ),',
    'decoration: pw.BoxDecoration(\n        color: PdfColors.yellow,\n        border: pw.Border.all(width: 0.5),\n      ),'
  );
  
  // Pattern 2: color is before decoration (1 line)
  content = content.replaceAll(
    'color: PdfColors.yellow,\n      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),',
    'decoration: pw.BoxDecoration(\n        color: PdfColors.yellow,\n        border: pw.Border.all(width: 0.5),\n      ),'
  );
  
  // Let's use Regex!
  final regex1 = RegExp(r'color:\s*(PdfColors\.\w+),\s*decoration:\s*(const\s+)?pw\.BoxDecoration\(');
  content = content.replaceAllMapped(regex1, (match) {
    final color = match.group(1);
    final isConst = match.group(2) ?? '';
    return 'decoration: ${isConst}pw.BoxDecoration(color: $color, ';
  });

  file.writeAsStringSync(content);
  print('Replaced colors!');
}
