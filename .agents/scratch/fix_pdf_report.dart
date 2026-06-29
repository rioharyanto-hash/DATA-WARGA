import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String content = await file.readAsString();

  // Find start of broken YatimPiatu
  final startBroken = content.indexOf(
    '  Future<Uint8List> generateYatimPiatuPdf({',
  );
  if (startBroken != -1) {
    content = content.substring(0, startBroken);
  }

  final buildCellFunc = '''
    pw.Widget buildCell(String text, {int flex = 1, bool isHeader = false, bool bottomBorder = false, bool noRightBorder = false}) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            color: isHeader ? PdfColors.grey300 : null,
            border: pw.Border(
              right: noRightBorder ? pw.BorderSide.none : const pw.BorderSide(color: PdfColors.black, width: 0.5),
              bottom: bottomBorder ? const pw.BorderSide(color: PdfColors.black, width: 0.5) : pw.BorderSide.none,
            ),
          ),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              font: isHeader ? fontBold : font,
              fontSize: isHeader ? 10 : 9,
              fontWeight: isHeader ? pw.FontWeight.bold : null,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }
''';

  final yatimPiatu = '''
  Future<Uint8List> generateYatimPiatuPdf({
    required String namaKelompok,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
    required String provinsi,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

\${buildCellFunc}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'DATA ANAK YATIM PIATU',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Kelompok Dasawisma: \$namaKelompok', style: pw.TextStyle(font: fontBold)),
            pw.Text('RT/RW: \$rt/\$rw', style: pw.TextStyle(font: font)),
            pw.Text('Kelurahan/Desa: \$desa', style: pw.TextStyle(font: font)),
            pw.Text('Kecamatan: \$kecamatan', style: pw.TextStyle(font: font)),
            pw.Text('Kabupaten/Kota: \$kabupaten', style: pw.TextStyle(font: font)),
            pw.Text('Provinsi: \$provinsi', style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    buildCell('No', flex: 1, isHeader: true),
                    buildCell('Nama', flex: 4, isHeader: true),
                    buildCell('NIK', flex: 3, isHeader: true),
                    buildCell('Umur', flex: 2, isHeader: true),
                    buildCell('L/P', flex: 1, isHeader: true),
                    buildCell('Alamat', flex: 4, isHeader: true),
                    buildCell('Nama Wali', flex: 3, isHeader: true),
                    buildCell('Status Yatim Piatu', flex: 3, isHeader: true, noRightBorder: true),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      buildCell(index.toString(), flex: 1, bottomBorder: true),
                      buildCell(item['nama_orang']?.toString() ?? '', flex: 4, bottomBorder: true),
                      buildCell(item['nik']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['umur']?.toString() ?? '', flex: 2, bottomBorder: true),
                      buildCell(item['jk'] == 'Laki-laki' ? 'L' : (item['jk'] == 'Perempuan' ? 'P' : ''), flex: 1, bottomBorder: true),
                      buildCell(item['alamat']?.toString() ?? '', flex: 4, bottomBorder: true),
                      buildCell(item['nama_wali']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['status_yatim_piatu']?.toString() ?? '', flex: 3, bottomBorder: true, noRightBorder: true),
                    ],
                  );
                }),
                if (data.isEmpty)
                  pw.TableRow(
                    children: [
                      buildCell('Tidak ada data', flex: 21, bottomBorder: true, noRightBorder: true),
                    ],
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

  final profilPenduduk = '''
  Future<Uint8List> generateProfilPendudukPdf({
    required String namaKelompok,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
    required String provinsi,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

\${buildCellFunc}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'PROFIL PENDUDUK',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Kelompok Dasawisma: \$namaKelompok', style: pw.TextStyle(font: fontBold)),
            pw.Text('RT/RW: \$rt/\$rw', style: pw.TextStyle(font: font)),
            pw.Text('Kelurahan/Desa: \$desa', style: pw.TextStyle(font: font)),
            pw.Text('Kecamatan: \$kecamatan', style: pw.TextStyle(font: font)),
            pw.Text('Kabupaten/Kota: \$kabupaten', style: pw.TextStyle(font: font)),
            pw.Text('Provinsi: \$provinsi', style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    buildCell('No', flex: 1, isHeader: true),
                    buildCell('Nama Lengkap', flex: 4, isHeader: true),
                    buildCell('NIK', flex: 3, isHeader: true),
                    buildCell('Jenis Kelamin', flex: 3, isHeader: true),
                    buildCell('Tempat Lahir', flex: 3, isHeader: true),
                    buildCell('Tanggal Lahir', flex: 3, isHeader: true),
                    buildCell('Agama', flex: 2, isHeader: true),
                    buildCell('Pendidikan', flex: 3, isHeader: true),
                    buildCell('Pekerjaan', flex: 3, isHeader: true, noRightBorder: true),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      buildCell(index.toString(), flex: 1, bottomBorder: true),
                      buildCell(item['nama_orang']?.toString() ?? '', flex: 4, bottomBorder: true),
                      buildCell(item['nik']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['jk']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['tempat_lahir']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['tgl_lahir']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['agama']?.toString() ?? '', flex: 2, bottomBorder: true),
                      buildCell(item['pendidikan']?.toString() ?? '', flex: 3, bottomBorder: true),
                      buildCell(item['pekerjaan']?.toString() ?? '', flex: 3, bottomBorder: true, noRightBorder: true),
                    ],
                  );
                }),
                if (data.isEmpty)
                  pw.TableRow(
                    children: [
                      buildCell('Tidak ada data', flex: 25, bottomBorder: true, noRightBorder: true),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
'$content\\n$yatimPiatu\\n$profilPenduduk\\n}\\n\\nfinal pdfReportServiceProvider = Provider<PdfReportService>((ref) {\\n  return PdfReportService();\\n});\\n'vice>((ref) {\\n  return PdfReportService();\\n});\\n';
  content = content.replaceAll('\\\\n', '\\n');
  await file.writeAsString(content);
}
