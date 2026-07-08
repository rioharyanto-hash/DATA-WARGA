import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/presentation/providers/report_provider.dart');
  String content = await file.readAsString();

  final targetBlock = """      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      int globalIndex = 1;

      for (var name in allowedNames) {
        final dataList = await repo.getLampidData(name);""";

  final replacementBlock = """      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      int globalIndex = 1;
      List<String> dasawismaList = [];

      for (var name in allowedNames) {
        final parts = name.split(' ');
        if (parts.isNotEmpty) {
          final noUrutStr = parts.last;
          if (!dasawismaList.contains(noUrutStr)) {
            dasawismaList.add(noUrutStr);
          }
        }

        final dataList = await repo.getLampidData(name);""";

  if (content.contains(targetBlock)) {
    content = content.replaceFirst(targetBlock, replacementBlock);
  } else {
    print("Could not find target block 1.");
  }

  final targetPdfBlock = """      final pdfBytes = await pdfService.generateLampidPdfRingkasan(
        mutasiList: ringkasanRows,
        namaKelompok:
            'Semua Kelompok RT \${rt == 'Semua' ? '...' : rt} RW \${rw == 'Semua' ? '...' : rw}',""";
            
  final replacementPdfBlock = """      final rwStr = rw == 'Semua' ? '...' : rw;
      final rtStr = rt == 'Semua' ? '...' : rt;
      final pdfBytes = await pdfService.generateLampidPdfRingkasan(
        mutasiList: ringkasanRows,
        namaKelompok: dasawismaList.isNotEmpty
            ? 'BUAH GOWOK \$rwStr.\$rtStr.\${dasawismaList.join(',')}'
            : 'BUAH GOWOK \$rwStr.\$rtStr',""";

  if (content.contains(targetPdfBlock)) {
    content = content.replaceFirst(targetPdfBlock, replacementPdfBlock);
  } else {
    print("Could not find target block 2.");
  }

  await file.writeAsString(content);
  print("Updated Lampid PDF header in report_provider.dart.");
}
