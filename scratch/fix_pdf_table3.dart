import 'dart:io';

void main() {
  final file = File('scratch/new_potensi_function.dart');
  var lines = file.readAsLinesSync();
  
  // Find start and end of dataRows building
  int startIdx = lines.indexWhere((l) => l.trim() == 'List<pw.Widget> dataRows = [];');
  int endIdx = lines.indexWhere((l) => l.trim() == 'return dataRows;');
  
  if (startIdx == -1 || endIdx == -1) {
    print('Could not find start or end index.');
    return;
  }
  
  List<String> newLines = [];
  newLines.addAll(lines.sublist(0, startIdx));
  
  String newLogic = r'''
          List<pw.TableRow> tableRows = [];

          for (var r in rows) {
            final krt = r['jmlKrt'] as int? ?? 0;
            final kk = r['jmlKk'] as int? ?? 0;
            final l = r['L'] as int? ?? 0;
            final p = r['P'] as int? ?? 0;
            final balitaL = r['balitaL'] as int? ?? 0;
            final balitaP = r['balitaP'] as int? ?? 0;
            final balitaAktifL = r['balitaAktifL'] as int? ?? 0;
            final balitaAktifP = r['balitaAktifP'] as int? ?? 0;
            final pus = r['pus'] as int? ?? 0;
            final tidakKb = r['tidakKb'] as int? ?? 0;
            final kbPil = r['kbPil'] as int? ?? 0;
            final kbIud = r['kbIud'] as int? ?? 0;
            final kbImplan = r['kbImplan'] as int? ?? 0;
            final kbSuntik = r['kbSuntik'] as int? ?? 0;
            final kbKondom = r['kbKondom'] as int? ?? 0;
            final kbSteril = r['kbSteril'] as int? ?? 0;
            final kbLainnya = r['kbLainnya'] as int? ?? 0;
            final remajaL = r['remajaL'] as int? ?? 0;
            final remajaP = r['remajaP'] as int? ?? 0;
            final remajaAktifL = r['remajaAktifL'] as int? ?? 0;
            final remajaAktifP = r['remajaAktifP'] as int? ?? 0;
            final lansiaL = r['lansiaL'] as int? ?? 0;
            final lansiaP = r['lansiaP'] as int? ?? 0;
            final lansiaAktifL = r['lansiaAktifL'] as int? ?? 0;
            final lansiaAktifP = r['lansiaAktifP'] as int? ?? 0;
            final berkebutuhanL = r['berkebutuhanL'] as int? ?? 0;
            final berkebutuhanP = r['berkebutuhanP'] as int? ?? 0;

            tKrt += krt;
            tKk += kk;
            tL += l;
            tP += p;
            tBalitaL += balitaL;
            tBalitaP += balitaP;
            tBalitaAktifL += balitaAktifL;
            tBalitaAktifP += balitaAktifP;
            tPus += pus;
            tTidakKb += tidakKb;
            tPil += kbPil;
            tIud += kbIud;
            tImplan += kbImplan;
            tSuntik += kbSuntik;
            tKondom += kbKondom;
            tSteril += kbSteril;
            tKbLainnya += kbLainnya;
            tRemajaL += remajaL;
            tRemajaP += remajaP;
            tRemajaAktifL += remajaAktifL;
            tRemajaAktifP += remajaAktifP;
            tLansiaL += lansiaL;
            tLansiaP += lansiaP;
            tLansiaAktifL += lansiaAktifL;
            tLansiaAktifP += lansiaAktifP;
            tBerkebutuhanL += berkebutuhanL;
            tBerkebutuhanP += berkebutuhanP;

            final values = [
              '${r['no']}',
              '${r['namaBangunan'] ?? r['dasawisma'] ?? ''}',
              '$krt',
              '$kk',
              '$l',
              '$p',
              '$balitaL',
              '$balitaP',
              '$balitaAktifL',
              '$balitaAktifP',
              '$pus',
              '$tidakKb',
              '$kbPil',
              '$kbIud',
              '$kbImplan',
              '$kbSuntik',
              '$kbKondom',
              '$kbSteril',
              '$kbLainnya',
              '$remajaL',
              '$remajaP',
              '$remajaAktifL',
              '$remajaAktifP',
              '$lansiaL',
              '$lansiaP',
              '$lansiaAktifL',
              '$lansiaAktifP',
              '$berkebutuhanL',
              '$berkebutuhanP',
              '',
            ];

            tableRows.add(
              pw.TableRow(
                children: [
                  for (int j = 0; j < 30; j++)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(1),
                      constraints: const pw.BoxConstraints(minHeight: 16),
                      alignment: j == 1
                          ? pw.Alignment.centerLeft
                          : pw.Alignment.center,
                      child: pw.Text(
                        values[j],
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // TOTAL row
          final totalValues = [
            '', // NO
            'JUMLAH', // NAMA BANGUNAN
            '$tKrt',
            '$tKk',
            '$tL',
            '$tP',
            '$tBalitaL',
            '$tBalitaP',
            '$tBalitaAktifL',
            '$tBalitaAktifP',
            '$tPus',
            '$tTidakKb',
            '$tPil',
            '$tIud',
            '$tImplan',
            '$tSuntik',
            '$tKondom',
            '$tSteril',
            '$tKbLainnya',
            '$tRemajaL',
            '$tRemajaP',
            '$tRemajaAktifL',
            '$tRemajaAktifP',
            '$tLansiaL',
            '$tLansiaP',
            '$tLansiaAktifL',
            '$tLansiaAktifP',
            '$tBerkebutuhanL',
            '$tBerkebutuhanP',
            '',
          ];

          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1.0),
                ),
              ),
              children: [
                for (int j = 0; j < 30; j++)
                  pw.Container(
                    height: 18,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      totalValues[j],
                      style: pw.TextStyle(font: boldFont, fontSize: j == 1 ? 6 : 5),
                    ),
                  ),
              ],
            ),
          );

          return [
            pw.Table(
              border: const pw.TableBorder(
                left: pw.BorderSide(width: 0.5),
                right: pw.BorderSide(width: 0.5),
                bottom: pw.BorderSide(width: 1.0),
                verticalInside: pw.BorderSide(width: 0.5),
                horizontalInside: pw.BorderSide(width: 0.5),
              ),
              columnWidths: {
                for (int j = 0; j < 30; j++)
                  j: j == 1 ? const pw.FlexColumnWidth(4) : const pw.FlexColumnWidth(1),
              },
              children: tableRows,
            )
          ];''';

  newLines.addAll(newLogic.split('\n'));
  newLines.addAll(lines.sublist(endIdx + 1));
  
  file.writeAsStringSync(newLines.join('\n'));
  print('Success');
}
