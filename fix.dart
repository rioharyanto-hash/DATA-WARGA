import 'dart:io';

void main() {
  final file = File(
    r'E:\Project\DAWIS\lib\src\features\report\presentation\providers\report_provider.dart',
  );
  var content = file.readAsStringSync();

  // Fix 1: generateProfilPendudukRingkasanPdf
  content = content.replaceFirst(
    "final pdfBytes = await pdfService.generateProfilKependudukan(\n        data: ringkasanData,\n        kelompokName: ringkasanData['kelompokName'] as String,\n        rt: pkkRt,\n        rw: pkkRw,\n        desa: region.kelurahan,\n        kecamatan: region.kecamatan,\n        kabupaten: region.kotaKab,\n        provinsi: 'DKI Jakarta',\n      );",
    "final pdfBytes = await pdfService.generateProfilPendudukPdf(\n        data: ringkasanRows,\n        namaKelompok: ringkasanData['kelompokName'] as String,\n        rt: pkkRt,\n        rw: pkkRw,\n        desa: region.kelurahan,\n        kecamatan: region.kecamatan,\n        kabupaten: region.kotaKab,\n        provinsi: 'DKI Jakarta',\n      );",
  );

  // Fix 2: generatePotensiWargaRingkasanPdf data parsing
  content = content.replaceFirst(
    "for (var name in allowedNames) {\n        final data = await repo.getPotensiWargaData(name);\n        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;\n        \n        final Map<String, int> sums = {};\n        for (var r in data['rows']) {",
    "for (var name in allowedNames) {\n        final dataList = await repo.getPotensiWargaData(name);\n        if (dataList.isEmpty) continue;\n        \n        final Map<String, int> sums = {};\n        for (var r in dataList) {",
  );

  // Fix 3: generatePotensiWargaRingkasanPdf pdfService call
  content = content.replaceFirst(
    "final pdfBytes = await pdfService.generateFormDataPotensiWarga(\n        data: ringkasanData,\n        kelompokName: kelompokNameStr,\n        rt: pkkRt,\n        rw: pkkRw,\n        kelurahan: region.kelurahan,\n        kecamatan: region.kecamatan,\n        kabupaten: region.kotaKab,\n        provinsi: 'DKI Jakarta',\n        tahun: DateTime.now().year.toString(),\n        bulan: ref.read(reportBulanProvider),\n      );",
    "final pdfBytes = await pdfService.generateFormDataPotensiWarga(\n        data: ringkasanRows,\n        kelompokName: kelompokNameStr,\n        pkkRw: pkkRw,\n        dusun: pkkRt,\n        desa: region.kelurahan,\n        tahun: DateTime.now().year.toString(),\n        periode: ref.read(reportBulanProvider),\n      );",
  );

  // Fix 4: generateLampidRingkasanPdf pdfService call
  content = content.replaceFirst(
    "final pdfBytes = await pdfService.generateFormIbuHamil(\n        data: ringkasanData,\n        kelompokName: 'Semua Kelompok RT $pkkRt RW $pkkRw',\n        rt: pkkRt,\n        rw: pkkRw,\n        kelurahan: region.kelurahan,\n        kecamatan: region.kecamatan,\n        kabupaten: region.kotaKab,\n        provinsi: 'DKI Jakarta',\n        tahun: DateTime.now().year.toString(),\n        bulan: ref.read(reportBulanProvider),\n      );",
    "final pdfBytes = await pdfService.generateLampidPdf(\n        mutasiList: ringkasanRows,\n        namaKelompok: 'Semua Kelompok RT $pkkRt RW $pkkRw',\n        rt: pkkRt,\n        rw: pkkRw,\n        kelurahan: region.kelurahan,\n        tahun: DateTime.now().year.toString(),\n        bulan: ref.read(reportBulanProvider),\n      );",
  );

  file.writeAsStringSync(content);
  print('Successfully patched report_provider.dart');
}
