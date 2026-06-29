import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final portraitMethod = '''
  /// =========================================================================
  /// FORM PROFIL KEPENDUDUKAN - RINGKASAN (TERISI)
  /// Format: Portrait, F4
  /// =========================================================================
  Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf({
    required Map<String, int> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
  }) async {
    final pdf = pw.Document();

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();

    pw.Widget buildCell(
      String text, {
      double? width,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
      pw.Alignment alignment = pw.Alignment.center,
      PdfColor backgroundColor = PdfColors.white,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(4),
        alignment: alignment,
        decoration: pw.BoxDecoration(
          color: backgroundColor,
          border: pw.Border(
            right: noRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.5),
            bottom: bottomBorder
                ? const pw.BorderSide(width: 0.5)
                : pw.BorderSide.none,
          ),
        ),
        child: pw.Text(
          text,
          textAlign: alignment == pw.Alignment.centerLeft ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 10 : 10),
          ),
        ),
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    final List<String> ageGroups = [
      '0 - 4 Tahun',
      '5 - 9 Tahun',
      '10 - 14 Tahun',
      '15 - 19 Tahun',
      '20 - 24 Tahun',
      '25 - 29 Tahun',
      '30 - 34 Tahun',
      '35 - 39 Tahun',
      '40 - 44 Tahun',
      '45 - 49 Tahun',
      '50 - 54 Tahun',
      '55 - 59 Tahun',
      '60 - 64 Tahun',
      '65 - 69 Tahun',
      '70 - 74 Tahun',
      '75 Tahun',
    ];

    final List<String> prefixList = [
      '0_4',
      '5_9',
      '10_14',
      '15_19',
      '20_24',
      '25_29',
      '30_34',
      '35_39',
      '40_44',
      '45_49',
      '50_54',
      '55_59',
      '60_64',
      '65_69',
      '70_74',
      '75_plus',
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          21.5 * PdfPageFormat.cm,
          33.0 * PdfPageFormat.cm,
        ), // Portrait F4
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROFIL KEPENDUDUKAN',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                style: pw.TextStyle(font: regularFont, fontSize: 12),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'NAMA',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': \$namaKelompok',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'Kelompok',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': ',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'RT / RW',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': \$rt / \$rw',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'Kelurahan',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': \$kelurahan',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'Kecamatan',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': \$kecamatan',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 100,
                              child: pw.Text(
                                'Kota',
                                style: pw.TextStyle(font: regularFont, fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              ': \$kota',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 100,
                    child: pw.Text(
                      'BULAN & THN',
                      style: pw.TextStyle(font: regularFont, fontSize: 10),
                    ),
                  ),
                  pw.Text(
                    ': ',
                    style: pw.TextStyle(font: regularFont, fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Tabel Profil Umur Ringkasan (Portrait)
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
                child: pw.Column(
                  children: [
                    // Header
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(
                          'UMUR',
                          flex: 2,
                          isHeader: true,
                          bottomBorder: true,
                          backgroundColor: PdfColors.yellow,
                        ),
                        buildCell(
                          'P',
                          flex: 3,
                          isHeader: true,
                          bottomBorder: true,
                          backgroundColor: PdfColors.yellow,
                        ),
                        buildCell(
                          'W',
                          flex: 3,
                          isHeader: true,
                          noRightBorder: true,
                          bottomBorder: true,
                          backgroundColor: PdfColors.yellow,
                        ),
                      ],
                    ),
                    // Rows
                    ...List.generate(ageGroups.length, (i) {
                      final pVal = data['\${prefixList[i]}_P']?.toString() ?? '0';
                      final wVal = data['\${prefixList[i]}_W']?.toString() ?? '0';
                      return pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          buildCell(
                            ageGroups[i],
                            flex: 2,
                            bottomBorder: true,
                          ),
                          buildCell(
                            pVal,
                            flex: 3,
                            bottomBorder: true,
                          ),
                          buildCell(
                            wVal,
                            flex: 3,
                            noRightBorder: true,
                            bottomBorder: true,
                          ),
                        ],
                      );
                    }),
                    // Footer (TOTAL)
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell(
                          'TOTAL',
                          flex: 2,
                          isHeader: true,
                          backgroundColor: PdfColors.yellow,
                        ),
                        buildCell(
                          data['total_P']?.toString() ?? '0',
                          flex: 3,
                          backgroundColor: PdfColors.yellow,
                        ),
                        buildCell(
                          data['total_W']?.toString() ?? '0',
                          flex: 3,
                          noRightBorder: true,
                          backgroundColor: PdfColors.yellow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
''';

  final lastBraceIndex = content.lastIndexOf('}');
  content = content.replaceRange(
    lastBraceIndex,
    lastBraceIndex + 1,
    portraitMethod,
  );

  file.writeAsStringSync(content);
  print('Added portrait method successfully');
}
