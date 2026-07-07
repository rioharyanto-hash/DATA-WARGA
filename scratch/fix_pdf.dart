import 'dart:io';

void main() {
  var file = File('lib/src/features/report/data/services/pdf_perincian_service.dart');
  var content = file.readAsStringSync();

  // Fix 2: namaKader and BULAN & THN in generateProfilUsiaPdf
  content = content.replaceAll(
'''  Future<Uint8List> generateProfilUsiaPdf({
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
  }) async {''',
'''  Future<Uint8List> generateProfilUsiaPdf({
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
    required String namaKader,
  }) async {'''
  );

  content = content.replaceFirst(
'''                          pw.Text(
                            ': ',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),''',
'''                          pw.Text(
                            ': \$namaKader',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),'''
  );

  content = content.replaceFirst(
'''                pw.Text(
                  ': ',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),''',
'''                pw.Text(
                  ': \${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][DateTime.now().month - 1]} \${DateTime.now().year}',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),'''
  );

  // Fix 3: generatePotensiPdf row height
  int idx = content.indexOf('generatePotensiPdf(');
  if (idx != -1) {
    String patternStr = r'''          for \(var r in rows\) \{[\s\S]*?          return \[''';
    RegExp exp = RegExp(patternStr);
    var match = exp.firstMatch(content.substring(idx));
    if (match != null) {
      String oldBlock = match.group(0)!;
      String newBlock = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.grey300) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  height: 20,
                  padding: const pw.EdgeInsets.all(2),
                  alignment: alignment,
                  child: pw.Text(
                    values[i],
                    style: pw.TextStyle(
                      font: isTotal ? boldFont : regularFont,
                      fontSize: 6,
                    ),
                  ),
                );
              }),
            );
          }

          for (var r in rows) {
            tKrt += r['jmlKrt'] as int? ?? 0;
            tKk += r['jmlKk'] as int? ?? 0;
            tL += r['L'] as int? ?? 0;
            tP += r['P'] as int? ?? 0;
            tBalitaL += r['balitaL'] as int? ?? 0;
            tBalitaP += r['balitaP'] as int? ?? 0;
            tBalitaAktifL += r['balitaAktifL'] as int? ?? 0;
            tBalitaAktifP += r['balitaAktifP'] as int? ?? 0;
            tPus += r['pus'] as int? ?? 0;
            tTidakKb += r['tidakKb'] as int? ?? 0;
            tKbPil += r['kbPil'] as int? ?? 0;
            tKbIud += r['kbIud'] as int? ?? 0;
            tKbImplan += r['kbImplan'] as int? ?? 0;
            tKbSuntik += r['kbSuntik'] as int? ?? 0;
            tKbKondom += r['kbKondom'] as int? ?? 0;
            tKbSteril += r['kbSteril'] as int? ?? 0;
            tKbLainnya += r['kbLainnya'] as int? ?? 0;

            tRemajaL += r['remajaL'] as int? ?? 0;
            tRemajaP += r['remajaP'] as int? ?? 0;
            tRemajaAktifL += r['remajaAktifL'] as int? ?? 0;
            tRemajaAktifP += r['remajaAktifP'] as int? ?? 0;

            tLansiaL += r['lansiaL'] as int? ?? 0;
            tLansiaP += r['lansiaP'] as int? ?? 0;
            tLansiaAktifL += r['lansiaAktifL'] as int? ?? 0;
            tLansiaAktifP += r['lansiaAktifP'] as int? ?? 0;

            tKhususL += r['berkebutuhanL'] as int? ?? 0;
            tKhususP += r['berkebutuhanP'] as int? ?? 0;

            tableRows.add(
              buildDataRow([
                '\${r['no'] ?? ''}',
                '\${r['namaBangunan'] ?? ''}',
                '\${r['jmlKrt'] ?? 0}',
                '\${r['jmlKk'] ?? 0}',
                '\${r['L'] ?? 0}',
                '\${r['P'] ?? 0}',
                '\${r['balitaL'] ?? 0}',
                '\${r['balitaP'] ?? 0}',
                '\${r['balitaAktifL'] ?? 0}',
                '\${r['balitaAktifP'] ?? 0}',
                '\${r['pus'] ?? 0}',
                '\${r['tidakKb'] ?? 0}',
                '\${r['kbPil'] ?? 0}',
                '\${r['kbIud'] ?? 0}',
                '\${r['kbImplan'] ?? 0}',
                '\${r['kbSuntik'] ?? 0}',
                '\${r['kbKondom'] ?? 0}',
                '\${r['kbSteril'] ?? 0}',
                '\${r['kbLainnya'] ?? 0}',
                '\${r['remajaL'] ?? 0}',
                '\${r['remajaP'] ?? 0}',
                '\${r['remajaAktifL'] ?? 0}',
                '\${r['remajaAktifP'] ?? 0}',
                '\${r['lansiaL'] ?? 0}',
                '\${r['lansiaP'] ?? 0}',
                '\${r['lansiaAktifL'] ?? 0}',
                '\${r['lansiaAktifP'] ?? 0}',
                '\${r['berkebutuhanL'] ?? 0}',
                '\${r['berkebutuhanP'] ?? 0}',
                '',
              ])
            );
          }

          // TOTAL ROW
          tableRows.add(
            buildDataRow([
              '',
              'JUMLAH',
              '\$tKrt',
              '\$tKk',
              '\$tL',
              '\$tP',
              '\$tBalitaL',
              '\$tBalitaP',
              '\$tBalitaAktifL',
              '\$tBalitaAktifP',
              '\$tPus',
              '\$tTidakKb',
              '\$tKbPil',
              '\$tKbIud',
              '\$tKbImplan',
              '\$tKbSuntik',
              '\$tKbKondom',
              '\$tKbSteril',
              '\$tKbLainnya',
              '\$tRemajaL',
              '\$tRemajaP',
              '\$tRemajaAktifL',
              '\$tRemajaAktifP',
              '\$tLansiaL',
              '\$tLansiaP',
              '\$tLansiaAktifL',
              '\$tLansiaAktifP',
              '\$tKhususL',
              '\$tKhususP',
              '',
            ], isTotal: true)
          );

          return [''';

      content = content.substring(0, idx) + content.substring(idx).replaceFirst(oldBlock, newBlock);
    }
  }

  file.writeAsStringSync(content);
  print("Updated successfully");
}
