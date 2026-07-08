import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  // Fix 1: Numbering Row (around line 2014)
  final numRowTarget = """                    for (int j = 1; j <= 30; j++)
                      pw.Expanded(
                        flex: j == 2 ? 4 : 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: j == 30
                                  ? pw.BorderSide.none
                                  : const pw.BorderSide(width: 0.5),
                            ),
                          ),""";
  final numRowReplace = """                    for (int j = 1; j <= 33; j++)
                      pw.Expanded(
                        flex: (j >= 2 && j <= 5) ? 2 : 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: j == 33
                                  ? pw.BorderSide.none
                                  : const pw.BorderSide(width: 0.5),
                            ),
                          ),""";
  content = content.replaceAll(numRowTarget, numRowReplace);

  // Fix 2: Variable declarations for totals
  final varTarget = """          int tBerkebutuhanL = 0, tBerkebutuhanP = 0;

          List<pw.TableRow> tableRows = [];

          for (var r in rows) {""";
  final varReplace = """          int tBerkebutuhanL = 0, tBerkebutuhanP = 0;
          int tDasawisma = 0, tBangunan = 0, tKelompok = 0;

          List<pw.TableRow> tableRows = [];

          for (var r in rows) {""";
  content = content.replaceAll(varTarget, varReplace);

  // Fix 3: Loop extraction and accumulating
  final calcTarget = """            final berkebutuhanP = r['berkebutuhanP'] as int? ?? 0;

            tKrt += krt;""";
  final calcReplace = """            final berkebutuhanP = r['berkebutuhanP'] as int? ?? 0;
            
            final dasawisma = r['jumlah_dasawisma'] as int? ?? 1;
            final bangunan = r['jumlah_bangunan'] as int? ?? 0;
            final kelompokVal = r['jumlah_kelompok'] as int? ?? 1;

            tDasawisma += dasawisma;
            tBangunan += bangunan;
            tKelompok += kelompokVal;

            tKrt += krt;""";
  content = content.replaceAll(calcTarget, calcReplace);

  // Fix 4: Values array and loop bound
  final valuesTarget = """            final values = [
              '\${r['no']}',
              '\${r['namaBangunan'] ?? r['dasawisma'] ?? ''}',
              '\$krt',
              '\$kk',""";
  final valuesReplace = """            final values = [
              '\${r['no']}',
              '\${r['nomor_rt'] ?? ''}',
              '\$dasawisma',
              '\$bangunan',
              '\$kelompokVal',
              '\$krt',
              '\$kk',""";
  content = content.replaceAll(valuesTarget, valuesReplace);

  final tableLoopTarget = """                  for (int j = 0; j < 30; j++)
                    pw.Container(""";
  final tableLoopReplace = """                  for (int j = 0; j < 33; j++)
                    pw.Container(""";
  content = content.replaceAll(tableLoopTarget, tableLoopReplace);

  // Fix 5: Total Values array and loops
  final totalTarget = """          final totalValues = [
            'JUMLAH',
            '',
            '\$tKrt',
            '\$tKk',""";
  final totalReplace = """          final totalValues = [
            'JUMLAH',
            '',
            '\$tDasawisma',
            '\$tBangunan',
            '\$tKelompok',
            '\$tKrt',
            '\$tKk',""";
  content = content.replaceAll(totalTarget, totalReplace);

  final totalRowTarget = """                for (int j = 0; j < 30; j++)
                  pw.Container(""";
  final totalRowReplace = """                for (int j = 0; j < 33; j++)
                  pw.Container(""";
  content = content.replaceAll(totalRowTarget, totalRowReplace);
  
  final colWidthTarget = """              columnWidths: {
                for (int j = 0; j < 30; j++)
                  j: j == 1 ? const pw.FlexColumnWidth(4) : const pw.FlexColumnWidth(1),
              },""";
  final colWidthReplace = """              columnWidths: {
                for (int j = 0; j < 33; j++)
                  j: (j >= 1 && j <= 4) ? const pw.FlexColumnWidth(2) : const pw.FlexColumnWidth(1),
              },""";
  content = content.replaceAll(colWidthTarget, colWidthReplace);
  
  // Total JUMLAH formatting
  final totalFormatTarget = """                    child: pw.Text(
                      totalValues[j],
                      style: pw.TextStyle(font: boldFont, fontSize: j == 1 ? 6 : 5),
                    ),""";
  final totalFormatReplace = """                    child: pw.Text(
                      totalValues[j],
                      style: pw.TextStyle(font: boldFont, fontSize: 5),
                    ),""";
  content = content.replaceAll(totalFormatTarget, totalFormatReplace);

  await file.writeAsString(content);
  print("Fix applied successfully!");
}
