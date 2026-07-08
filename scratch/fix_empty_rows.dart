import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  final regex = RegExp(r"final dasawisma = r\['jumlah_dasawisma'\] as int\? \?\? 1;");
  
  final replacement = """final isRowEmpty = r.isEmpty || r['namaWarga'] == null || r['namaWarga'].toString().isEmpty;
            final dasawismaStr = r['jumlah_dasawisma']?.toString() ?? '1';
            final bangunan = r['jumlah_bangunan'] as int? ?? 0;
            final kelompokVal = r['jumlah_kelompok'] as int? ?? 1;""";
  
  if (content.contains("final dasawisma = r['jumlah_dasawisma'] as int? ?? 1;")) {
    content = content.replaceFirst(
      "final dasawisma = r['jumlah_dasawisma'] as int? ?? 1;\n            final bangunan = r['jumlah_bangunan'] as int? ?? 0;\n            final kelompokVal = r['jumlah_kelompok'] as int? ?? 1;",
      replacement
    );
  } else {
    print("Could not find dasawisma cast");
  }

  final accTarget = """            tDasawisma += dasawisma;
            tBangunan += bangunan;
            tKelompok += kelompokVal;""";
  final accReplace = """            if (!isRowEmpty) {
              tDasawisma += 1; // Count 1 Dasawisma per row
              tBangunan += bangunan;
              tKelompok += kelompokVal;
            }""";
  content = content.replaceFirst(accTarget, accReplace);

  final valuesTarget = """            final values = [
              '\${r['no']}',
              '\${r['nomor_rt'] ?? ''}',
              '\$dasawisma',
              '\$bangunan',
              '\$kelompokVal',
              '\$krt',
              '\$kk',
              '\$l',
              '\$p',
              '\$balitaL',
              '\$balitaP',
              '\$balitaAktifL',
              '\$balitaAktifP',
              '\$pus',
              '\$tidakKb',
              '\$kbPil',
              '\$kbIud',
              '\$kbImplan',
              '\$kbSuntik',
              '\$kbKondom',
              '\$kbSteril',
              '\$kbLainnya',
              '\$remajaL',
              '\$remajaP',
              '\$remajaAktifL',
              '\$remajaAktifP',
              '\$lansiaL',
              '\$lansiaP',
              '\$lansiaAktifL',
              '\$lansiaAktifP',
              '\$berkebutuhanL',
              '\$berkebutuhanP',
              '',
            ];""";
  final valuesReplace = """            final values = isRowEmpty ? [
              '\${r['no']}',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', ''
            ] : [
              '\${r['no']}',
              '\${r['nomor_rt'] ?? ''}',
              dasawismaStr,
              '\$bangunan',
              '\$kelompokVal',
              '\$krt',
              '\$kk',
              '\$l',
              '\$p',
              '\$balitaL',
              '\$balitaP',
              '\$balitaAktifL',
              '\$balitaAktifP',
              '\$pus',
              '\$tidakKb',
              '\$kbPil',
              '\$kbIud',
              '\$kbImplan',
              '\$kbSuntik',
              '\$kbKondom',
              '\$kbSteril',
              '\$kbLainnya',
              '\$remajaL',
              '\$remajaP',
              '\$remajaAktifL',
              '\$remajaAktifP',
              '\$lansiaL',
              '\$lansiaP',
              '\$lansiaAktifL',
              '\$lansiaAktifP',
              '\$berkebutuhanL',
              '\$berkebutuhanP',
              '',
            ];""";
  content = content.replaceFirst(valuesTarget, valuesReplace);

  await file.writeAsString(content);
  print("Modifications applied successfully");
}
