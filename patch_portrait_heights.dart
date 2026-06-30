import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final oldString = '''
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
              child: pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'UMUR',
                        flex: 2,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'P',
                        flex: 3,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'W',
                        flex: 3,
                        isHeader: true,
                        noRightBorder: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  ...List.generate(ageGroups.length, (i) {
                    final pVal = sums['\${prefixList[i]}_P']?.toString() ?? '0';
                    final wVal = sums['\${prefixList[i]}_W']?.toString() ?? '0';
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(
                          ageGroups[i],
                          flex: 2,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          pVal,
                          flex: 3,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          wVal,
                          flex: 3,
                          noRightBorder: true,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                      ],
                    );
                  }),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'TOTAL',
                        flex: 2,
                        isHeader: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_P']?.toString() ?? '0',
                        flex: 3,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_W']?.toString() ?? '0',
                        flex: 3,
                        noRightBorder: true,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
''';

  final newString = '''
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
              child: pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'UMUR',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'P',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'W',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        noRightBorder: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  ...List.generate(ageGroups.length, (i) {
                    final pVal = sums['\${prefixList[i]}_P']?.toString() ?? '0';
                    final wVal = sums['\${prefixList[i]}_W']?.toString() ?? '0';
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(
                          ageGroups[i],
                          flex: 1,
                          height: 28,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          pVal,
                          flex: 1,
                          height: 28,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          wVal,
                          flex: 1,
                          height: 28,
                          noRightBorder: true,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                      ],
                    );
                  }),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'TOTAL',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_P']?.toString() ?? '0',
                        flex: 1,
                        height: 28,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_W']?.toString() ?? '0',
                        flex: 1,
                        height: 28,
                        noRightBorder: true,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
''';

  if (content.contains(oldString)) {
    content = content.replaceAll(oldString, newString);
    file.writeAsStringSync(content);
    print('Portrait table sizes and flex patched!');
  } else {
    print('Failed to find oldString. Searching for parts...');
  }
}
