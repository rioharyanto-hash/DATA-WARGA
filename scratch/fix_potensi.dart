import 'dart:io';

void fixFile(String filePath, String functionName) {
  var file = File(filePath);
  var content = file.readAsStringSync();

  int idx = content.indexOf(functionName);
  if (idx == -1) {
    print("Function \$functionName not found in \$filePath");
    return;
  }

  String pattern = r'''          for \(var r in rows\) \{[\s\S]*?          return \[''';
  RegExp exp = RegExp(pattern);
  var match = exp.firstMatch(content.substring(idx));
  if (match == null) {
    print("Match not found in \$functionName");
    return;
  }

  String oldBlock = match.group(0)!;
  String newBlock = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.yellow) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  height: 20,
                  padding: const pw.EdgeInsets.all(2),
                  alignment: alignment,
                  child: pw.Text(
                    values[i],
                    style: pw.TextStyle(
                      font: isTotal ? pw.Font.helveticaBold() : pw.Font.helvetica(),
                      fontSize: 6,
                    ),
                  ),
                );
              }),
            );
          }

          for (var r in rows) {
            tSehat += r['rumahSehat'] as int? ?? 0;
            tTidakSehat += r['rumahTidakSehat'] as int? ?? 0;
            tSampah += r['punyaTempatSampah'] as int? ?? 0;
            tSpal += r['punyaSpal'] as int? ?? 0;
            tJamban += r['punyaJamban'] as int? ?? 0;
            tStiker += r['tempelStiker'] as int? ?? 0;
            tPdam += r['sumberAirPdam'] as int? ?? 0;
            tSumur += r['sumberAirSumur'] as int? ?? 0;
            tDll += r['sumberAirLainnya'] as int? ?? 0;
            tBeras += r['makananBeras'] as int? ?? 0;
            tNonBeras += r['makananNonBeras'] as int? ?? 0;
            tUp2k += r['ikutUp2k'] as int? ?? 0;
            tPekarangan += r['pekarangan'] as int? ?? 0;
            tIndustri += r['industriRT'] as int? ?? 0;
            tKerja += r['kerjaBakti'] as int? ?? 0;

            tableRows.add(
              buildDataRow([
                '\${r['no']}',
                '\${r['rt']}',
                '\${r['dasawisma']}',
                '\${r['rumahSehat']}',
                '\${r['rumahTidakSehat']}',
                '\${r['punyaTempatSampah']}',
                '\${r['punyaSpal']}',
                '\${r['punyaJamban']}',
                '\${r['tempelStiker']}',
                '\${r['sumberAirPdam']}',
                '\${r['sumberAirSumur']}',
                '\${r['sumberAirLainnya']}',
                '\${r['makananBeras']}',
                '\${r['makananNonBeras']}',
                '\${r['ikutUp2k']}',
                '\${r['pekarangan']}',
                '\${r['industriRT']}',
                '\${r['kerjaBakti']}',
                '',
              ])
            );
          }

          tableRows.add(
            buildDataRow([
              '',
              'Jumlah',
              '',
              '\$tSehat',
              '\$tTidakSehat',
              '\$tSampah',
              '\$tSpal',
              '\$tJamban',
              '\$tStiker',
              '\$tPdam',
              '\$tSumur',
              '\$tDll',
              '\$tBeras',
              '\$tNonBeras',
              '\$tUp2k',
              '\$tPekarangan',
              '\$tIndustri',
              '\$tKerja',
              '',
            ], isTotal: true)
          );

          return [''';

  content = content.substring(0, idx) + content.substring(idx).replaceFirst(oldBlock, newBlock);
  file.writeAsStringSync(content);
  print("Updated \$filePath successfully");
}

void main() {
  fixFile('lib/src/features/report/data/services/pdf_perincian_service.dart', 'generatePotensiWargaPdfPerincian(');
  fixFile('lib/src/features/report/data/services/pdf_report_service.dart', 'generatePotensiWargaPdf(');
}
