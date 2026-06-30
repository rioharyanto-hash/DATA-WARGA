import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final startLandscape =
      '    // ==========================================\n    // PAGE 2: LANDSCAPE\n    // ==========================================';
  final endLandscape = '    return pdf.save();';

  final startIndex = content.indexOf(startLandscape);
  final endIndex = content.indexOf(endLandscape, startIndex);

  if (startIndex != -1 && endIndex != -1) {
    var before = content.substring(0, startIndex);
    var after = content.substring(endIndex);

    final newLandscape = '''    // ==========================================
    // PAGE 2: LANDSCAPE
    // ==========================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ),
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROFIL KEPENDUDUKAN (RINCIAN KELUARGA)',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.Text(
                'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
              ),
              pw.SizedBox(height: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text('NAMA', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                      ),
                      pw.Text(': \$namaKelompok', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text('RT / RW', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                      ),
                      pw.Text(': \$rt / \$rw', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text('Kelurahan', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                      ),
                      pw.Text(': \$kelurahan', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text('Kecamatan', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                      ),
                      pw.Text(': \$kecamatan', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text('Kota', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                      ),
                      pw.Text(': \$kota', style: pw.TextStyle(font: regularFont, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                height: 30,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.yellow,
                  border: pw.Border(
                    top: pw.BorderSide(width: 0.5),
                    bottom: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    buildCell('NO', flex: 1, isHeader: true, fontSize: 8),
                    buildCell('Nama Kepala Keluarga', flex: 4, isHeader: true, fontSize: 8),
                    for (int i = 0; i < ageGroups.length; i++)
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(right: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell(ageGroups[i], height: 15, isHeader: true, noRightBorder: true, bottomBorder: true, fontSize: 6),
                              pw.Container(
                                height: 15,
                                child: pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('P', flex: 1, isHeader: true, fontSize: 6),
                                    buildCell('W', flex: 1, isHeader: true, noRightBorder: true, fontSize: 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            buildCell('Jumlah', height: 15, isHeader: true, noRightBorder: true, bottomBorder: true, fontSize: 6),
                            pw.Container(
                              height: 15,
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell('P', flex: 1, isHeader: true, fontSize: 6),
                                  buildCell('W', flex: 1, isHeader: true, noRightBorder: true, fontSize: 6),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // Data Rows
          for (int idx = 0; idx < data.length; idx++) {
            final row = data[idx];
            widgets.add(
              pw.Container(
                height: 20,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    buildCell((idx + 1).toString(), flex: 1, height: 20),
                    buildCell(row['namaKeluarga']?.toString() ?? '', flex: 4, height: 20, alignment: pw.Alignment.centerLeft),
                    for (int i = 0; i < prefixList.length; i++) ...[
                      buildCell(row['\${prefixList[i]}_P']?.toString() ?? '0', flex: 1, height: 20),
                      buildCell(row['\${prefixList[i]}_W']?.toString() ?? '0', flex: 1, height: 20, noRightBorder: false),
                    ],
                    buildCell(row['total_P']?.toString() ?? '0', flex: 1, height: 20),
                    buildCell(row['total_W']?.toString() ?? '0', flex: 1, height: 20, noRightBorder: true),
                  ],
                ),
              ),
            );
          }

          // JUMLAH Row
          widgets.add(
            pw.Container(
              height: 20,
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('', flex: 1, height: 20),
                  buildCell('JUMLAH', flex: 4, isHeader: true, height: 20),
                  for (int i = 0; i < prefixList.length; i++) ...[
                    buildCell(sums['\${prefixList[i]}_P'].toString(), flex: 1, isHeader: true, height: 20),
                    buildCell(sums['\${prefixList[i]}_W'].toString(), flex: 1, isHeader: true, height: 20, noRightBorder: false),
                  ],
                  buildCell(sums['total_P'].toString(), flex: 1, isHeader: true, height: 20),
                  buildCell(sums['total_W'].toString(), flex: 1, isHeader: true, height: 20, noRightBorder: true),
                ],
              ),
            ),
          );

          return widgets;
        },
      ),
    );

''';

    file.writeAsStringSync(before + newLandscape + after);
    print(
      'Landscape PDF rebuilt with MultiPage header and border adjustments.',
    );
  } else {
    print('Could not find boundaries.');
  }
}
