import 'dart:io';

void main() {
  final file = File(
    r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart',
  );
  var content = file.readAsStringSync();

  if (content.contains('Future<Uint8List> generateProfilUsiaRingkasanPdf')) {
    print('Already contains generateProfilUsiaRingkasanPdf');
    return;
  }

  // We will insert it right before `generateBlankFormProfilUsiaRingkasan`
  final insertIndex = content.indexOf(
    'Future<Uint8List> generateBlankFormProfilUsiaRingkasan() async {',
  );
  if (insertIndex == -1) {
    print('Could not find insertion point!');
    return;
  }

  final newMethod = '''
  Future<Uint8List> generateProfilUsiaRingkasanPdf({
    required List<Map<String, dynamic>> data,
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
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(1),
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
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
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 6 : 8),
          ),
        ),
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    final List<String> ageGroups = [
      '0 - 4',
      '5 - 9th',
      '10 - 14th',
      '15 - 19',
      '20 - 24',
      '25 - 29',
      '30 - 34',
      '35 - 39',
      '40 - 44',
      '45 - 49',
      '50 - 54',
      '55 - 59',
      '60 - 64',
      '65 - 69',
      '70 - 74',
      '75 +',
      'Jumlah',
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
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ), // Landscape F4
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PROFIL KEPENDUDUKAN (RINGKASAN)',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.Text(
                  'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
                pw.SizedBox(height: 16),

                // Header Info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text(
                            'NAMA',
                            style: pw.TextStyle(font: regularFont, fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          ': \$namaKelompok',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text(
                            'RT / RW',
                            style: pw.TextStyle(font: regularFont, fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          ': \$rt / \$rw',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text(
                            'Kelurahan',
                            style: pw.TextStyle(font: regularFont, fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          ': \$kelurahan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text(
                            'Kecamatan',
                            style: pw.TextStyle(font: regularFont, fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          ': \$kecamatan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text(
                            'Kota',
                            style: pw.TextStyle(font: regularFont, fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          ': \$kota',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Tabel Profil Umur
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Row 1: Main Headers
                      pw.Container(
                        height: 30,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.yellow,
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('NO', flex: 1, isHeader: true, fontSize: 8),
                            buildCell(
                              'Nama Kelompok / Kader',
                              flex: 4,
                              isHeader: true,
                              fontSize: 8,
                            ),
                            for (int i = 0; i < ageGroups.length; i++)
                              pw.Expanded(
                                flex: 2,
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                      right: i == ageGroups.length - 1
                                          ? pw.BorderSide.none
                                          : const pw.BorderSide(width: 0.5),
                                    ),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.stretch,
                                    children: [
                                      buildCell(
                                        ageGroups[i],
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        bottomBorder: true,
                                        fontSize: 6,
                                      ),
                                      pw.Expanded(
                                        flex: 1,
                                        child: pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.stretch,
                                          children: [
                                            buildCell(
                                              'P',
                                              flex: 1,
                                              isHeader: true,
                                              fontSize: 6,
                                            ),
                                            buildCell(
                                              'W',
                                              flex: 1,
                                              isHeader: true,
                                              noRightBorder: true,
                                              fontSize: 6,
                                            ),
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
                      
                      // Data Rows
                      ...data.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final row = entry.value;
                        return pw.Container(
                          height: 20,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell(idx.toString(), flex: 1),
                              buildCell(row['namaKeluarga']?.toString() ?? '', flex: 4, alignment: pw.Alignment.centerLeft),
                              for (int i = 0; i < prefixList.length; i++) ...[
                                buildCell(row['\${prefixList[i]}_P']?.toString() ?? '0', flex: 1),
                                buildCell(row['\${prefixList[i]}_W']?.toString() ?? '0', flex: 1, noRightBorder: i == prefixList.length - 1 ? false : true),
                                if (i != prefixList.length - 1)
                                  pw.Container(
                                    width: 0.5,
                                    color: PdfColors.black,
                                  ),
                              ],
                              buildCell(row['total_P']?.toString() ?? '0', flex: 1),
                              buildCell(row['total_W']?.toString() ?? '0', flex: 1, noRightBorder: true),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
  
''';

  content = content.replaceRange(insertIndex, insertIndex, newMethod);
  file.writeAsStringSync(content);
  print('Successfully patched pdf_report_service.dart');
}
