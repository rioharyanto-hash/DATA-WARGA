import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/presentation/providers/report_provider.dart');
  String content = await file.readAsString();

  // 1. Add globalIndex and dasawismaList
  final target1 = """      List<Map<String, dynamic>> ringkasanRows = [];

      for (var name in allowedNames) {""";
  final replace1 = """      List<Map<String, dynamic>> ringkasanRows = [];
      int globalIndex = 1;
      List<String> dasawismaList = [];

      for (var name in allowedNames) {""";
  content = content.replaceFirst(target1, replace1);

  // 2. Add 'no' to rowMap and collect dasawismaList
  final target2 = """        if (dMatch != null) {
          if (pkkRt == '...' || pkkRt == 'Semua') {
            rtFromName = dMatch.group(1)!;
          }
          dasawismaFromName = dMatch.group(2)!;
        }

        final rowMap = <String, dynamic>{
          'namaWarga': name,
          'nomor_rt': rtFromName,
          'jumlah_dasawisma': dasawismaFromName,""";
  final replace2 = """        if (dMatch != null) {
          if (pkkRt == '...' || pkkRt == 'Semua') {
            rtFromName = dMatch.group(1)!;
          }
          dasawismaFromName = dMatch.group(2)!;
          if (!dasawismaList.contains(dasawismaFromName)) {
            dasawismaList.add(dasawismaFromName);
          }
        }

        final rowMap = <String, dynamic>{
          'no': globalIndex++,
          'namaWarga': name,
          'nomor_rt': rtFromName,
          'jumlah_dasawisma': dasawismaFromName,""";
  content = content.replaceFirst(target2, replace2);

  // 3. Update kelompokName in ringkasanData
  // Note: the original 'kelompokName' is missing in ringkasanData for Potensi Warga Ringkasan!
  final target3 = """      final ringkasanData = {
        'rows': ringkasanRows,
        'rt': pkkRt,
        'rw': pkkRw,
        'kelurahan': region.kelurahan,
        'kecamatan': region.kecamatan,""";
  final replace3 = """      final ringkasanData = {
        'rows': ringkasanRows,
        'kelompok': dasawismaList.isNotEmpty 
            ? 'BUAH GOWOK.\$pkkRw.\$pkkRt. \${dasawismaList.join(', ')}' 
            : 'BUAH GOWOK.\$pkkRw.\$pkkRt',
        'rt': pkkRt,
        'rw': pkkRw,
        'kelurahan': region.kelurahan,
        'kecamatan': region.kecamatan,""";
  content = content.replaceFirst(target3, replace3);

  await file.writeAsString(content);
  print("Updated report_provider.dart");
}
