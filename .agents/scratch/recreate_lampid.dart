import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String content = await file.readAsString();

  final startBlank = content.indexOf(
    'Future<Uint8List> generateBlankFormIbuHamil() async {',
  );
  final endBlank = content.indexOf('Future<Uint8List> generateForm1({');
  final blankContent = content.substring(startBlank, endBlank);

  // We are going to replace the generateLampidPdf at the end of the file
  final startIdx = content.indexOf(
    '      Future<Uint8List> generateLampidPdf({',
  );

  if (startIdx != -1) {
    // Generate the new Lampid PDF from the blank form
    String newLampid = blankContent.replaceFirst(
      'Future<Uint8List> generateBlankFormIbuHamil() async {',
      'Future<Uint8List> generateLampidPdf({required String namaKelompok, required List<Map<String, dynamic>> mutasiList}) async {',
    );

    // Change title
    newLampid = newLampid.replaceAll(
      "'FORMULIR DATA IBU HAMIL, MELAHIRKAN, NIFAS, IBU MENINGGAL, KELAHIRAN BAYI, BAYI MENINGGAL DAN KEMATIAN BALITA'",
      "'LAPORAN LAMPID (LAHIR, MATI, PINDAH, DATANG)'",
    );

    // Change header table
    newLampid = newLampid.replaceAll(
      '''
                      buildCell('No', flex: 1, isHeader: true),
                      buildCell('Nama Ibu', flex: 4, isHeader: true),
                      buildCell('Status Kehamilan (Hamil/Melahirkan/Nifas)', flex: 4, isHeader: true),
                      buildCell('Nama Suami', flex: 4, isHeader: true),
                      buildCell('Status Kematian Ibu (Meninggal/Tidak)', flex: 3, isHeader: true),
                      buildCell('Nama Bayi', flex: 4, isHeader: true),
                      buildCell('Jenis Kelamin Bayi', flex: 3, isHeader: true),
                      buildCell('Tanggal Lahir Bayi', flex: 3, isHeader: true),
                      buildCell('Akte Kelahiran (Ada/Tidak)', flex: 2, isHeader: true),
                      buildCell('Status Kematian Bayi (Meninggal/Tidak)', flex: 3, isHeader: true),
                      buildCell('Keterangan', flex: 3, isHeader: true, noRightBorder: true),
''',
      '''
                      buildCell('No', flex: 1, isHeader: true),
                      buildCell('Tanggal', flex: 3, isHeader: true),
                      buildCell('Nama', flex: 4, isHeader: true),
                      buildCell('NIK', flex: 3, isHeader: true),
                      buildCell('Jenis Mutasi', flex: 3, isHeader: true),
                      buildCell('Asal/Tujuan', flex: 4, isHeader: true),
                      buildCell('Sebab/Status Ibu', flex: 3, isHeader: true),
                      buildCell('Keterangan', flex: 4, isHeader: true, noRightBorder: true),
''',
    );

    // Change rows
    final oldRows = '''
                  for (int i = 1; i <= 20; i++)
                    pw.TableRow(
                      children: [
                        buildCell(i.toString(), flex: 1, bottomBorder: true),
                        buildCell('', flex: 4, bottomBorder: true),
                        buildCell('', flex: 4, bottomBorder: true),
                        buildCell('', flex: 4, bottomBorder: true),
                        buildCell('', flex: 3, bottomBorder: true),
                        buildCell('', flex: 4, bottomBorder: true),
                        buildCell('', flex: 3, bottomBorder: true),
                        buildCell('', flex: 3, bottomBorder: true),
                        buildCell('', flex: 2, bottomBorder: true),
                        buildCell('', flex: 3, bottomBorder: true),
                        buildCell('', flex: 3, bottomBorder: true, noRightBorder: true),
                      ],
                    ),
''';
    final newRows = '''
                  ...mutasiList.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final mutasi = entry.value;
                    return pw.TableRow(
                      children: [
                        buildCell(index.toString(), flex: 1, bottomBorder: true),
                        buildCell(mutasi['tanggal_mutasi']?.toString() ?? '', flex: 3, bottomBorder: true),
                        buildCell(mutasi['nama_orang']?.toString() ?? '', flex: 4, bottomBorder: true),
                        buildCell(mutasi['nik']?.toString() ?? '-', flex: 3, bottomBorder: true),
                        buildCell(mutasi['jenis_mutasi']?.toString() ?? '', flex: 3, bottomBorder: true),
                        buildCell(mutasi['jenis_mutasi'] == 'Pindah' || mutasi['jenis_mutasi'] == 'Datang' ? ((mutasi['jenis_mutasi'] == 'Pindah' ? mutasi['tujuan'] : mutasi['asal']) ?? '-') : '-', flex: 4, bottomBorder: true),
                        buildCell(mutasi['jenis_mutasi'] == 'Meninggal' ? (mutasi['sebab_kematian'] ?? '-') : (mutasi['jenis_mutasi'] == 'Lahir' || mutasi['jenis_mutasi'] == 'Status Ibu (Hamil/Nifas)' ? (mutasi['status_ibu'] ?? '-') : '-'), flex: 3, bottomBorder: true),
                        buildCell(mutasi['keterangan']?.toString() ?? '-', flex: 4, bottomBorder: true, noRightBorder: true),
                      ],
                    );
                  }),
                  if (mutasiList.isEmpty)
                    pw.TableRow(
                      children: [
                        buildCell('Tidak ada data mutasi', flex: 25, bottomBorder: true, noRightBorder: true),
                      ],
                    ),
''';
    newLampid = newLampid.replaceAll(oldRows, newRows);

    // Make sure we have proper spacing
    newLampid = "  ${newLampid.trim()}\n";

    // Also remove any remaining stretch
    newLampid = newLampid.replaceAll(
      'crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
      'crossAxisAlignment: pw.CrossAxisAlignment.center,',
    );

    // Keep Column stretch
    newLampid = newLampid.replaceAll(
      'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.center,',
      'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    );

    content =
        '${content.substring(0, startIdx)}$newLampid}\n\nfinal pdfReportServiceProvider = Provider<PdfReportService>((ref) {\n  return PdfReportService();\n});\n';
    await file.writeAsString(content);
    print('Successfully re-created generateLampidPdf!');
  } else {
    print('Failed to find startIdx');
  }
}
