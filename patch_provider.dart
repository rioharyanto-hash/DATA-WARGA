import 'dart:io';

void main() {
  final fileProv = File('lib/src/features/report/presentation/providers/report_provider.dart');
  var contentProv = fileProv.readAsStringSync();
  
  // Fix 1: generateProfilUsiaRingkasanPortraitPdf
  contentProv = contentProv.replaceFirst(
    "final pdfBytes = await pdfService.generateProfilUsiaRingkasanPortraitPdf(\n          perKelompokData: perKelompokTotals,\n          namaKelompok: namaKaderList.isNotEmpty\n              ? namaKaderList.join(', ')\n              : 'Semua Kelompok RT \ RW \',",
    "final pdfBytes = await pdfService.generateProfilUsiaRingkasanPortraitPdf(\n          perKelompokData: perKelompokTotals,\n          namaKelompok: allowedNames.isNotEmpty ? allowedNames.join(', ') : 'Semua Kelompok RT \ RW \',\n          namaKader: namaKaderList.isNotEmpty ? namaKaderList.join(', ') : '',"
  );

  // Fix 2: generateFormDataPotensiWarga
  contentProv = contentProv.replaceFirst(
    "final pdfBytes = await pdfService.generateFormDataPotensiWarga(\n        data: data,",
    "final pdfBytes = await pdfService.generatePotensiWargaPdf(\n        data: {'rows': data},"
  );

  contentProv = contentProv.replaceFirst(
    "final pdfBytes = await pdfService.generateFormDataPotensiWarga(\n          data: ringkasanRows,",
    "final pdfBytes = await pdfService.generatePotensiWargaPdf(\n          data: {'rows': ringkasanRows},"
  );
  
  fileProv.writeAsStringSync(contentProv);
  print('Provider patch applied!');
}
