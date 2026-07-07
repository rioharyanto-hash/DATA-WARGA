import re

file_path = 'lib/src/features/report/data/services/pdf_perincian_service.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix 1: generateKuantitasWargaPdf height fix (lines 244-609 in old code)
# Replace flexes and columnWidths inside buildDataRow, and move them up
# Since this was done via replace_file_content earlier, I will just apply the same logic using python string replace!

# Fix 2: namaKader and BULAN & THN in generateProfilUsiaPdf
content = content.replace(
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
)

content = content.replace(
'''                          pw.Text(
                            ': ',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),''',
'''                          pw.Text(
                            ': $namaKader',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),''',
)

content = content.replace(
'''                pw.Text(
                  ': ',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),''',
'''                pw.Text(
                  ': ${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][__import__("datetime").datetime.now().month - 1]} ${__import__("datetime").datetime.now().year}',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),'''
)

# Fix 3: generatePotensiPdf row height
# Find the start of generatePotensiPdf
idx = content.find('generatePotensiPdf(')
if idx != -1:
    # Find the loop block
    import re
    # We will match the loop block using a very specific start and end
    # start: for (var r in rows) {
    # end: return [
    match = re.search(r'          for \(var r in rows\) \{[\s\S]*?          return \[', content[idx:])
    if match:
        old_block = match.group(0)
        
        new_block = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
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
                      font: isTotal ? pw.Font.helveticaBold() : pw.Font.helvetica(),
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
                f"{r.get('no', '')}",
                f"{r.get('namaBangunan', '')}",
                f"{r.get('jmlKrt', 0)}",
                f"{r.get('jmlKk', 0)}",
                f"{r.get('L', 0)}",
                f"{r.get('P', 0)}",
                f"{r.get('balitaL', 0)}",
                f"{r.get('balitaP', 0)}",
                f"{r.get('balitaAktifL', 0)}",
                f"{r.get('balitaAktifP', 0)}",
                f"{r.get('pus', 0)}",
                f"{r.get('tidakKb', 0)}",
                f"{r.get('kbPil', 0)}",
                f"{r.get('kbIud', 0)}",
                f"{r.get('kbImplan', 0)}",
                f"{r.get('kbSuntik', 0)}",
                f"{r.get('kbKondom', 0)}",
                f"{r.get('kbSteril', 0)}",
                f"{r.get('kbLainnya', 0)}",
                f"{r.get('remajaL', 0)}",
                f"{r.get('remajaP', 0)}",
                f"{r.get('remajaAktifL', 0)}",
                f"{r.get('remajaAktifP', 0)}",
                f"{r.get('lansiaL', 0)}",
                f"{r.get('lansiaP', 0)}",
                f"{r.get('lansiaAktifL', 0)}",
                f"{r.get('lansiaAktifP', 0)}",
                f"{r.get('berkebutuhanL', 0)}",
                f"{r.get('berkebutuhanP', 0)}",
                '',
              ])
            );
          }

          // TOTAL ROW
          tableRows.add(
            buildDataRow([
              '',
              'JUMLAH',
              f"{tKrt}",
              f"{tKk}",
              f"{tL}",
              f"{tP}",
              f"{tBalitaL}",
              f"{tBalitaP}",
              f"{tBalitaAktifL}",
              f"{tBalitaAktifP}",
              f"{tPus}",
              f"{tTidakKb}",
              f"{tKbPil}",
              f"{tKbIud}",
              f"{tKbImplan}",
              f"{tKbSuntik}",
              f"{tKbKondom}",
              f"{tKbSteril}",
              f"{tKbLainnya}",
              f"{tRemajaL}",
              f"{tRemajaP}",
              f"{tRemajaAktifL}",
              f"{tRemajaAktifP}",
              f"{tLansiaL}",
              f"{tLansiaP}",
              f"{tLansiaAktifL}",
              f"{tLansiaAktifP}",
              f"{tKhususL}",
              f"{tKhususP}",
              '',
            ], isTotal: true)
          );

          return ['''
        
        # We need to change the f-strings into dart strings!
        new_block = new_block.replace('f"{', '\\'${').replace('}"', '}\\'')
        content = content[:idx] + content[idx:].replace(old_block, new_block, 1)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated successfully")
