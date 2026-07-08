import 'dart:io';

void main() async {
  final perincianFile = File('lib/src/features/report/data/services/pdf_perincian_service.dart');
  final perincian = await perincianFile.readAsString();

  final regex = RegExp(r'Future<Uint8List> generatePotensiWargaPdfPerincian\(\{(.*?)\n  Future<Uint8List> generateProfilPendudukPdf', dotAll: true);
  final match = regex.firstMatch(perincian);
  
  if (match == null) {
    print("Could not find generatePotensiWargaPdfPerincian");
    exit(1);
  }

  String funcBody = "Future<Uint8List> generatePotensiWargaPdfRingkasan({" + match.group(1)!;

  funcBody = funcBody.replaceAll(
    "'DATA POTENSI WARGA (TERISI)'",
    "'DATA POTENSI WARGA\\nKELOMPOK PKK RW'"
  );

  final headerTarget = """          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
          buildCell('NAMA\\nBANGUNAN', flex: 4, isHeader: true, fontSize: 5),
          buildCell('JML\\nKRT', flex: 1, isHeader: true, fontSize: 5),
          buildCell('JML\\nKK', flex: 1, isHeader: true, fontSize: 5),
          // TOTAL (L, P)""";

  final headerReplace = """          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
          buildCell('NOMOR RT', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nDASAWISMA', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nBANGUNAN', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JUMLAH\\nKELOMPOK', flex: 2, isHeader: true, fontSize: 5),
          buildCell('JML\\nKRT', flex: 1, isHeader: true, fontSize: 5),
          buildCell('JML\\nKK', flex: 1, isHeader: true, fontSize: 5),
          // TOTAL (L, P)""";

  funcBody = funcBody.replaceAll(headerTarget, headerReplace);

  final rowTarget = """                      buildCell((i + 1).toString(), flex: 1, fontSize: 5),
                      buildCell(potensi['namaWarga']?.toString() ?? '', flex: 4, alignment: pw.Alignment.centerLeft, fontSize: 5),
                      buildCell(potensi['jumlah_krt']?.toString() ?? '', flex: 1, fontSize: 5),
                      buildCell(potensi['jumlah_kk']?.toString() ?? '', flex: 1, fontSize: 5),
                      // TOTAL""";

  final rowReplace = """                      buildCell((i + 1).toString(), flex: 1, fontSize: 5),
                      buildCell(potensi['nomor_rt']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_dasawisma']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_bangunan']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_kelompok']?.toString() ?? '', flex: 2, fontSize: 5),
                      buildCell(potensi['jumlah_krt']?.toString() ?? '', flex: 1, fontSize: 5),
                      buildCell(potensi['jumlah_kk']?.toString() ?? '', flex: 1, fontSize: 5),
                      // TOTAL""";

  funcBody = funcBody.replaceAll(rowTarget, rowReplace);

  final totalTarget = """                      buildCell('JUMLAH', flex: 5, isHeader: true, fontSize: 5),
                      buildCell(totalKrt.toString(), flex: 1, isHeader: true, fontSize: 5),
                      buildCell(totalKk.toString(), flex: 1, isHeader: true, fontSize: 5),
                      // TOTAL""";

  final totalReplace = """                      buildCell('JUMLAH', flex: 3, isHeader: true, fontSize: 5),
                      buildCell(totalDasawisma.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalBangunan.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalKelompok.toString(), flex: 2, isHeader: true, fontSize: 5),
                      buildCell(totalKrt.toString(), flex: 1, isHeader: true, fontSize: 5),
                      buildCell(totalKk.toString(), flex: 1, isHeader: true, fontSize: 5),
                      // TOTAL""";

  funcBody = funcBody.replaceAll(totalTarget, totalReplace);

  final totalsTarget = """      int totalKrt = 0;
      int totalKk = 0;
      int totalTotalL = 0;""";

  final totalsReplace = """      int totalDasawisma = 0;
      int totalBangunan = 0;
      int totalKelompok = 0;
      int totalKrt = 0;
      int totalKk = 0;
      int totalTotalL = 0;""";

  funcBody = funcBody.replaceAll(totalsTarget, totalsReplace);

  final totalsCalcTarget = """        totalKrt += int.tryParse(potensi['jumlah_krt']?.toString() ?? '0') ?? 0;
        totalKk += int.tryParse(potensi['jumlah_kk']?.toString() ?? '0') ?? 0;
        totalTotalL += int.tryParse(potensi['total_L']?.toString() ?? '0') ?? 0;""";

  final totalsCalcReplace = """        totalDasawisma += int.tryParse(potensi['jumlah_dasawisma']?.toString() ?? '0') ?? 0;
        totalBangunan += int.tryParse(potensi['jumlah_bangunan']?.toString() ?? '0') ?? 0;
        totalKelompok += int.tryParse(potensi['jumlah_kelompok']?.toString() ?? '0') ?? 0;
        totalKrt += int.tryParse(potensi['jumlah_krt']?.toString() ?? '0') ?? 0;
        totalKk += int.tryParse(potensi['jumlah_kk']?.toString() ?? '0') ?? 0;
        totalTotalL += int.tryParse(potensi['total_L']?.toString() ?? '0') ?? 0;""";

  funcBody = funcBody.replaceAll(totalsCalcTarget, totalsCalcReplace);

  final headerInfoTarget = """            pw.Text('DATA POTENSI WARGA (TERISI)',
                style: pw.TextStyle(font: boldFont, fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RT', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('RW', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Kelurahan', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Kecamatan', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Tahun', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 7,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(': \${data['rt'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': \${data['rw'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': \${data['kelurahan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': \${data['kecamatan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(': \${data['tahun'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),""";

  final headerInfoReplace = """            pw.Text('DATA POTENSI WARGA\\nKELOMPOK PKK RW',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: boldFont, fontSize: 8)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RW', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('DUSUN / LINGKUNGAN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('DESA / KELURAHAN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('TAHUN', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text('PERIODE', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ],
                ),
                pw.SizedBox(width: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(': \${data['rw'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': -', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': \${data['kelurahan']?.toString().toUpperCase() ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': \${data['tahun'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(': \${data['periode'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),""";

  funcBody = funcBody.replaceAll(headerInfoTarget, headerInfoReplace);

  final ringkasanFile = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  final ringkasan = await ringkasanFile.readAsString();

  // Find what follows generatePotensiWargaPdfRingkasan in pdf_ringkasan_service.dart
  // Wait, I searched earlier: `Future<Uint8List> generateLampidRingkasanPdf` maybe? Or let's just use `generateCatatan`
  final regexOld = RegExp(r'Future<Uint8List> generatePotensiWargaPdfRingkasan\(\{(.*?)\n  Future<Uint8List> (generateProfilPendudukRingkasanPdf|generateLampidRingkasanPdf)', dotAll: true);
  var matchOld = regexOld.firstMatch(ringkasan);
  
  if (matchOld == null) {
      final regexOldFallback = RegExp(r'Future<Uint8List> generatePotensiWargaPdfRingkasan\(\{(.*?)\n  Future<Uint8List> [a-zA-Z0-9_]+', dotAll: true);
      matchOld = regexOldFallback.firstMatch(ringkasan);
      if (matchOld == null) {
        print("Could not find old generatePotensiWargaPdfRingkasan");
        exit(1);
      }
  }
  
  // Actually, we can just replace everything between Future<Uint8List> generatePotensiWargaPdfRingkasan({ and the next Future<Uint8List>
  final newRingkasan = ringkasan.substring(0, matchOld.start) + funcBody + "\n  " + ringkasan.substring(matchOld.end - (matchOld.group(0)!.length - matchOld.group(0)!.lastIndexOf("Future<Uint8List>")));

  await ringkasanFile.writeAsString(newRingkasan);
  print("Replacement successful");
}
