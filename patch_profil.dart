import 'dart:io';

void main() {
  final filePdf = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var contentPdf = filePdf.readAsStringSync();

  // Fix generateProfilUsiaRingkasanPortraitPdf
  contentPdf = contentPdf.replaceFirst(
    'Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf({\n      required List<Map<String, int>> perKelompokData,\n      required String namaKelompok,\n      required String rt,',
    'Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf({\n      required List<Map<String, int>> perKelompokData,\n      required String namaKelompok,\n      required String namaKader,\n      required String rt,'
  );

  contentPdf = contentPdf.replaceFirst(
    "pw.Text(\n                            ': \',",
    "pw.Text(\n                            ': \',"
  );
  
  contentPdf = contentPdf.replaceFirst(
    "pw.Text(\n                            ': ',\n                            style: pw.TextStyle(\n                              font: regularFont,\n                              fontSize: 10,\n                            ),\n                          ),",
    "pw.Text(\n                            ': \',\n                            style: pw.TextStyle(\n                              font: regularFont,\n                              fontSize: 10,\n                            ),\n                          ),"
  );
  
  // Fix column widths P and W
  contentPdf = contentPdf.replaceFirst("buildCell(\n                        'UMUR',\n                        flex: 2,", "buildCell(\n                        'UMUR',\n                        flex: 4,");
  contentPdf = contentPdf.replaceFirst("buildCell(\n                        'P',\n                        flex: 3,", "buildCell(\n                        'P',\n                        flex: 2,");
  contentPdf = contentPdf.replaceFirst("buildCell(\n                        'W',\n                        flex: 3,", "buildCell(\n                        'W',\n                        flex: 2,");

  contentPdf = contentPdf.replaceFirst("buildCell(ageGroups[i], flex: 2,", "buildCell(ageGroups[i], flex: 4,");
  contentPdf = contentPdf.replaceFirst("buildCell(pBreakdown, flex: 3,", "buildCell(pBreakdown, flex: 2,");
  contentPdf = contentPdf.replaceFirst("buildCell(\n                          wBreakdown,\n                          flex: 3,", "buildCell(\n                          wBreakdown,\n                          flex: 2,");

  contentPdf = contentPdf.replaceFirst("buildCell(\n                        'TOTAL',\n                        flex: 2,", "buildCell(\n                        'TOTAL',\n                        flex: 4,");
  contentPdf = contentPdf.replaceFirst("buildCell(\n                        buildBreakdown(perKelompokData, 'total_P'),\n                        flex: 3,", "buildCell(\n                        buildBreakdown(perKelompokData, 'total_P'),\n                        flex: 2,");
  contentPdf = contentPdf.replaceFirst("buildCell(\n                        buildBreakdown(perKelompokData, 'total_W'),\n                        flex: 3,", "buildCell(\n                        buildBreakdown(perKelompokData, 'total_W'),\n                        flex: 2,");

  filePdf.writeAsStringSync(contentPdf);

  final fileProv = File('lib/src/features/report/presentation/providers/report_provider.dart');
  var contentProv = fileProv.readAsStringSync();
  
  contentProv = contentProv.replaceFirst(
    "perKelompokData: perKelompokTotals,\n          namaKelompok: namaKaderList.isNotEmpty\n              ? namaKaderList.join(', ')\n              : 'Semua Kelompok RT \ RW \',",
    "perKelompokData: perKelompokTotals,\n          namaKelompok: allowedNames.isNotEmpty ? allowedNames.join(', ') : 'Semua Kelompok RT \ RW \',\n          namaKader: namaKaderList.isNotEmpty ? namaKaderList.join(', ') : '',"
  );
  
  fileProv.writeAsStringSync(contentProv);
  print('Profil patch applied!');
}
