// ignore_for_file: unused_element, unused_import, unused_local_variable
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfRingkasanService {
  pw.Widget _buildAdvancedHeaderCell(
    String text,
    pw.Font font, {
    double fontSize = 8,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: fontSize),
      ),
    );
  }

  pw.Widget _buildCell(
    String text,
    pw.Font font,
    bool isBold, {
    double fontSize = 8,
  }) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.TableRow _buildEmptyTableRow(
    List<String> columns, {
    required pw.Font font,
    double height = 18,
    double fontSize = 8,
    List<pw.Alignment>? alignments,
  }) {
    return pw.TableRow(
      children: List.generate(columns.length, (index) {
        final text = columns[index];
        final alignment = (alignments != null && alignments.length > index)
            ? alignments[index]
            : pw.Alignment.center;

        final textAlign = alignment == pw.Alignment.centerLeft
            ? pw.TextAlign.left
            : (alignment == pw.Alignment.centerRight
                  ? pw.TextAlign.right
                  : pw.TextAlign.center);

        return pw.Container(
          height: height,
          padding: const pw.EdgeInsets.all(4),
          alignment: alignment,
          child: pw.Text(
            text,
            textAlign: textAlign,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        );
      }),
    );
  }

  Future<Uint8List> generateForm3Ringkasan({
    required Map<String, dynamic> data,
  }) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final tableHeaders = [
      'NO',
      'JUMLAH KRT',
      'JUMLAH KEPALA KELUARGA',
      'LAKI-LAKI',
      'PEREMPUAN',
      'Jumlah',
      'Balita\n(0-5 Thn)',
      'Anak\n(6-9 Thn)',
      'Remaja\n(10-24 Thn)',
      'Dewasa\n(25-59 Thn)',
      'Lansia\n(60+ Thn)',
      'Jumlah\nKeluarga',
      'Jumlah\nPasangan\nUsia Subur\n(PUS)',
      'MOW/Steril\nWanita',
      'MOP/Steril\nPria',
      'IUD/Spiral\nAKDR',
      'Implant/\nSusuk',
      'Suntik',
      'Pil',
      'Kondom',
      'Jumlah\nPeserta KB',
      'TIAL',
      'IAT',
      'IAS',
      'Hamil',
      'Jumlah Bukan\nPeserta KB',
    ];

    final style = pw.TextStyle(font: boldFont, fontSize: 4.5);
    final borderRight = const pw.Border(right: pw.BorderSide(width: 0.5));
    final borderBottom = const pw.Border(bottom: pw.BorderSide(width: 0.5));

    pw.Widget headerCell(
      String text,
      double flexVal, [
      pw.Border? customBorder,
    ]) {
      return pw.Expanded(
        flex: (flexVal * 10).toInt(),
        child: pw.Container(
          decoration: pw.BoxDecoration(border: customBorder ?? borderRight),
          child: pw.Center(
            child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
          ),
        ),
      );
    }

    pw.Widget numberCell(String text, int flexVal, [pw.Border? customBorder]) {
      return pw.Expanded(
        flex: flexVal,
        child: pw.Container(
          decoration: pw.BoxDecoration(
              border: customBorder ??
                  const pw.Border(
                    right: pw.BorderSide(width: 0.5),
                    top: pw.BorderSide(width: 0.5),
                  )),
          child: pw.Center(
            child: pw.Text(text, style: style),
          ),
        ),
      );
    }

    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Column(
        children: [
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
          headerCell('NO', 1),
          headerCell('JUMLAH KRT', 3),
          headerCell('JUMLAH KEPALA KELUARGA', 4),
          pw.Expanded(
            flex: 80,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text(
                        'Jumlah dan Komposisi Penduduk',
                        style: style,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('LAKI-LAKI', 1),
                        headerCell('PEREMPUAN', 1),
                        headerCell('Jumlah', 1),
                        headerCell('Balita\n(0-5 Thn)', 1),
                        headerCell('Anak\n(6-9 Thn)', 1),
                        headerCell('Remaja\n(10-24 Thn)', 1),
                        headerCell('Dewasa\n(25-59 Thn)', 1),
                        headerCell('Lansia\n(60+ Thn)', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          headerCell('Jumlah\nKeluarga', 1),
          headerCell('Jumlah\nPasangan\nUsia Subur\n(PUS)', 1),
          pw.Expanded(
            flex: 80,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('Jumlah Kesertaan Ber-KB', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('MOW/Steril\nWanita', 1),
                        headerCell('MOP/Steril\nPria', 1),
                        headerCell('IUD/Spiral\nAKDR', 1),
                        headerCell('Implant/\nSusuk', 1),
                        headerCell('Suntik', 1),
                        headerCell('Pil', 1),
                        headerCell('Kondom', 1),
                        headerCell('Jumlah\nPeserta KB', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 50,
            child: pw.Container(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('Bukan Peserta KB', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('TIAL', 1),
                        headerCell('IAT', 1),
                        headerCell('IAS', 1),
                        headerCell('Hamil', 1),
                        headerCell('Jumlah Bukan\nPeserta KB', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
              ],
            ),
          ),
          pw.Container(
            height: 10,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                numberCell('1', 10),
                numberCell('2', 30),
                numberCell('3', 40),
                numberCell('4', 80),
                numberCell('5', 10),
                numberCell('6', 10),
                numberCell('7', 80),
                numberCell('8', 50, const pw.Border(top: pw.BorderSide(width: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(3),
      2: const pw.FlexColumnWidth(4),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1),
      5: const pw.FlexColumnWidth(1),
      6: const pw.FlexColumnWidth(1),
      7: const pw.FlexColumnWidth(1),
      8: const pw.FlexColumnWidth(1),
      9: const pw.FlexColumnWidth(1),
      10: const pw.FlexColumnWidth(1),
      11: const pw.FlexColumnWidth(1),
      12: const pw.FlexColumnWidth(1),
      13: const pw.FlexColumnWidth(1),
      14: const pw.FlexColumnWidth(1),
      15: const pw.FlexColumnWidth(1),
      16: const pw.FlexColumnWidth(1),
      17: const pw.FlexColumnWidth(1),
      18: const pw.FlexColumnWidth(1),
      19: const pw.FlexColumnWidth(1),
      20: const pw.FlexColumnWidth(1),
      21: const pw.FlexColumnWidth(1),
      22: const pw.FlexColumnWidth(1),
      23: const pw.FlexColumnWidth(1),
      24: const pw.FlexColumnWidth(1),
      25: const pw.FlexColumnWidth(1),
    };

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.legal.landscape,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DATA KUANTITAS',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FixedColumnWidth(10),
                  2: const pw.FixedColumnWidth(300),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'NAMA',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        data['namaKader'] ?? '',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'Kelompok',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        data['kelompokName'] ?? '',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'RT / RW',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        '${data['rt'] ?? ''} / ${data['rw'] ?? ''}',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'Kelurahan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        data['kelurahan'] ?? '',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'Kecamatan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        data['kecamatan'] ?? '',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(
                        'Kota',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        ':',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.Text(
                        data['kota'] ?? '',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(height: 40, child: tableHeaderWidget),
            ],
          );
        },
        build: (context) {
          int tKrt = 0, tKk = 0, tL = 0, tP = 0, tJml = 0;
          int tBalita = 0, tAnak = 0, tRemaja = 0, tDewasa = 0, tLansia = 0;
          int tKeluarga = 0, tPus = 0;
          int tMow = 0,
              tMop = 0,
              tIud = 0,
              tImp = 0,
              tSuntik = 0,
              tPil = 0,
              tKon = 0,
              tKb = 0;
          int tTial = 0, tIat = 0, tIas = 0, tHamil = 0, tBukanKb = 0;

          List<pw.TableRow> tableRows = [];
          for (var r in rows) {
            tKrt += (r['namaKrt'] as String).isNotEmpty
                ? int.tryParse(r['namaKrt'].toString()) ?? 0
                : 0;
            tKk += (r['namaKk'] as String).isNotEmpty
                ? int.tryParse(r['namaKk'].toString()) ?? 0
                : 0;
            tL += r['L'] as int? ?? 0;
            tP += r['P'] as int? ?? 0;
            tJml += r['jumlah'] as int? ?? 0;
            tBalita += r['balita'] as int? ?? 0;
            tAnak += r['anak'] as int? ?? 0;
            tRemaja += r['remaja'] as int? ?? 0;
            tDewasa += r['dewasa'] as int? ?? 0;
            tLansia += r['lansia'] as int? ?? 0;
            tKeluarga += r['jumlahKeluarga'] as int? ?? 0;
            tPus += r['pus'] as int? ?? 0;
            tMow += r['mow'] as int? ?? 0;
            tMop += r['mop'] as int? ?? 0;
            tIud += r['iud'] as int? ?? 0;
            tImp += r['implant'] as int? ?? 0;
            tSuntik += r['suntik'] as int? ?? 0;
            tPil += r['pil'] as int? ?? 0;
            tKon += r['kondom'] as int? ?? 0;
            tKb += r['jumlahKb'] as int? ?? 0;
            tTial += r['tial'] as int? ?? 0;
            tIat += r['iat'] as int? ?? 0;
            tIas += r['ias'] as int? ?? 0;
            tHamil += r['hamil'] as int? ?? 0;
            tBukanKb += r['jumlahBukanKb'] as int? ?? 0;

            tableRows.add(
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['no']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      '${r['namaKrt']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      '${r['namaKk']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['L']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['P']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['jumlah']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['balita']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['anak']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['remaja']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['dewasa']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['lansia']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['jumlahKeluarga']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['pus']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['mow']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['mop']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['iud']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['implant']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['suntik']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['pil']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['kondom']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['jumlahKb']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['tial']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['iat']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['ias']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['hamil']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${r['jumlahBukanKb']}',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ),
                ],
              ),
            );

            tableRows.add(
              pw.TableRow(
                children: List.generate(
                  26,
                  (index) => pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '.',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 6,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          for (int i = 0; i < 14; i++) {
            tableRows.add(
              pw.TableRow(
                children: List.generate(
                  26,
                  (index) => pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '.',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 6,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.yellow),
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Jumlah',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tKrt',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tKk',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tL',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tP',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tJml',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tBalita',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tAnak',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tRemaja',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tDewasa',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tLansia',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tKeluarga',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tPus',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tMow',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tMop',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tIud',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tImp',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tSuntik',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tPil',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tKon',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tKb',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tTial',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tIat',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tIas',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tHamil',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '$tBukanKb',
                    style: pw.TextStyle(font: boldFont, fontSize: 6),
                  ),
                ),
              ],
            ),
          );

          return [
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: columnWidths,
              children: tableRows,
            ),
            pw.SizedBox(height: 16),
            pw.Text('KET:', style: pw.TextStyle(font: boldFont, fontSize: 8)),
            pw.Text(
              '*TIAL = Tidak Ingin Anak Lagi',
              style: pw.TextStyle(font: regularFont, fontSize: 8),
            ),
            pw.Text(
              '*IAT = Ingin Anak Tunda',
              style: pw.TextStyle(font: regularFont, fontSize: 8),
            ),
            pw.Text(
              '*IAS = INGIN ANAK SEGERA',
              style: pw.TextStyle(font: regularFont, fontSize: 8),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateRekapPkkPdf({
    required String namaKelompok,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
    required String provinsi,
    required Map<String, dynamic> data,
  }) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final style = pw.TextStyle(font: boldFont, fontSize: 8);
    final borderRight = const pw.Border(right: pw.BorderSide(width: 0.5));
    final borderBottom = const pw.Border(bottom: pw.BorderSide(width: 0.5));

    pw.Widget headerCell(
      String text,
      double flexVal, [
      pw.Border? customBorder,
    ]) {
      return pw.Expanded(
        flex: (flexVal * 10).toInt(),
        child: pw.Container(
          decoration: pw.BoxDecoration(border: customBorder ?? borderRight),
          child: pw.Center(
            child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
          ),
        ),
      );
    }

    pw.Widget dataCell(String text, {pw.Font? font}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(2),
        alignment: pw.Alignment.center,
        constraints: const pw.BoxConstraints(minHeight: 12),
        child: pw.Text(
          text.isEmpty ? ' ' : text,
          style: pw.TextStyle(font: font ?? regularFont, fontSize: 8),
        ),
      );
    }

    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          headerCell('NO', 1.5),
          headerCell('NOMOR RT', 2.5),
          headerCell('JUMLAH\nDASA\nWISMA', 2.5),
          headerCell('JUMLAH\nKRT', 2.5),
          headerCell('JUMLAH\nKK', 2.5),
          pw.Expanded(
            flex: 270,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('JUMLAH ANGGOTA KELUARGA', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 40,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 12,
                                  decoration: pw.BoxDecoration(border: borderBottom),
                                  child: pw.Center(child: pw.Text('TOTAL', style: style)),
                                ),
                                pw.Expanded(
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                    children: [
                                      headerCell('L', 2),
                                      headerCell('P', 2, pw.Border()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 40,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 12,
                                  decoration: pw.BoxDecoration(border: borderBottom),
                                  child: pw.Center(child: pw.Text('BALITA', style: style)),
                                ),
                                pw.Expanded(
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                    children: [
                                      headerCell('L', 2),
                                      headerCell('P', 2, pw.Border()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        headerCell('REMAJA', 2),
                        headerCell('PUS', 2),
                        headerCell('WUS', 2),
                        headerCell('IBU\nHAMIL', 2),
                        headerCell('IBU\nMENYUSUI', 2.5),
                        headerCell('PRA\nLANSIA', 2),
                        headerCell('LANSIA', 2),
                        headerCell('3 BUTA', 2),
                        headerCell('BERKEB.\nKHUSUS', 2.5, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 135,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('SEHAT\nLAYAK\nHUNI', 2.5),
                        headerCell('TIDAK\nSEHAT\nLAYAK\nHUNI', 2.5),
                        headerCell('MEMILIKI TMP.\nPEMB. SAMPAH', 2),
                        headerCell('MEMILIKI\nSPAL', 2),
                        headerCell('MEMILIKI\nJAMBAN\nKELUARGA', 2.5),
                        headerCell('MENEMPEL\nSTIKER P4K', 2, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('PDAM', 2),
                        headerCell('SUMUR', 2),
                        headerCell('DLL', 2, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 40,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('BERAS', 2),
                        headerCell('NON\nBERAS', 2, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 90,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('UP2K', 2),
                        headerCell('PEMANF.\nPEKARA\nNGAN', 2.5),
                        headerCell('INDUSTRI\nRT', 2.5),
                        headerCell('KERJA\nBAKTI', 2, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          headerCell('KET', 3, pw.Border()),
        ],
      ),
    );

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.5),
      1: const pw.FlexColumnWidth(2.5),
      2: const pw.FlexColumnWidth(2.5),
      3: const pw.FlexColumnWidth(2.5),
      4: const pw.FlexColumnWidth(2.5),
      5: const pw.FlexColumnWidth(2),
      6: const pw.FlexColumnWidth(2),
      7: const pw.FlexColumnWidth(2),
      8: const pw.FlexColumnWidth(2),
      9: const pw.FlexColumnWidth(2),
      10: const pw.FlexColumnWidth(2),
      11: const pw.FlexColumnWidth(2),
      12: const pw.FlexColumnWidth(2),
      13: const pw.FlexColumnWidth(2.5),
      14: const pw.FlexColumnWidth(2),
      15: const pw.FlexColumnWidth(2),
      16: const pw.FlexColumnWidth(2),
      17: const pw.FlexColumnWidth(2.5),
      18: const pw.FlexColumnWidth(2.5),
      19: const pw.FlexColumnWidth(2.5),
      20: const pw.FlexColumnWidth(2),
      21: const pw.FlexColumnWidth(2),
      22: const pw.FlexColumnWidth(2.5),
      23: const pw.FlexColumnWidth(2),
      24: const pw.FlexColumnWidth(2),
      25: const pw.FlexColumnWidth(2),
      26: const pw.FlexColumnWidth(2),
      27: const pw.FlexColumnWidth(2),
      28: const pw.FlexColumnWidth(2),
      29: const pw.FlexColumnWidth(2),
      30: const pw.FlexColumnWidth(2.5),
      31: const pw.FlexColumnWidth(2.5),
      32: const pw.FlexColumnWidth(2),
      33: const pw.FlexColumnWidth(3),
    };

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.legal.landscape,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'REKAPITULASI',
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                    pw.Text(
                      'CATATAN DATA DAN KEGIATAN WARGA',
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                    pw.Text(
                      'KELOMPOK PKK RW',
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    child: pw.Table(
                      columnWidths: {
                        0: const pw.FixedColumnWidth(120),
                        1: const pw.FixedColumnWidth(10),
                        2: const pw.IntrinsicColumnWidth(),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text(
                              'RW',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              ':',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              rw,
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text(
                              'DUSUN/LINGKUNGAN',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              ':',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              '', // No data for dusun/lingkungan currently
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text(
                              'DESA / KELURAHAN',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              ':',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              desa,
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text(
                              'TAHUN',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              ':',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                            pw.Text(
                              '${data['tahun']}',
                              style: pw.TextStyle(font: regularFont, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(height: 40, child: tableHeaderWidget),
              pw.Container(
                child: pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: columnWidths,
                  children: [
                    pw.TableRow(
                      children: List.generate(
                        34,
                        (i) => pw.Container(
                          height: 10,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${i + 1}',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
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
          int tKrt = 0,
              tKk = 0,
              tL = 0,
              tP = 0,
              tBalitaL = 0,
              tBalitaP = 0,
              tButa = 0;
          int tBerkebutuhan = 0,
              tRemaja = 0,
              tPus = 0,
              tWus = 0,
              tHamil = 0,
              tMenyusui = 0;
          int tPraLansia = 0,
              tLansia = 0,
              tSehat = 0,
              tTidakSehat = 0,
              tSampah = 0;
          int tSpal = 0,
              tJamban = 0,
              tStiker = 0,
              tPdam = 0,
              tSumur = 0,
              tDll = 0;
          int tBeras = 0,
              tNonBeras = 0,
              tUp2k = 0,
              tPekarangan = 0,
              tIndustri = 0,
              tKerja = 0;

          List<pw.TableRow> tableRows = [];
          for (var r in rows) {
            tKrt += r['jmlKrt'] as int? ?? 0;
            tKk += r['jmlKk'] as int? ?? 0;
            tL += r['L'] as int? ?? 0;
            tP += r['P'] as int? ?? 0;
            tBalitaL += r['balitaL'] as int? ?? 0;
            tBalitaP += r['balitaP'] as int? ?? 0;
            tButa += r['buta'] as int? ?? 0;
            tBerkebutuhan += r['berkebutuhanKhusus'] as int? ?? 0;
            tRemaja += r['remaja'] as int? ?? 0;
            tPus += r['pus'] as int? ?? 0;
            tWus += r['wus'] as int? ?? 0;
            tHamil += r['ibuHamil'] as int? ?? 0;
            tMenyusui += r['ibuMenyusui'] as int? ?? 0;
            tPraLansia += r['praLansia'] as int? ?? 0;
            tLansia += r['lansia'] as int? ?? 0;
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
              pw.TableRow(
                children: [
                  dataCell('${r['no']}'),
                  dataCell('${r['rt']}'),
                  dataCell('1'),
                  dataCell('${r['jmlKrt']}'),
                  dataCell('${r['jmlKk']}'),
                  dataCell('${r['L']}'),
                  dataCell('${r['P']}'),
                  dataCell('${r['balitaL']}'),
                  dataCell('${r['balitaP']}'),
                  dataCell('${r['remaja']}'),
                  dataCell('${r['pus']}'),
                  dataCell('${r['wus']}'),
                  dataCell('${r['ibuHamil']}'),
                  dataCell('${r['ibuMenyusui']}'),
                  dataCell('${r['praLansia']}'),
                  dataCell('${r['lansia']}'),
                  dataCell('${r['buta']}'),
                  dataCell('${r['berkebutuhanKhusus']}'),
                  dataCell('${r['rumahSehat']}'),
                  dataCell('${r['rumahTidakSehat']}'),
                  dataCell('${r['punyaTempatSampah']}'),
                  dataCell('${r['punyaSpal']}'),
                  dataCell('${r['punyaJamban']}'),
                  dataCell('${r['tempelStiker']}'),
                  dataCell('${r['sumberAirPdam']}'),
                  dataCell('${r['sumberAirSumur']}'),
                  dataCell('${r['sumberAirLainnya']}'),
                  dataCell('${r['makananBeras']}'),
                  dataCell('${r['makananNonBeras']}'),
                  dataCell('${r['ikutUp2k']}'),
                  dataCell('${r['pekarangan']}'),
                  dataCell('${r['industriRT']}'),
                  dataCell('${r['kerjaBakti']}'),
                  dataCell(''), // Keterangan
                ],
              ),
            );
          }

          // Add 15 empty rows
          for (int i = 0; i < 15; i++) {
            tableRows.add(
              pw.TableRow(
                children: List.generate(34, (index) => dataCell('')),
              ),
            );
          }

          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.yellow),
              children: [
                dataCell('', font: boldFont), // No
                dataCell('Jumlah', font: boldFont), // RT
                dataCell('${rows.length}', font: boldFont), // Dasawisma
                dataCell('$tKrt', font: boldFont),
                dataCell('$tKk', font: boldFont),
                dataCell('$tL', font: boldFont),
                dataCell('$tP', font: boldFont),
                dataCell('$tBalitaL', font: boldFont),
                dataCell('$tBalitaP', font: boldFont),
                dataCell('$tRemaja', font: boldFont),
                dataCell('$tPus', font: boldFont),
                dataCell('$tWus', font: boldFont),
                dataCell('$tHamil', font: boldFont),
                dataCell('$tMenyusui', font: boldFont),
                dataCell('$tPraLansia', font: boldFont),
                dataCell('$tLansia', font: boldFont),
                dataCell('$tButa', font: boldFont),
                dataCell('$tBerkebutuhan', font: boldFont),
                dataCell('$tSehat', font: boldFont),
                dataCell('$tTidakSehat', font: boldFont),
                dataCell('$tSampah', font: boldFont),
                dataCell('$tSpal', font: boldFont),
                dataCell('$tJamban', font: boldFont),
                dataCell('$tStiker', font: boldFont),
                dataCell('$tPdam', font: boldFont),
                dataCell('$tSumur', font: boldFont),
                dataCell('$tDll', font: boldFont),
                dataCell('$tBeras', font: boldFont),
                dataCell('$tNonBeras', font: boldFont),
                dataCell('$tUp2k', font: boldFont),
                dataCell('$tPekarangan', font: boldFont),
                dataCell('$tIndustri', font: boldFont),
                dataCell('$tKerja', font: boldFont),
                dataCell('', font: boldFont), // Keterangan
              ],
            ),
          );

          return [
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: columnWidths,
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generatePotensiWargaPdfRingkasan({
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
            fontSize: fontSize ?? (isHeader ? 6 : 8),
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
          buildCell('NO', flex: 1, isHeader: true, fontSize: 6),
          buildCell('NOMOR RT', flex: 2, isHeader: true, fontSize: 6),
          buildCell('JUMLAH\nDASAWISMA', flex: 2, isHeader: true, fontSize: 6),
          buildCell('JUMLAH\nBANGUNAN', flex: 2, isHeader: true, fontSize: 6),
          buildCell('JUMLAH\nKELOMPOK', flex: 2, isHeader: true, fontSize: 6),
          buildCell('JML\nKRT', flex: 1, isHeader: true, fontSize: 6),
          buildCell('JML\nKK', flex: 1, isHeader: true, fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 6),
                        buildCell('P',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 6),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 6),
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
                                  fontSize: 6),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 6),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 6),
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
          buildCell('PUS', flex: 1, isHeader: true, fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('TIDAK\nKB',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('PIL',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('IUD',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('IMPLAN',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('SUNTIK',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('KONDOM',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('STERIL',
                            flex: 1, isHeader: true, fontSize: 6),
                        buildCell('LAINN\nYA',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 6),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 6),
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
                                  fontSize: 6),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 6),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 6),
                        buildCell('P', flex: 1, isHeader: true, fontSize: 6),
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
                                  fontSize: 6),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell('L',
                                        flex: 1,
                                        isHeader: true,
                                        fontSize: 6),
                                    buildCell('P',
                                        flex: 1,
                                        isHeader: true,
                                        noRightBorder: true,
                                        fontSize: 6),
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
                      fontSize: 6),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        buildCell('L', flex: 1, isHeader: true, fontSize: 6),
                        buildCell('P',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // KET
          buildCell('KET',
              flex: 1, isHeader: true, noRightBorder: true, fontSize: 6),
        ],
      ),
    );

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();
    final rt = data['rt']?.toString() ?? '...';
    final rw = data['rw']?.toString() ?? '...';
    final kelurahan = data['kelurahan']?.toString() ?? '...';
    final tahun = data['tahun']?.toString() ?? '...';
    final periode = data['periode']?.toString() ?? '...';
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
                      _potensiInfoRow('PERIODE', periode, boldFont, regularFont),
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
                    for (int j = 1; j <= 33; j++)
                      pw.Expanded(
                        flex: (j >= 2 && j <= 5) ? 2 : 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: j == 33
                                  ? pw.BorderSide.none
                                  : const pw.BorderSide(width: 0.5),
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '$j',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 8,
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
          int tDasawisma = 0, tBangunan = 0, tKelompok = 0;

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
            
            final isRowEmpty = r.isEmpty || r['namaWarga'] == null || r['namaWarga'].toString().isEmpty;
            final dasawismaStr = r['jumlah_dasawisma']?.toString() ?? '1';
            final bangunan = r['jumlah_bangunan'] as int? ?? 0;
            final kelompokVal = r['jumlah_kelompok'] as int? ?? 1;

            if (!isRowEmpty) {
              tDasawisma += 1; // Count 1 Dasawisma per row
              tBangunan += bangunan;
              tKelompok += kelompokVal;
            }

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

            final values = isRowEmpty ? [
              r['no']?.toString() ?? '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', '', '', '', '', '', '', '', '',
              '', '', ''
            ] : [
              '${r['no']}',
              '${r['nomor_rt'] ?? ''}',
              dasawismaStr,
              '$bangunan',
              '$kelompokVal',
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
                  for (int j = 0; j < 33; j++)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(1),
                      constraints: const pw.BoxConstraints(minHeight: 16),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        values[j],
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 8,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // TOTAL row
          final totalValues = [
            '',
            'JUMLAH',
            '$tDasawisma',
            '$tBangunan',
            '$tKelompok',
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
                for (int j = 0; j < 33; j++)
                  pw.Container(
                    height: 18,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      totalValues[j],
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
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
                for (int j = 0; j < 33; j++)
                  j: (j >= 1 && j <= 4) ? const pw.FlexColumnWidth(2) : const pw.FlexColumnWidth(1),
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

  Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf({
    required List<Map<String, int>> perKelompokData,
    required String namaKelompok,
    required String namaKader,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
    String bulanTahun = '',
  }) async {
    final pdf = pw.Document();

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();

    pw.Widget buildCell(
      dynamic contentData, {
      double? width,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
      pw.Alignment alignment = pw.Alignment.center,
      PdfColor backgroundColor = PdfColors.white,
    }) {
      final contentWidget = contentData is String
          ? pw.Text(
              contentData,
              textAlign: alignment == pw.Alignment.centerLeft
                  ? pw.TextAlign.left
                  : pw.TextAlign.center,
              style: pw.TextStyle(
                font: isHeader ? boldFont : regularFont,
                fontSize: fontSize ?? (isHeader ? 10 : 10),
              ),
            )
          : contentData as pw.Widget;

      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(4),
        alignment: alignment,
        decoration: pw.BoxDecoration(
          color: backgroundColor,
          border: pw.Border(
            right: noRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.5),
            bottom: bottomBorder
                ? const pw.BorderSide(width: 0.5)
                : pw.BorderSide.none,
          ),
        ),
        child: contentWidget,
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    final List<String> ageGroups = [
      '0 - 4 Tahun',
      '5 - 9 Tahun',
      '10 - 14 Tahun',
      '15 - 19 Tahun',
      '20 - 24 Tahun',
      '25 - 29 Tahun',
      '30 - 34 Tahun',
      '35 - 39 Tahun',
      '40 - 44 Tahun',
      '45 - 49 Tahun',
      '50 - 54 Tahun',
      '55 - 59 Tahun',
      '60 - 64 Tahun',
      '65 - 69 Tahun',
      '70 - 74 Tahun',
      '75 Tahun',
    ];

    final List<String> prefixList = [
      '0_4',
      '5_9',
      '10_14',
      '15_19',
      '20_24',
      '25_29',
      '30_34',
      '35_39',
      '40_44',
      '45_49',
      '50_54',
      '55_59',
      '60_64',
      '65_69',
      '70_74',
      '75_plus',
    ];

    // Helper: build breakdown widget with perfectly aligned numbers
    pw.Widget buildBreakdown(List<Map<String, int>> dataList, String key) {
      if (dataList.length <= 1) {
        final val = dataList.isNotEmpty ? (dataList.first[key] ?? 0) : 0;
        return pw.Text(val.toString(), style: pw.TextStyle(font: regularFont, fontSize: 10));
      }
      final values = dataList.map((d) => d[key] ?? 0).toList();
      final total = values.fold(0, (sum, v) => sum + v);
      
      List<pw.Widget> children = [];
      for (int i = 0; i < values.length; i++) {
        children.add(
          pw.Container(
            width: 14,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(values[i].toString(), style: pw.TextStyle(font: regularFont, fontSize: 10)),
          ),
        );
        if (i < values.length - 1) {
          children.add(
            pw.Container(
              width: 12,
              alignment: pw.Alignment.center,
              child: pw.Text('+', style: pw.TextStyle(font: regularFont, fontSize: 10)),
            ),
          );
        }
      }
      children.add(
        pw.Container(
          width: 12,
          alignment: pw.Alignment.center,
          child: pw.Text('=', style: pw.TextStyle(font: regularFont, fontSize: 10)),
        ),
      );
      children.add(
        pw.Container(
          width: 20,
          alignment: pw.Alignment.centerRight,
          child: pw.Text(total.toString(), style: pw.TextStyle(font: regularFont, fontSize: 10)),
        ),
      );
      
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: children,
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          21.5 * PdfPageFormat.cm,
          33.0 * PdfPageFormat.cm,
        ), // Portrait F4
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              'PROFIL KEPENDUDUKAN',
              style: pw.TextStyle(font: boldFont, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
              style: pw.TextStyle(font: regularFont, fontSize: 12),
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'NAMA',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $namaKader',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kelompok',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $namaKelompok',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'RT / RW',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $rt / $rw',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kelurahan',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $kelurahan',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kecamatan',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $kecamatan',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kota',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': $kota',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 100,
                  child: pw.Text(
                    'BULAN & THN',
                    style: pw.TextStyle(font: regularFont, fontSize: 10),
                  ),
                ),
                pw.Text(
                  ': $bulanTahun',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Tabel Profil Umur Ringkasan (Portrait)
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
              child: pw.Column(
                children: [
                  // Header
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'UMUR',
                        flex: 2,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                      buildCell(
                        'P',
                        flex: 2,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                      buildCell(
                        'W',
                        flex: 2,
                        isHeader: true,
                        noRightBorder: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                    ],
                  ),
                  // Rows with per-kelompok breakdown
                  ...List.generate(ageGroups.length, (i) {
                    final pBreakdown = buildBreakdown(
                      perKelompokData,
                      '${prefixList[i]}_P',
                    );
                    final wBreakdown = buildBreakdown(
                      perKelompokData,
                      '${prefixList[i]}_W',
                    );
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(ageGroups[i], flex: 2, bottomBorder: true),
                        buildCell(pBreakdown, flex: 2, bottomBorder: true, alignment: pw.Alignment.center),
                        buildCell(
                          wBreakdown,
                          flex: 2,
                          noRightBorder: true,
                          bottomBorder: true,
                          alignment: pw.Alignment.center,
                        ),
                      ],
                    );
                  }),
                  // Footer (TOTAL) with breakdown
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'TOTAL',
                        flex: 2,
                        isHeader: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                      buildCell(
                        buildBreakdown(perKelompokData, 'total_P'),
                        flex: 2,
                        backgroundColor: PdfColors.yellow,
                        alignment: pw.Alignment.center,
                      ),
                      buildCell(
                        buildBreakdown(perKelompokData, 'total_W'),
                        flex: 2,
                        noRightBorder: true,
                        backgroundColor: PdfColors.yellow,
                        alignment: pw.Alignment.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateLampidPdfRingkasan({
    required String namaKelompok,
    required List<Map<String, dynamic>> mutasiList,
    required String rt,
    required String rw,
    required String kelurahan,
    required String bulan,
    required String tahun,
  }) async {
    final filteredMutasiList = mutasiList.where((row) {
      final jenisMutasi = row['jenis_mutasi']?.toString().toUpperCase() ?? '';
      if (jenisMutasi == 'LAHIR') return true;
      if (jenisMutasi.contains('IBU') || jenisMutasi.contains('HAMIL')) return true;
      
      if (jenisMutasi == 'MENINGGAL') {
        bool isBayiOrBalita = false;
        final tglLahirStr = row['tanggal_lahir']?.toString();
        if (tglLahirStr != null && tglLahirStr.isNotEmpty) {
          try {
            final tglLahir = DateTime.parse(tglLahirStr);
            final tglMutasiStr = row['tanggal_mutasi']?.toString();
            final tglMutasi = tglMutasiStr != null && tglMutasiStr.isNotEmpty 
                ? DateTime.parse(tglMutasiStr) 
                : DateTime.now();
            final ageInDays = tglMutasi.difference(tglLahir).inDays;
            if (ageInDays <= (5 * 365 + 2)) {
              isBayiOrBalita = true;
            }
          } catch (_) {}
        }
        
        final hub = row['hubungan_keluarga']?.toString().toUpperCase() ?? '';
        final statusKrt = row['status_dgn_krt']?.toString().toUpperCase() ?? '';
        final isIstri = hub == 'ISTRI' || statusKrt == 'ISTRI';
        
        if (isBayiOrBalita || isIstri) {
          return true;
        }

        final keterangan = row['keterangan']?.toString().toUpperCase() ?? '';
        if (keterangan.contains('HAMIL') || keterangan.contains('MELAHIRKAN') || keterangan.contains('NIFAS') || keterangan.contains('IBU')) {
          return true;
        }
      }
      return false;
    }).toList();

    final pdf = pw.Document();

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();

    pw.Widget buildCell(
      String text, {
      double? width,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(2),
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
            fontSize: fontSize ?? (isHeader ? 6 : 8),
          ),
        ),
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ), // Landscape F4
        margin: const pw.EdgeInsets.all(32), // 1.1 cm margin
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'REKAPITULASI DATA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'IBU HAMIL, MELAHIRKAN, NIFAS, IBU MENINGGAL , KELAHIRAN BAYI, BAYI MENINGGAL , DAN KEMATIAN BALITA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.SizedBox(height: 16),

              // Header Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 140,
                            child: pw.Text(
                              'KELOMPOK DASAWISMA',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 250,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              namaKelompok,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 140,
                            child: pw.Text(
                              'KELOMPOK PKK RT',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 250,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              rt,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 140,
                            child: pw.Text(
                              'KELOMPOK PKK RW',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 250,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              rw,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 140,
                            child: pw.Text(
                              'KELURAHAN / DESA',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 250,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              kelurahan,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 60,
                            child: pw.Text(
                              'BULAN',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 100,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              bulan,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 60,
                            child: pw.Text(
                              'TAHUN',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 100,
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                              left: 4,
                            ),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                            child: pw.Text(
                              tahun,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Tabel Data
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 40,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('NO', flex: 1, isHeader: true),
                          buildCell('NAMA IBU', flex: 3, isHeader: true),
                          buildCell('NAMA\nSUAMI', flex: 3, isHeader: true),
                          buildCell(
                            'STATUS ( HAMIL /\nMELAHIRKAN\n/NIFAS',
                            flex: 4,
                            isHeader: true,
                            fontSize: 6,
                          ),

                          // CATATAN KELAHIRAN
                          pw.Expanded(
                            flex: 10,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell(
                                    'CATATAN KELAHIRAN',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
                                      children: [
                                        buildCell(
                                          'NAMA BAYI',
                                          flex: 4,
                                          isHeader: true,
                                          fontSize: 6,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                right: pw.BorderSide(
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'JENIS\nKELAMIN',
                                                  flex: 3,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 6,
                                                ),
                                                pw.Expanded(
                                                  flex: 2,
                                                  child: pw.Row(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      buildCell(
                                                        'L',
                                                        flex: 1,
                                                        isHeader: true,
                                                        fontSize: 6,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        buildCell(
                                          'TGL\nLAHIR',
                                          flex: 2,
                                          isHeader: true,
                                          fontSize: 6,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'AKTE\nKELAHIRAN',
                                                  flex: 3,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 6,
                                                ),
                                                pw.Expanded(
                                                  flex: 2,
                                                  child: pw.Row(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      buildCell(
                                                        'ADA',
                                                        flex: 1,
                                                        isHeader: true,
                                                        fontSize: 6,
                                                      ),
                                                      buildCell(
                                                        'TIDAK',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // CATATAN KEMATIAN
                          pw.Expanded(
                            flex: 12,
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell(
                                    'CATATAN KEMATIAN',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                  ),
                                  pw.Expanded(
                                    flex: 2,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
                                      children: [
                                        buildCell(
                                          'NAMA IBU/\nBALITA / BAYI',
                                          flex: 3,
                                          isHeader: true,
                                          fontSize: 6,
                                        ),
                                        buildCell(
                                          'STATUS (IBU/\nBAYI/BALITA)',
                                          flex: 3,
                                          isHeader: true,
                                          fontSize: 6,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                right: pw.BorderSide(
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'JENIS\nKELAMIN',
                                                  flex: 3,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 6,
                                                ),
                                                pw.Expanded(
                                                  flex: 2,
                                                  child: pw.Row(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      buildCell(
                                                        'L',
                                                        flex: 1,
                                                        isHeader: true,
                                                        fontSize: 6,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        buildCell(
                                          'TGL MENINGGAL',
                                          flex: 2,
                                          isHeader: true,
                                          fontSize: 6,
                                        ),
                                        buildCell(
                                          'SEBAB\nMENINGGAL',
                                          flex: 2,
                                          isHeader: true,
                                          noRightBorder: true,
                                          fontSize: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          buildCell(
                            'KETERANGAN',
                            flex: 3,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 6,
                          ),
                        ],
                      ),
                    ),

                    // Row 2: Sub Headers (Column Numbers)
                    pw.Container(
                      height: 12,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('1', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('2', flex: 3, isHeader: true, fontSize: 6),
                          buildCell('3', flex: 3, isHeader: true, fontSize: 6),
                          buildCell('4', flex: 4, isHeader: true, fontSize: 6),
                          buildCell('5', flex: 4, isHeader: true, fontSize: 6),
                          buildCell('6', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('7', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('8', flex: 2, isHeader: true, fontSize: 6),
                          buildCell('9', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('10', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('11', flex: 3, isHeader: true, fontSize: 6),
                          buildCell('12', flex: 3, isHeader: true, fontSize: 6),
                          buildCell('13', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('14', flex: 1, isHeader: true, fontSize: 6),
                          buildCell('15', flex: 2, isHeader: true, fontSize: 6),
                          buildCell('16', flex: 2, isHeader: true, fontSize: 6),
                          buildCell(
                            '17',
                            flex: 3,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 6,
                          ),
                        ],
                      ),
                    ),

                    // Data Rows
                    ...List.generate(filteredMutasiList.length < 12 ? 12 : filteredMutasiList.length, (index) {
                      if (index >= filteredMutasiList.length) {
                        return pw.Container(
                          height: 18,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell('', flex: 1, fontSize: 7),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 4),
                              buildCell('', flex: 4),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 2),
                              buildCell('', flex: 3, noRightBorder: true),
                            ],
                          ),
                        );
                      }
                      final int i = index + 1;
                      final row = filteredMutasiList[index];

                      final jenisMutasi = row['jenis_mutasi']?.toString() ?? '';
                      final isKelahiran = jenisMutasi.toUpperCase() == 'LAHIR';
                      final isKematian =
                          jenisMutasi.toUpperCase() == 'MENINGGAL';
                      final isIbu =
                          jenisMutasi.toUpperCase().contains('IBU') ||
                          jenisMutasi.toUpperCase().contains('HAMIL');

                      final namaIbu = row['nama_ibu']?.toString() ?? '';
                      final namaSuami = row['nama_suami']?.toString() ?? '';
                      final statusIbu = isIbu
                          ? (row['status_ibu']?.toString() ?? jenisMutasi)
                          : '';

                      final namaAnak = isKelahiran
                          ? (row['nama_orang']?.toString() ?? '')
                          : '';
                      final jkLahirL =
                          isKelahiran && row['jenis_kelamin'] == 'L' ? 'V' : '';
                      final jkLahirP =
                          isKelahiran && row['jenis_kelamin'] == 'P' ? 'V' : '';
                      final tglLahir = isKelahiran
                          ? (row['tanggal_mutasi']?.toString() ?? '')
                          : '';
                      final akteAda = ''; // Placeholder
                      final akteTidak = ''; // Placeholder

                      final namaMeninggal = isKematian
                          ? (row['nama_orang']?.toString() ?? '')
                          : '';
                      
                      String statusMeninggal = '';
                      if (isKematian) {
                        final tglLahirStr = row['tanggal_lahir']?.toString();
                        if (tglLahirStr != null && tglLahirStr.isNotEmpty) {
                          try {
                            final tglLahir = DateTime.parse(tglLahirStr);
                            final tglMutasiStr = row['tanggal_mutasi']?.toString();
                            final tglMutasi = tglMutasiStr != null && tglMutasiStr.isNotEmpty 
                                ? DateTime.parse(tglMutasiStr) 
                                : DateTime.now();
                            final ageInDays = tglMutasi.difference(tglLahir).inDays;
                            if (ageInDays < 365) {
                              statusMeninggal = 'Bayi';
                            } else if (ageInDays < (5 * 365 + 2)) {
                              statusMeninggal = 'Balita';
                            }
                          } catch (_) {}
                        }
                        
                        if (statusMeninggal.isEmpty) {
                          final hub = row['hubungan_keluarga']?.toString().toUpperCase() ?? '';
                          final statusKrt = row['status_dgn_krt']?.toString().toUpperCase() ?? '';
                          if (hub == 'ISTRI' || statusKrt == 'ISTRI') {
                            statusMeninggal = 'Ibu';
                          } else {
                            final keterangan = row['keterangan']?.toString().toUpperCase() ?? '';
                            if (keterangan.contains('HAMIL') || keterangan.contains('MELAHIRKAN') || keterangan.contains('NIFAS') || keterangan.contains('IBU')) {
                              statusMeninggal = 'Ibu';
                            }
                          }
                        }
                      }
                      final jkMatiL = isKematian && row['jenis_kelamin'] == 'L'
                          ? 'V'
                          : '';
                      final jkMatiP = isKematian && row['jenis_kelamin'] == 'P'
                          ? 'V'
                          : '';
                      final tglMeninggal = isKematian
                          ? (row['tanggal_mutasi']?.toString() ?? '')
                          : '';
                      final sebabMeninggal = isKematian
                          ? (row['sebab_kematian']?.toString() ?? '')
                          : '';

                      final ket = row['keterangan']?.toString() ?? '';

                      return pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('$i', flex: 1, fontSize: 7),
                            buildCell(namaIbu, flex: 3),
                            buildCell(namaSuami, flex: 3),
                            buildCell(statusIbu, flex: 4),
                            buildCell(namaAnak, flex: 4),
                            buildCell(jkLahirL, flex: 1),
                            buildCell(jkLahirP, flex: 1),
                            buildCell(tglLahir, flex: 2),
                            buildCell(akteAda, flex: 1),
                            buildCell(akteTidak, flex: 1),
                            buildCell(namaMeninggal, flex: 3),
                            buildCell(statusMeninggal, flex: 3),
                            buildCell(jkMatiL, flex: 1),
                            buildCell(jkMatiP, flex: 1),
                            buildCell(tglMeninggal, flex: 2),
                            buildCell(sebabMeninggal, flex: 2),
                            buildCell(ket, flex: 3, noRightBorder: true),
                          ],
                        ),
                      );
                    }),



                    // JUMLAH Row
                    pw.Container(
                      height: 18,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            flex: 4, // NO(1)+NAMA IBU(3)
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                'JUMLAH',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          buildCell('', flex: 3), // NAMA SUAMI
                          buildCell('', flex: 4), // STATUS
                          buildCell('', flex: 4),
                          buildCell('', flex: 1),
                          buildCell('', flex: 1),
                          buildCell('', flex: 2),
                          buildCell('', flex: 1),
                          buildCell('', flex: 1),
                          buildCell('', flex: 3),
                          buildCell('', flex: 3),
                          buildCell('', flex: 1),
                          buildCell('', flex: 1),
                          buildCell('', flex: 2),
                          buildCell('', flex: 2),
                          buildCell('', flex: 3, noRightBorder: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Catatan
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Catatan :',
                      style: pw.TextStyle(font: regularFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '1. Jumlah Ibu Hamil',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '2. Jumlah Ibu Melahirkan',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '3. Jumlah Ibu Nifas',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '4. Jumlah Ibu Meninggal',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '5. Jumlah Bayi lahir',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '6. Jumlah Bayi Meninggal',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '7. Jumlah Balita Meninggal',
                            style: pw.TextStyle(font: regularFont, fontSize: 7),
                          ),
                        ),
                        pw.Text(
                          ':  0     orang',
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '*Ibu meninggal karena hamil/melahirkan/nifas',
                      style: pw.TextStyle(font: regularFont, fontSize: 7),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// =========================================================================
  /// FORM I: PENETAPAN SASARAN PENDATAAN (TEMPLATE KOSONG)
  /// Format: Portrait
  /// =========================================================================
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}