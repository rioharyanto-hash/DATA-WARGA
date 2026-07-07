  Future<Uint8List> generatePotensiWargaPdfPerincian({
    required Map<String, dynamic> data,
  }) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pw.Widget buildCell(
      String text, {
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
    }) {
      final content = pw.Container(
        padding: const pw.EdgeInsets.all(1),
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: noRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.5),
            bottom: bottomBorder
                ? const pw.BorderSide(width: 0.5)
                : pw.BorderSide.none,
          ),
        ),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 5 : 6),
          ),
        ),
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    // Build the complex table header widget
    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
          buildCell('NAMA\nBANGUNAN', flex: 4, isHeader: true, fontSize: 5),
          buildCell('JML\nKRT', flex: 1, isHeader: true, fontSize: 5),
          buildCell('JML\nKK', flex: 1, isHeader: true, fontSize: 5),
          // TOTAL (L, P)
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('TOTAL',
                      flex: 1,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 5),
                        buildCell('P',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // BALITA (L, P, AKTIF POSYANDU L/P)
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('BALITA',
                      flex: 1,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 5),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 5),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell('AKTIF\nPOSYANDU',
                                  flex: 2,
                                  isHeader: true,
                                  noRightBorder: true,
                                  bottomBorder: true,
                                  fontSize: 4),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 5),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // PUS
          buildCell('PUS', flex: 1, isHeader: true, fontSize: 5),
          // PENGGUNAAN ALAT KB (8 sub-columns)
          pw.Expanded(
            flex: 8,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('PENGGUNAAN ALAT KB',
                      flex: 1,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('TIDAK\nKB',
                            flex: 1, isHeader: true, fontSize: 5),
                        buildCell('PIL',
                            flex: 1, isHeader: true, fontSize: 5),
                        buildCell('IUD',
                            flex: 1, isHeader: true, fontSize: 5),
                        buildCell('IMPLAN',
                            flex: 1, isHeader: true, fontSize: 4),
                        buildCell('SUNTIK',
                            flex: 1, isHeader: true, fontSize: 4),
                        buildCell('KONDOM',
                            flex: 1, isHeader: true, fontSize: 4),
                        buildCell('STERIL',
                            flex: 1, isHeader: true, fontSize: 4),
                        buildCell('LAINN\nYA',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // REMAJA (10-18) TH
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('REMAJA (10-18) TH',
                      flex: 1,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 5),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 5),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell('AKTIF\nPOSREM',
                                  flex: 2,
                                  isHeader: true,
                                  noRightBorder: true,
                                  bottomBorder: true,
                                  fontSize: 4),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 5),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // LANSIA
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('LANSIA',
                      flex: 1,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 5),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 5),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell('AKTIF POSLAN',
                                  flex: 2,
                                  isHeader: true,
                                  noRightBorder: true,
                                  bottomBorder: true,
                                  fontSize: 4),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 5),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // BERKEBUTUHAN KHUSUS (L, P)
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('BERKEBUTUHAN\nKHUSUS',
                      flex: 2,
                      isHeader: true,
                      noRightBorder: true,
                      bottomBorder: true,
                      fontSize: 5),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 5),
                        buildCell('P',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // KET
          buildCell('KET',
              flex: 1, isHeader: true, noRightBorder: true, fontSize: 5),
        ],
      ),
    );

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();
    final rt = data['rt']?.toString() ?? '...';
    final rw = data['rw']?.toString() ?? '...';
    final kelurahan = data['kelurahan']?.toString() ?? '...';
    final tahun = data['tahun']?.toString() ?? '...';
    final kelompok = data['kelompok']?.toString() ?? '...';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ), // F4 Landscape
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'DATA POTENSI WARGA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.Text(
                'KELOMPOK DASAWISMA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _potensiInfoRow(
                          'NAMA KELOMPOK', kelompok, boldFont, regularFont),
                      pw.SizedBox(height: 2),
                      _potensiInfoRow(
                          'RUKUN WARGA (RW)', rw, boldFont, regularFont),
                      pw.SizedBox(height: 2),
                      _potensiInfoRow(
                          'DESA / KELURAHAN', kelurahan, boldFont, regularFont),
                      pw.SizedBox(height: 2),
                      _potensiInfoRow('TAHUN', tahun, boldFont, regularFont),
                      pw.SizedBox(height: 2),
                      _potensiInfoRow('PERIODE', '...', boldFont, regularFont),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Container(height: 48, child: tableHeaderWidget),
              pw.Container(
                height: 12,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    for (int j = 1; j <= 30; j++)
                      pw.Expanded(
                        flex: j == 2 ? 4 : 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: j == 30
                                  ? pw.BorderSide.none
                                  : const pw.BorderSide(width: 0.5),
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '$j',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        build: (context) {
          int tKrt = 0, tKk = 0, tL = 0, tP = 0;
          int tBalitaL = 0, tBalitaP = 0, tBalitaAktifL = 0, tBalitaAktifP = 0;
          int tPus = 0;
          int tTidakKb = 0,
              tPil = 0,
              tIud = 0,
              tImplan = 0,
              tSuntik = 0,
              tKondom = 0,
              tSteril = 0,
              tKbLainnya = 0;
          int tRemajaL = 0,
              tRemajaP = 0,
              tRemajaAktifL = 0,
              tRemajaAktifP = 0;
          int tLansiaL = 0,
              tLansiaP = 0,
              tLansiaAktifL = 0,
              tLansiaAktifP = 0;
          int tBerkebutuhanL = 0, tBerkebutuhanP = 0;

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
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _potensiInfoRow(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            label,
            style: pw.TextStyle(font: boldFont, fontSize: 8),
          ),
        ),
        pw.Text(
          ': ',
          style: pw.TextStyle(font: boldFont, fontSize: 8),
        ),
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            value,
            style: pw.TextStyle(font: regularFont, fontSize: 8),
          ),
        ),
      ],
    );
  }