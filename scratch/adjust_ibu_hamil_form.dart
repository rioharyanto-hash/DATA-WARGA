import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  // 1. Change 20 to 15
  content = content.replaceAll(
    'mutasiList.length < 20 ? 20 : mutasiList.length',
    'mutasiList.length < 15 ? 15 : mutasiList.length'
  );

  // 2. Add height: 20 to Data Rows container
  // Find the exact block for Data Rows pw.Container
  final targetDataRowContainer = """                      if (index >= mutasiList.length) {
                        return pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),""";
  final replaceDataRowContainer = """                      if (index >= mutasiList.length) {
                        return pw.Container(
                          height: 20,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),""";
  content = content.replaceFirst(targetDataRowContainer, replaceDataRowContainer);

  final targetDataRowContainer2 = """                      return pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),""";
  final replaceDataRowContainer2 = """                      return pw.Container(
                        height: 20,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),""";
  content = content.replaceFirst(targetDataRowContainer2, replaceDataRowContainer2);

  // 3. Update JUMLAH row
  final targetJumlahRow = """                    // JUMLAH Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            flex:
                                11, // NO(1)+NAMA IBU(3)+NAMA SUAMI(3)+STATUS(4)
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              padding: const pw.EdgeInsets.only(left: 8),
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                'JUMLAH',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          buildCell('', flex: 4),""";

  final replaceJumlahRow = """                    // JUMLAH Row
                    pw.Container(
                      height: 20,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            flex: 4, // NO(1)+NAMA IBU(3)
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                'JUMLAH',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          buildCell('', flex: 3), // NAMA SUAMI
                          buildCell('', flex: 4), // STATUS
                          buildCell('', flex: 4),""";

  if (content.contains(targetJumlahRow)) {
    content = content.replaceFirst(targetJumlahRow, replaceJumlahRow);
  } else {
    print("Could not find targetJumlahRow");
  }

  await file.writeAsString(content);
  print("Adjusted Ibu Hamil form formatting.");
}
