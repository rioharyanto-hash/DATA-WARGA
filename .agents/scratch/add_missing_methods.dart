import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String content = await file.readAsString();

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
                    _buildCell('No', fontBold, align: pw.TextAlign.center),
                    _buildCell('Nama', fontBold, align: pw.TextAlign.center),
                    _buildCell('NIK', fontBold, align: pw.TextAlign.center),
                    _buildCell('Umur', fontBold, align: pw.TextAlign.center),
                    _buildCell('L/P', fontBold, align: pw.TextAlign.center),
                    _buildCell('Alamat', fontBold, align: pw.TextAlign.center),
                    _buildCell('Nama Wali', fontBold, align: pw.TextAlign.center),
                    _buildCell('Status Yatim Piatu', fontBold, align: pw.TextAlign.center),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      _buildCell(index.toString(), font, align: pw.TextAlign.center),
                      _buildCell(item['nama_orang']?.toString() ?? '', font),
                      _buildCell(item['nik']?.toString() ?? '', font),
                      _buildCell(item['umur']?.toString() ?? '', font, align: pw.TextAlign.center),
                      _buildCell(item['jk'] == 'Laki-laki' ? 'L' : (item['jk'] == 'Perempuan' ? 'P' : ''), font, align: pw.TextAlign.center),
                      _buildCell(item['alamat']?.toString() ?? '', font),
                      _buildCell(item['nama_wali']?.toString() ?? '', font),
                      _buildCell(item['status_yatim_piatu']?.toString() ?? '', font, align: pw.TextAlign.center),
                    ],
                  );
                }),
                if (data.isEmpty)
                  pw.TableRow(
                    children: [
                      _buildCell('Tidak ada data', font, align: pw.TextAlign.center),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
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
                    _buildCell('No', fontBold, align: pw.TextAlign.center),
                    _buildCell('Nama Lengkap', fontBold, align: pw.TextAlign.center),
                    _buildCell('NIK', fontBold, align: pw.TextAlign.center),
                    _buildCell('Jenis Kelamin', fontBold, align: pw.TextAlign.center),
                    _buildCell('Tempat Lahir', fontBold, align: pw.TextAlign.center),
                    _buildCell('Tanggal Lahir', fontBold, align: pw.TextAlign.center),
                    _buildCell('Agama', fontBold, align: pw.TextAlign.center),
                    _buildCell('Pendidikan', fontBold, align: pw.TextAlign.center),
                    _buildCell('Pekerjaan', fontBold, align: pw.TextAlign.center),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      _buildCell(index.toString(), font, align: pw.TextAlign.center),
                      _buildCell(item['nama_orang']?.toString() ?? '', font),
                      _buildCell(item['nik']?.toString() ?? '', font),
                      _buildCell(item['jk']?.toString() ?? '', font, align: pw.TextAlign.center),
                      _buildCell(item['tempat_lahir']?.toString() ?? '', font),
                      _buildCell(item['tgl_lahir']?.toString() ?? '', font, align: pw.TextAlign.center),
                      _buildCell(item['agama']?.toString() ?? '', font),
                      _buildCell(item['pendidikan']?.toString() ?? '', font),
                      _buildCell(item['pekerjaan']?.toString() ?? '', font),
                    ],
                  );
                }),
                if (data.isEmpty)
                  pw.TableRow(
                    children: [
                      _buildCell('Tidak ada data', font, align: pw.TextAlign.center),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
                      _buildCell('', font),
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

  final classEndIdx = content.lastIndexOf('}');

  // We want to insert the methods before the very last `}` which should be the end of the class (if we ignore the provider).
  // Wait, there is `final pdfReportServiceProvider = Provider...` at the end of the file.
  // We need to insert before that.
  final endClass = content.indexOf('final pdfReportServiceProvider =');
  if (endClass != -1) {
    final lastBraceBeforeEndClass = content
        .substring(0, endClass)
        .lastIndexOf('}');
    if (lastBraceBeforeEndClass != -'${content.substring(0, lastBraceBeforeEndClass)}\\n$yatimPiatu\\n$profilPenduduk\\n}\\n\\n${content.substring(endClass)}' '\\n}\\n\\n' +
          content.substring(endClass) {
       {}
    }
      await file.writeAsString(content);
      print('Successfully added methods!');
    }
  }
}
