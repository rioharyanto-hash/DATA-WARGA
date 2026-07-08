import re

with open('lib/src/features/report/data/services/pdf_perincian_service.dart', 'r') as f:
    perincian = f.read()

# Extract generatePotensiWargaPdfPerincian
match = re.search(r'Future<Uint8List> generatePotensiWargaPdfPerincian\(\{(.*?)\n  Future<Uint8List> generateCatatan', perincian, re.DOTALL)
if not match:
    print("Could not find generatePotensiWargaPdfPerincian")
    exit(1)

func_body = "Future<Uint8List> generatePotensiWargaPdfRingkasan({" + match.group(1)

# Now apply replacements to func_body
func_body = func_body.replace(
    "'DATA POTENSI WARGA (TERISI)'",
    "'DATA POTENSI WARGA\\nKELOMPOK PKK RW'"
)

# Header columns replacement
header_target = """          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
          buildCell('NAMA\\nBANGUNAN', flex: 4, isHeader: true, fontSize: 5),
          buildCell('JML\\nKRT', flex: 1, isHeader: true, fontSize: 5),
          buildCell('JML\\nKK', flex: 1, isHeader: true, fontSize: 5),
          // TOTAL (L, P)"""

header_replace = """          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
          buildCell('NOMOR RT', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nDASAWISMA', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nBANGUNAN', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nKELOMPOK', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JML\\nKRT', flex: 1, isHeader: true, fontSize: 5),
          buildCell('JML\\nKK', flex: 1, isHeader: true, fontSize: 5),
          // TOTAL (L, P)"""

func_body = func_body.replace(header_target, header_replace)

# Row formatting replacement
row_target = """                      buildCell((i + 1).toString(), flex: 1, fontSize: 5),
                      buildCell(potensi['namaWarga']?.toString() ?? '', flex: 4, alignment: pw.Alignment.centerLeft, fontSize: 5),
                      buildCell(potensi['jumlah_krt']?.toString() ?? '', flex: 1, fontSize: 5),
                      buildCell(potensi['jumlah_kk']?.toString() ?? '', flex: 1, fontSize: 5),
                      // TOTAL"""

row_replace = """                      buildCell((i + 1).toString(), flex: 1, fontSize: 5),
                      buildCell(potensi['nomor_rt']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_dasawisma']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_bangunan']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_kelompok']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_krt']?.toString() ?? '', flex: 1, fontSize: 5),
                      buildCell(potensi['jumlah_kk']?.toString() ?? '', flex: 1, fontSize: 5),
                      // TOTAL"""

func_body = func_body.replace(row_target, row_replace)

# Total row formatting replacement
total_target = """                      buildCell('JUMLAH', flex: 5, isHeader: true, fontSize: 5),
                      buildCell(totalKrt.toString(), flex: 1, isHeader: true, fontSize: 5),
                      buildCell(totalKk.toString(), flex: 1, isHeader: true, fontSize: 5),
                      // TOTAL"""

total_replace = """                      buildCell('JUMLAH', flex: 3, isHeader: true, fontSize: 5),
                      buildCell(totalDasawisma.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalBangunan.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalKelompok.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalKrt.toString(), flex: 1, isHeader: true, fontSize: 5),
                      buildCell(totalKk.toString(), flex: 1, isHeader: true, fontSize: 5),
                      // TOTAL"""

func_body = func_body.replace(total_target, total_replace)

# We need to add totalDasawisma, totalBangunan, totalKelompok parsing
totals_target = """      int totalKrt = 0;
      int totalKk = 0;
      int totalTotalL = 0;"""

totals_replace = """      int totalDasawisma = 0;
      int totalBangunan = 0;
      int totalKelompok = 0;
      int totalKrt = 0;
      int totalKk = 0;
      int totalTotalL = 0;"""
func_body = func_body.replace(totals_target, totals_replace)

totals_calc_target = """        totalKrt += int.tryParse(potensi['jumlah_krt']?.toString() ?? '0') ?? 0;
        totalKk += int.tryParse(potensi['jumlah_kk']?.toString() ?? '0') ?? 0;
        totalTotalL += int.tryParse(potensi['total_L']?.toString() ?? '0') ?? 0;"""

totals_calc_replace = """        totalDasawisma += int.tryParse(potensi['jumlah_dasawisma']?.toString() ?? '0') ?? 0;
        totalBangunan += int.tryParse(potensi['jumlah_bangunan']?.toString() ?? '0') ?? 0;
        totalKelompok += int.tryParse(potensi['jumlah_kelompok']?.toString() ?? '0') ?? 0;
        totalKrt += int.tryParse(potensi['jumlah_krt']?.toString() ?? '0') ?? 0;
        totalKk += int.tryParse(potensi['jumlah_kk']?.toString() ?? '0') ?? 0;
        totalTotalL += int.tryParse(potensi['total_L']?.toString() ?? '0') ?? 0;"""
func_body = func_body.replace(totals_calc_target, totals_calc_replace)

# Header mapping
header_info_target = """            pw.Text('DATA POTENSI WARGA (TERISI)',
                style: pw.TextStyle(font: boldFont, fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RT', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('RW', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Kelurahan', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Kecamatan', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Tahun', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 7,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(': ${data['rt'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': ${data['rw'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': ${data['kelurahan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': ${data['kecamatan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': ${data['tahun'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),"""

header_info_replace = """            pw.Text('DATA POTENSI WARGA\\nKELOMPOK PKK RW',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: boldFont, fontSize: 8)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RW', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('DUSUN / LINGKUNGAN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('DESA / KELURAHAN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('TAHUN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('PERIODE', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ],
                ),
                pw.SizedBox(width: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(': ${data['rw'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': -', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': ${data['kelurahan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': ${data['tahun'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': ${data['periode'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),"""
func_body = func_body.replace(header_info_target, header_info_replace)


# Read original pdf_ringkasan_service.dart
with open('lib/src/features/report/data/services/pdf_ringkasan_service.dart', 'r') as f:
    ringkasan = f.read()

# Replace the old generatePotensiWargaPdfRingkasan
match_old = re.search(r'Future<Uint8List> generatePotensiWargaPdfRingkasan\(\{(.*?)\n  Future<Uint8List> generateCatatan', ringkasan, re.DOTALL)
if not match_old:
    print("Could not find old generatePotensiWargaPdfRingkasan")
    exit(1)

new_ringkasan = ringkasan[:match_old.start()] + func_body + "\n  Future<Uint8List> generateCatatan" + ringkasan[match_old.end():]

with open('lib/src/features/report/data/services/pdf_ringkasan_service.dart', 'w') as f:
    f.write(new_ringkasan)

print("Replacement successful")
