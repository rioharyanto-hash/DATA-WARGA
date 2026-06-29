import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\presentation\providers\report_provider.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  // Patch generateProfilPendudukPdf
  final oldGenProfil = '''
      final pdfBytes = await pdfService.generateProfilPendudukPdf(
        namaKelompok: namaKelompok,
        rt: data['rt']?.toString() ?? '',
        rw: data['rw']?.toString() ?? '',
        provinsi: 'DKI JAKARTA',
        data:
            (data['keluargaList'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        desa: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
      );
''';
  final newGenProfil = '''
      final pdfBytes = await pdfService.generateProfilUsiaPdf(
        namaKelompok: namaKelompok,
        rt: data['rt']?.toString() ?? '',
        rw: data['rw']?.toString() ?? '',
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kota: region.kotaKab,
        data: (data['keluargaList'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      );
''';
  if (content.contains(oldGenProfil)) {
    content = content.replaceFirst(oldGenProfil, newGenProfil);
  } else {
    print('Failed to find oldGenProfil block');
  }

  // Patch generateProfilPendudukRingkasanPdf
  final oldRingkasan = '''
      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      for (var name in allowedNames) {
        final data = await repo.getProfilPendudukData(name);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;

        final Map<String, int> sums = {};
        for (var r in data['rows']) {
          for (var key in r.keys) {
            if (key != 'namaKeluarga') {
              sums[key] = (sums[key] ?? 0) + (r[key] as int? ?? 0);
            }
          }
        }

        sums['namaKeluarga'] = 0;
        final rowMap = <String, dynamic>{'namaKeluarga': name};
        rowMap.addAll(sums);
        ringkasanRows.add(rowMap);
      }

      final ringkasanData = {
        'kelompokName': 'Semua Kelompok RT \$pkkRt RW \$pkkRw',
        'namaKordinator': allowedNames.join(', '),
        'rows': ringkasanRows,
      };

      final pdfBytes = await pdfService.generateProfilUsiaRingkasanPdf(
        data: ringkasanRows,
        namaKelompok: ringkasanData['kelompokName'] as String,
        rt: pkkRt,
        rw: pkkRw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kota: region.kotaKab,
      );
''';

  final newRingkasan = '''
      final allowedNames = await _getFilteredKelompokNames();
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      final Map<String, int> totalSums = {};
      for (var name in allowedNames) {
        final data = await repo.getProfilPendudukData(name);
        final keluargaList = (data['keluargaList'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (keluargaList.isEmpty) continue;

        for (var r in keluargaList) {
          for (var key in r.keys) {
            if (key != 'namaKeluarga') {
              totalSums[key] = (totalSums[key] ?? 0) + (r[key] as int? ?? 0);
            }
          }
        }
      }

      final pdfBytes = await pdfService.generateProfilUsiaRingkasanPortraitPdf(
        data: totalSums,
        namaKelompok: 'Semua Kelompok RT \$pkkRt RW \$pkkRw',
        rt: pkkRt,
        rw: pkkRw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kota: region.kotaKab,
      );
''';
  if (content.contains(oldRingkasan)) {
    content = content.replaceFirst(oldRingkasan, newRingkasan);
  } else {
    print('Failed to find oldRingkasan block');
  }

  file.writeAsStringSync(content);
  print('Done patching report provider');
}
