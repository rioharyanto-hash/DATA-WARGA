import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final startMethod = 'Future<Uint8List> generateProfilUsiaPdf({';
  final endMethodStr =
      '  Future<Uint8List> generateBlankFormProfilUsiaRingkasan() async {';

  final methodIndex = content.indexOf(startMethod);
  final endMethodIndex = content.indexOf(endMethodStr);

  if (methodIndex != -1 && endMethodIndex != -1) {
    var beforeMethod = content.substring(0, methodIndex);
    var afterMethod = content.substring(endMethodIndex);

    final newMethod = '''
  Future<Uint8List> generateProfilUsiaPdf({
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
      pw.Alignment alignment = pw.Alignment.center,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(1),
        alignment: alignment,
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
          textAlign: alignment == pw.Alignment.centerLeft
              ? pw.TextAlign.left
              : pw.TextAlign.center,
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

    final ageGroups = [
      '0 - 4',
      '5 - 9',
      '10 - 14',
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
    ];

    final prefixList = [
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
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PROFIL KEPENDUDUKAN',
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
              ],
            ),
          );

          // Header Row
          widgets.add(
            pw.Container(
              height: 30,
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
                border: pw.Border(
                  top: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  buildCell('NO', flex: 1, isHeader: true, fontSize: 8),
                  buildCell('Nama Kelompok / Kader', flex: 4, isHeader: true, fontSize: 8),
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
                            buildCell(ageGroups[i], flex: 1, isHeader: true, noRightBorder: true, bottomBorder: true, fontSize: 6),
                            pw.Expanded(
                              flex: 1,
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
                  // Jumlah Header
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          buildCell('Jumlah', flex: 1, isHeader: true, noRightBorder: true, bottomBorder: true, fontSize: 6),
                          pw.Expanded(
                            flex: 1,
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
          );

          // Data Rows
          for (int idx = 0; idx < data.length; idx++) {
            final row = data[idx];
            widgets.add(
              pw.Container(
                height: 20,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    buildCell((idx + 1).toString(), flex: 1),
                    buildCell(row['namaKeluarga']?.toString() ?? '', flex: 4, alignment: pw.Alignment.centerLeft),
                    for (int i = 0; i < prefixList.length; i++) ...[
                      buildCell(row['\${prefixList[i]}_P']?.toString() ?? '0', flex: 1),
                      buildCell(row['\${prefixList[i]}_W']?.toString() ?? '0', flex: 1, noRightBorder: false),
                    ],
                    buildCell(row['total_P']?.toString() ?? '0', flex: 1),
                    buildCell(row['total_W']?.toString() ?? '0', flex: 1, noRightBorder: true),
                  ],
                ),
              ),
            );
          }

          // JUMLAH Row Data calculations
          Map<String, int> sums = {};
          for (var prefix in prefixList) {
            sums['\${prefix}_P'] = 0;
            sums['\${prefix}_W'] = 0;
          }
          sums['total_P'] = 0;
          sums['total_W'] = 0;

          for (var r in data) {
            for (var prefix in prefixList) {
              sums['\${prefix}_P'] = (sums['\${prefix}_P']!) + (int.tryParse(r['\${prefix}_P']?.toString() ?? '0') ?? 0);
              sums['\${prefix}_W'] = (sums['\${prefix}_W']!) + (int.tryParse(r['\${prefix}_W']?.toString() ?? '0') ?? 0);
            }
            sums['total_P'] = (sums['total_P']!) + (int.tryParse(r['total_P']?.toString() ?? '0') ?? 0);
            sums['total_W'] = (sums['total_W']!) + (int.tryParse(r['total_W']?.toString() ?? '0') ?? 0);
          }

          widgets.add(
            pw.Container(
              height: 20,
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
                  buildCell('', flex: 1),
                  buildCell('JUMLAH', flex: 4, isHeader: true),
                  for (int i = 0; i < prefixList.length; i++) ...[
                    buildCell(sums['\${prefixList[i]}_P'].toString(), flex: 1, isHeader: true),
                    buildCell(sums['\${prefixList[i]}_W'].toString(), flex: 1, isHeader: true, noRightBorder: false),
                  ],
                  buildCell(sums['total_P'].toString(), flex: 1, isHeader: true),
                  buildCell(sums['total_W'].toString(), flex: 1, isHeader: true, noRightBorder: true),
                ],
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }
''';

    file.writeAsStringSync(beforeMethod + newMethod + afterMethod);
    print(
      'generateProfilUsiaPdf updated correctly with pagination and JUMLAH row.',
    );
  } else {
    print('Could not find boundaries.');
  }
}
