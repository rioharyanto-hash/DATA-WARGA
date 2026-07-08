import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  // 1. Standardize header fonts
  // We want to replace fontSize: 8 or fontSize: 7 to fontSize: 6
  // ONLY in the generateLampidPdfRingkasan section.
  // The section starts around "Future<Uint8List> generateLampidPdfRingkasan" and ends at the end of the file or next method.
  
  int startIndex = content.indexOf('generateLampidPdfRingkasan');
  if (startIndex != -1) {
    String before = content.substring(0, startIndex);
    String after = content.substring(startIndex);

    // Default font size in buildCell
    after = after.replaceAll('fontSize: fontSize ?? (isHeader ? 7 : 8)', 'fontSize: fontSize ?? (isHeader ? 6 : 8)');

    // Explicit fontSize: 8 or 7 in headers. Since headers in Lampid typically use `isHeader: true`
    // Let's replace any `fontSize: 8` with `fontSize: 6` inside `isHeader: true` calls,
    // Actually, in Lampid, let's just replace all `fontSize: 8` with `fontSize: 6` in the header section.
    // The header section is from `// Row 1: Main Headers` to `// Data Rows`
    int headerStart = after.indexOf('// Row 1: Main Headers');
    int headerEnd = after.indexOf('// Data Rows');
    
    if (headerStart != -1 && headerEnd != -1) {
      String headerPart = after.substring(headerStart, headerEnd);
      headerPart = headerPart.replaceAll('fontSize: 8', 'fontSize: 6');
      headerPart = headerPart.replaceAll('fontSize: 7', 'fontSize: 6');
      after = after.substring(0, headerStart) + headerPart + after.substring(headerEnd);
    }
    
    // Also, there are column numbers (1, 2, 3...) which might be fontSize: 8
    // Let's check for `// Row N` blocks. Actually the `headerEnd` covers all headers up to `// Data Rows`.

    // 2. Add 20 empty rows and remove "Tidak ada data mutasi"
    final targetRows = """                    // Data Rows
                    ...mutasiList.asMap().entries.map((entry) {
                      final int i = entry.key + 1;
                      final row = entry.value;""";

    final replaceRows = """                    // Data Rows
                    ...List.generate(mutasiList.length < 20 ? 20 : mutasiList.length, (index) {
                      if (index >= mutasiList.length) {
                        return pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell('', flex: 1, fontSize: 7),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 4),
                              buildCell('', flex: 4),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 2),
                              buildCell('', flex: 3, noRightBorder: true),
                            ],
                          ),
                        );
                      }
                      final int i = index + 1;
                      final row = mutasiList[index];""";

    after = after.replaceFirst(targetRows, replaceRows);

    final targetEmptyBlock = """                    if (mutasiList.isEmpty)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Tidak ada data mutasi',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                        ),
                      ),""";
    
    after = after.replaceFirst(targetEmptyBlock, "");
    // Just in case mutasiList.isEmpty block was slightly different
    
    // Also remove the `})` that ends the `...mutasiList.asMap().entries.map((entry) {` 
    // Wait, the end of the block is `});`? No, it's `}),`. We need to replace `}),` with `}),`. That's identical.
    
    content = before + after;
  }

  await file.writeAsString(content);
  print("Updated Lampid (Ibu Hamil) PDF format.");
}
