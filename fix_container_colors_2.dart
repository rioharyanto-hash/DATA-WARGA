import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();

  // Pattern: decoration: const pw.BoxDecoration(...), \n color: PdfColors.yellow,
  final regex2 = RegExp(r'decoration:\s*(const\s+)?pw\.BoxDecoration\(([^)]*)\),\s*color:\s*(PdfColors\.\w+),');
  content = content.replaceAllMapped(regex2, (match) {
    final isConst = match.group(1) ?? '';
    final boxDecorArgs = match.group(2) ?? '';
    final color = match.group(3);
    return 'decoration: ${isConst}pw.BoxDecoration(color: $color, $boxDecorArgs),';
  });
  
  // Let's also check for just `color:` without `PdfColors`? No, we mostly use `PdfColors`.

  file.writeAsStringSync(content);
  print('Replaced reversed colors!');
}
