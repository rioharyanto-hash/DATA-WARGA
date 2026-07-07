import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart'
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // 1. Revert ALL back to height: 20
    content = content.replaceAll(
      'constraints: const pw.BoxConstraints(minHeight: 20)', 
      'height: 20'
    );
    
    // 2. Safely apply to buildDataRow for generatePotensiWargaPdfPerincian and generatePotensiWargaPdf
    // The exact lines for buildDataRow container are:
    String oldRowStart = '''          pw.TableRow buildDataRow(
            List<String> values, {
            bool isTotal = false,
          }) {
            return pw.TableRow(
              decoration: isTotal
                  ? const pw.BoxDecoration(color: PdfColors.yellow)
                  : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2)
                    ? pw.Alignment.centerLeft
                    : pw.Alignment.center;
                return pw.Container(
                  height: 20,
                  padding: const pw.EdgeInsets.all(2),''';
                  
    String newRowStart = '''          pw.TableRow buildDataRow(
            List<String> values, {
            bool isTotal = false,
          }) {
            return pw.TableRow(
              decoration: isTotal
                  ? const pw.BoxDecoration(color: PdfColors.yellow)
                  : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2)
                    ? pw.Alignment.centerLeft
                    : pw.Alignment.center;
                return pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 20),
                  padding: const pw.EdgeInsets.all(2),''';

    content = content.replaceFirst(oldRowStart, newRowStart);

    // Try the other format if the first one didn't match (for the other file)
    String oldRowStart2 = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.yellow) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  height: 20,
                  padding: const pw.EdgeInsets.all(2),''';
                  
    String newRowStart2 = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.yellow) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 20),
                  padding: const pw.EdgeInsets.all(2),''';

    content = content.replaceFirst(oldRowStart2, newRowStart2);
    
    file.writeAsStringSync(content);
  }
  print('Reverted and fixed constraints properly');
}
