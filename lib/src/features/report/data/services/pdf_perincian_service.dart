// ignore_for_file: unused_element, unused_import, unused_local_variable
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPerincianService {
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

  Future<Uint8List> generateForm3Perincian({
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
      'Balita\\n(0-5 Thn)',
      'Anak\\n(6-9 Thn)',
      'Remaja\\n(10-24 Thn)',
      'Dewasa\\n(25-59 Thn)',
      'Lansia\\n(60+ Thn)',
      'Jumlah\\nKeluarga',
      'Jumlah\\nPasangan\\nUsia Subur\\n(PUS)',
      'MOW/Steril\\nWanita',
      'MOP/Steril\\nPria',
      'IUD/Spiral\\nAKDR',
      'Implant/\\nSusuk',
      'Suntik',
      'Pil',
      'Kondom',
      'Jumlah\\nPeserta KB',
      'TIAL',
      'IAT',
      'IAS',
      'Hamil',
      'Jumlah Bukan\\nPeserta KB',
    ];

    final style = pw.TextStyle(font: boldFont, fontSize: 6);
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

    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          headerCell('NO', 1),
          headerCell('NAMA KRT', 3),
          headerCell('NAMA KEPALA KELUARGA', 4),
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
        pageFormat: const PdfPageFormat(13 * PdfPageFormat.inch, 8.5 * PdfPageFormat.inch), // F4 / Folio
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
              pw.Container(
                child: pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: columnWidths,
                  children: [
                    pw.TableRow(
                      children: List.generate(
                        26,
                        (i) => pw.Container(
                          height: 10,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${i + 1}',
                            style: pw.TextStyle(font: regularFont, fontSize: 6),
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
            tKrt += (r['namaKrt'] as String).isNotEmpty ? 1 : 0;
            tKk += (r['namaKk'] as String).isNotEmpty ? 1 : 0;
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

  Future<Uint8List> generateProfilPendudukPdf({
    required String namaKelompok,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
    required String provinsi,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pw.Widget buildCell(
      String text, {
      double? width,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
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
          style: isHeader
              ? pw.TextStyle(font: fontBold, fontSize: 6)
              : pw.TextStyle(font: font, fontSize: 6),
        ),
      );

      if (flex != null) {
        return pw.Expanded(flex: flex, child: content);
      }
      return content;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'PROFIL PENDUDUK',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Kelompok Dasawisma: $namaKelompok',
              style: pw.TextStyle(font: fontBold),
            ),
            pw.Text('RT/RW: $rt/$rw', style: pw.TextStyle(font: font)),
            pw.Text('Kelurahan/Desa: $desa', style: pw.TextStyle(font: font)),
            pw.Text('Kecamatan: $kecamatan', style: pw.TextStyle(font: font)),
            pw.Text(
              'Kabupaten/Kota: $kabupaten',
              style: pw.TextStyle(font: font),
            ),
            pw.Text('Provinsi: $provinsi', style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    buildCell('No', flex: 1, isHeader: true),
                    buildCell('Nama Lengkap', flex: 4, isHeader: true),
                    buildCell('NIK', flex: 3, isHeader: true),
                    buildCell('Jenis Kelamin', flex: 3, isHeader: true),
                    buildCell('Tempat Lahir', flex: 3, isHeader: true),
                    buildCell('Tanggal Lahir', flex: 3, isHeader: true),
                    buildCell('Agama', flex: 2, isHeader: true),
                    buildCell('Pendidikan', flex: 3, isHeader: true),
                    buildCell(
                      'Pekerjaan',
                      flex: 3,
                      isHeader: true,
                      noRightBorder: true,
                    ),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      buildCell(index.toString(), flex: 1, bottomBorder: true),
                      buildCell(
                        item['nama_orang']?.toString() ?? '',
                        flex: 4,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['nik']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['jk']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['tempat_lahir']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['tgl_lahir']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['agama']?.toString() ?? '',
                        flex: 2,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['pendidikan']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['pekerjaan']?.toString() ?? '',
                        flex: 3,
                        bottomBorder: true,
                        noRightBorder: true,
                      ),
                    ],
                  );
                }),
                if (data.isEmpty)
                  pw.TableRow(
                    children: [
                      buildCell(
                        'Tidak ada data',
                        flex: 25,
                        bottomBorder: true,
                        noRightBorder: true,
                      ),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// =========================================================================
  /// FORM PROFIL KEPENDUDUKAN - RINGKASAN (TERISI)
  /// Format: Portrait, F4
  /// =========================================================================

  Future<Uint8List> generateYatimPiatuPdf({
    required String namaKelompok,
    required String rt,
    required String rw,
    required String desa,
    required String kecamatan,
    required String kabupaten,
    required String provinsi,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pw.Widget buildCell(
      String text, {
      double? width,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
    }) {
      return pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(2),
        alignment: pw.Alignment.center,
        // no custom borders since pw.TableBorder.all is used
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: isHeader
              ? pw.TextStyle(font: fontBold, fontSize: 6)
              : pw.TextStyle(font: font, fontSize: 6),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'DATA ANAK YATIM PIATU',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 120,
                            child: pw.Text(
                              'Kelompok Dasawisma',
                              style: pw.TextStyle(font: fontBold, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: fontBold, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              namaKelompok,
                              style: pw.TextStyle(font: fontBold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 120,
                            child: pw.Text(
                              'RT/RW',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '$rt/$rw',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 120,
                            child: pw.Text(
                              'Kelurahan/Desa',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              desa,
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kecamatan',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              kecamatan,
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Kabupaten/Kota',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              kabupaten,
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Provinsi',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              provinsi,
                              style: pw.TextStyle(font: font, fontSize: 10),
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
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(3),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(4),
                6: pw.FlexColumnWidth(3),
                7: pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    buildCell('No', isHeader: true),
                    buildCell('Nama', isHeader: true),
                    buildCell('NIK', isHeader: true),
                    buildCell('Umur', isHeader: true),
                    buildCell('L/P', isHeader: true),
                    buildCell('Alamat', isHeader: true),
                    buildCell('Nama Wali', isHeader: true),
                    buildCell(
                      'Status Yatim Piatu',
                      isHeader: true,
                      noRightBorder: true,
                    ),
                  ],
                ),
                ...data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      buildCell(index.toString(), bottomBorder: true),
                      buildCell(
                        item['nama_orang']?.toString() ?? '',
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['nik']?.toString() ?? '',
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['umur']?.toString() ?? '',
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['jk'] == 'Laki-laki'
                            ? 'L'
                            : (item['jk'] == 'Perempuan' ? 'P' : ''),
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['alamat']?.toString() ?? '',
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['nama_wali']?.toString() ?? '',
                        bottomBorder: true,
                      ),
                      buildCell(
                        item['status_yatim_piatu']?.toString() ?? '',
                        bottomBorder: true,
                        noRightBorder: true,
                      ),
                    ],
                  );
                }),
                ...List.generate(data.length < 15 ? 15 - data.length : 0, (
                  index,
                ) {
                  final emptyIndex = data.length + index + 1;
                  return pw.TableRow(
                    children: [
                      buildCell(emptyIndex.toString(), bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true),
                      buildCell('', bottomBorder: true, noRightBorder: true),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateRekapPkkPerincianPdf({
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

    final style = pw.TextStyle(font: boldFont, fontSize: 5);
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

    // === TABLE HEADER (30 columns matching reference, 3-level structure) ===
    // Flex values computed from columnWidths * 10 to ensure alignment.
    // Group sums:
    // JUMLAH ANGGOTA KELUARGA: cols 3-12 = 2+2+2+2+2+2+2+2.5+2+2 = 20.5 → flex 205
    // KRITERIA RUMAH: cols 13-19 = 2.5+2+2.5+2.5+2+2+2.5 = 16 → flex 160
    // SUMBER AIR: cols 20-22 = 2+2+2 = 6 → flex 60
    // MAKANAN POKOK: cols 23-24 = 2+2 = 4 → flex 40
    // WARGA MENGIKUTI: cols 25-28 = 2+2.5+2.5+2 = 9 → flex 90
    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // NO (col 0: 1.5 → flex 15)
          pw.Expanded(
            flex: 15,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Center(child: pw.Text('NO', style: style)),
            ),
          ),
          // NAMA KEPALA RUMAH TANGGA (col 1: 10 → flex 100)
          pw.Expanded(
            flex: 100,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Center(
                child: pw.Text(
                  'NAMA KEPALA RUMAH\nTANGGA',
                  style: style,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ),
          // JML KK (col 2: 2 → flex 20)
          pw.Expanded(
            flex: 20,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Center(
                child: pw.Text(
                  'JML\nKK',
                  style: style,
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ),
          // JUMLAH ANGGOTA KELUARGA (cols 3-12, total flex 205)
          pw.Expanded(
            flex: 205,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  // Level 1: Group header
                  pw.Container(
                    height: 10,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('JUMLAH ANGGOTA KELUARGA', style: style),
                    ),
                  ),
                  // Level 2 + 3
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // TOTAL group (cols 3-4, sum=4 → flex 40)
                        pw.Expanded(
                          flex: 40,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border: borderBottom,
                                  ),
                                  child: pw.Center(
                                    child: pw.Text('TOTAL', style: style),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.stretch,
                                    children: [
                                      pw.Expanded(
                                        flex: 20,
                                        child: pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: borderRight,
                                          ),
                                          child: pw.Center(
                                            child: pw.Text('L', style: style),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 20,
                                        child: pw.Container(
                                          child: pw.Center(
                                            child: pw.Text('P', style: style),
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
                        // BALITA group (cols 5-6, sum=4 → flex 40)
                        pw.Expanded(
                          flex: 40,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border: borderBottom,
                                  ),
                                  child: pw.Center(
                                    child: pw.Text('BALITA', style: style),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.stretch,
                                    children: [
                                      pw.Expanded(
                                        flex: 20,
                                        child: pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: borderRight,
                                          ),
                                          child: pw.Center(
                                            child: pw.Text('L', style: style),
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 20,
                                        child: pw.Container(
                                          child: pw.Center(
                                            child: pw.Text('P', style: style),
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
                        // PUS (col 7: 2 → flex 20)
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('PUS', style: style),
                            ),
                          ),
                        ),
                        // WUS (col 8: 2 → flex 20)
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('WUS', style: style),
                            ),
                          ),
                        ),
                        // IBU HAMIL (col 9: 2 → flex 20)
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'IBU\nHAMIL',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // IBU MENYUSUI (col 10: 2.5 → flex 25)
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'IBU\nMENYU\nSUI',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // LANSIA (col 11: 2 → flex 20)
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'LAN\nSIA',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // 3 BUTA (col 12: 2 → flex 20, no right border - last in group)
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            child: pw.Center(
                              child: pw.Text(
                                '3\nBUTA',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
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
          // KRITERIA RUMAH (cols 13-19, total flex 160)
          pw.Expanded(
            flex: 160,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 10,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'RUMAH/\nBANGU\nNAN\nKHUSUS',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'SEHAT\nLAYAK\nHUNI',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'TIDAK\nSEHAT\nLAYAK\nHUNI',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'MEMILIKI\nTMP.\nPEMB.\nSAMPAH',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'MEMI\nLIKI\nJAMBAN',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'MEMI\nLIKI\nSPAL',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            child: pw.Center(
                              child: pw.Text(
                                'MENEMPEL\nSTIKER\nP4K',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
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
          // SUMBER AIR KELUARGA (cols 20-22, total flex 60)
          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 10,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('PDAM', style: style),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('SUMUR', style: style),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            child: pw.Center(
                              child: pw.Text('DLL', style: style),
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
          // MAKANAN POKOK (cols 23-24, total flex 40)
          pw.Expanded(
            flex: 40,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 10,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('BERAS', style: style),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            child: pw.Center(
                              child: pw.Text(
                                'NON\nBERAS',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
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
          // WARGA MENGIKUTI KEGIATAN (cols 25-28, total flex 90)
          pw.Expanded(
            flex: 90,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 10,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text('UP2K', style: style),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'PEMAN\nFAATAN\nTANAH\nPEKA\nRANGAN',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 25,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(border: borderRight),
                            child: pw.Center(
                              child: pw.Text(
                                'INDUSTRI\nRUMAH\nTANGGA',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 20,
                          child: pw.Container(
                            child: pw.Center(
                              child: pw.Text(
                                'KERJA\nBAKTI',
                                style: style,
                                textAlign: pw.TextAlign.center,
                              ),
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
          // KET (col 29: 3 → flex 30)
          pw.Expanded(
            flex: 30,
            child: pw.Container(
              child: pw.Center(child: pw.Text('KET', style: style)),
            ),
          ),
        ],
      ),
    );

    // === COLUMN WIDTHS (30 columns) ===
    // Menggunakan FlexColumnWidth yang tersinkronisasi dengan flex pada header.
    // Lebar NAMA KRT diperbesar rasionya agar saat dicetak di F4 tidak mepet,
    // sedangkan kolom isian data (flex 2) akan menjadi lebih ramping.
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.5), // NO
      1: const pw.FlexColumnWidth(10), // NAMA KRT (diperbesar dari 5 ke 10)
      2: const pw.FlexColumnWidth(2), // JML KK
      3: const pw.FlexColumnWidth(2), // TOTAL L
      4: const pw.FlexColumnWidth(2), // TOTAL P
      5: const pw.FlexColumnWidth(2), // BALITA L
      6: const pw.FlexColumnWidth(2), // BALITA P
      7: const pw.FlexColumnWidth(2), // PUS
      8: const pw.FlexColumnWidth(2), // WUS
      9: const pw.FlexColumnWidth(2), // IBU HAMIL
      10: const pw.FlexColumnWidth(2.5), // IBU MENYUSUI
      11: const pw.FlexColumnWidth(2), // LANSIA
      12: const pw.FlexColumnWidth(2), // 3 BUTA
      13: const pw.FlexColumnWidth(2.5), // RUMAH BANGUNAN KHUSUS
      14: const pw.FlexColumnWidth(2), // SEHAT LAYAK HUNI
      15: const pw.FlexColumnWidth(2.5), // TIDAK SEHAT LAYAK HUNI
      16: const pw.FlexColumnWidth(2.5), // MEMILIKI TMP SAMPAH
      17: const pw.FlexColumnWidth(2), // MEMILIKI JAMBAN
      18: const pw.FlexColumnWidth(2), // MEMILIKI SPAL
      19: const pw.FlexColumnWidth(2.5), // TEMPEL STIKER P4K
      20: const pw.FlexColumnWidth(2), // PDAM
      21: const pw.FlexColumnWidth(2), // SUMUR
      22: const pw.FlexColumnWidth(2), // DLL
      23: const pw.FlexColumnWidth(2), // BERAS
      24: const pw.FlexColumnWidth(2), // NON BERAS
      25: const pw.FlexColumnWidth(2), // UP2K
      26: const pw.FlexColumnWidth(2.5), // PEKARANGAN
      27: const pw.FlexColumnWidth(2.5), // INDUSTRI RT
      28: const pw.FlexColumnWidth(2), // KERJA BAKTI
      29: const pw.FlexColumnWidth(3), // KET
    };

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(13 * PdfPageFormat.inch, 8.5 * PdfPageFormat.inch), // Ukuran F4 / Folio
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'REKAPITULASI\nCATATAN DATA DAN KEGIATAN WARGA\nKELOMPOK DASAWISMA',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Padding(
                padding: const pw.EdgeInsets.only(
                  left: 275,
                ), // Geser ke kiri sejajar kata CATATAN
                child: pw.Container(
                  width: 500,
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(130),
                      1: const pw.FixedColumnWidth(15),
                      2: const pw.FixedColumnWidth(355),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text(
                            'DASA WISMA',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            namaKelompok,
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text(
                            'RT',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            rt,
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text(
                            'RW',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            rw,
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text(
                            'DESA / KELURAHAN',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            desa,
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text(
                            'TAHUN',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            '${data['tahun'] ?? ''}',
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
              ),
              pw.SizedBox(height: 16),
              pw.Container(height: 50, child: tableHeaderWidget),
              pw.Container(
                child: pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: columnWidths,
                  children: [
                    pw.TableRow(
                      children: List.generate(
                        30,
                        (i) => pw.Container(
                          height: 10,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${i + 1}',
                            style: pw.TextStyle(font: regularFont, fontSize: 5),
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
          int tKk = 0, tL = 0, tP = 0, tBalitaL = 0, tBalitaP = 0;
          int tPus = 0, tWus = 0, tHamil = 0, tMenyusui = 0;
          int tLansia = 0, tButa = 0, tBerkebutuhan = 0;
          int tSehat = 0, tTidakSehat = 0, tSampah = 0;
          int tJamban = 0, tSpal = 0, tStiker = 0;
          int tPdam = 0, tSumur = 0, tDll = 0;
          int tBeras = 0, tNonBeras = 0;
          int tUp2k = 0, tPekarangan = 0, tIndustri = 0, tKerja = 0;

          List<pw.TableRow> tableRows = [];
          for (int i = 0; i < rows.length; i++) {
            final r = rows[i];
            tKk += r['jmlKk'] as int? ?? 0;
            tL += r['jiwaLaki'] as int? ?? 0;
            tP += r['jiwaPerempuan'] as int? ?? 0;
            tBalitaL += r['balitaLaki'] as int? ?? 0;
            tBalitaP += r['balitaPerempuan'] as int? ?? 0;
            tPus += r['pus'] as int? ?? 0;
            tWus += r['wus'] as int? ?? 0;
            tHamil += r['ibuHamil'] as int? ?? 0;
            tMenyusui += r['ibuMenyusui'] as int? ?? 0;
            tLansia += r['lansia'] as int? ?? 0;
            tButa += r['buta'] as int? ?? 0;
            tBerkebutuhan += r['berkebutuhanKhusus'] as int? ?? 0;
            tSehat += r['rumahSehat'] as int? ?? 0;
            tTidakSehat += r['rumahTidakSehat'] as int? ?? 0;
            tSampah += r['punyaTempatSampah'] as int? ?? 0;
            tJamban += r['punyaJamban'] as int? ?? 0;
            tSpal += r['punyaSpal'] as int? ?? 0;
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

            pw.Widget cell(
              String text, {
              pw.Alignment align = pw.Alignment.center,
            }) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(2),
                alignment: align,
                child: pw.Text(
                  text,
                  style: pw.TextStyle(font: regularFont, fontSize: 5),
                ),
              );
            }

            tableRows.add(
              pw.TableRow(
                children: [
                  cell('${i + 1}'),
                  cell('${r['namaKrt'] ?? ''}', align: pw.Alignment.centerLeft),
                  cell('${r['jmlKk'] ?? 0}'),
                  cell('${r['jiwaLaki'] ?? 0}'),
                  cell('${r['jiwaPerempuan'] ?? 0}'),
                  cell('${r['balitaLaki'] ?? 0}'),
                  cell('${r['balitaPerempuan'] ?? 0}'),
                  cell('${r['pus'] ?? 0}'),
                  cell('${r['wus'] ?? 0}'),
                  cell('${r['ibuHamil'] ?? 0}'),
                  cell('${r['ibuMenyusui'] ?? 0}'),
                  cell('${r['lansia'] ?? 0}'),
                  cell('${r['buta'] ?? 0}'),
                  cell('${r['berkebutuhanKhusus'] ?? 0}'),
                  cell('${r['rumahSehat'] ?? 0}'),
                  cell('${r['rumahTidakSehat'] ?? 0}'),
                  cell('${r['punyaTempatSampah'] ?? 0}'),
                  cell('${r['punyaJamban'] ?? 0}'),
                  cell('${r['punyaSpal'] ?? 0}'),
                  cell('${r['tempelStiker'] ?? 0}'),
                  cell('${r['sumberAirPdam'] ?? 0}'),
                  cell('${r['sumberAirSumur'] ?? 0}'),
                  cell('${r['sumberAirLainnya'] ?? 0}'),
                  cell('${r['makananBeras'] ?? 0}'),
                  cell('${r['makananNonBeras'] ?? 0}'),
                  cell('${r['ikutUp2k'] ?? 0}'),
                  cell('${r['pekarangan'] ?? 0}'),
                  cell('${r['industriRT'] ?? 0}'),
                  cell('${r['kerjaBakti'] ?? 0}'),
                  cell('${r['keterangan'] ?? ''}'),
                ],
              ),
            );
          }

          // Jumlah row
          pw.Widget totalCell(String text) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(2),
              alignment: pw.Alignment.center,
              child: pw.Text(
                text,
                style: pw.TextStyle(font: boldFont, fontSize: 5),
              ),
            );
          }

          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.yellow),
              children: [
                totalCell(''),
                totalCell('JUMLAH'),
                totalCell('$tKk'),
                totalCell('$tL'),
                totalCell('$tP'),
                totalCell('$tBalitaL'),
                totalCell('$tBalitaP'),
                totalCell('$tPus'),
                totalCell('$tWus'),
                totalCell('$tHamil'),
                totalCell('$tMenyusui'),
                totalCell('$tLansia'),
                totalCell('$tButa'),
                totalCell('$tBerkebutuhan'),
                totalCell('$tSehat'),
                totalCell('$tTidakSehat'),
                totalCell('$tSampah'),
                totalCell('$tJamban'),
                totalCell('$tSpal'),
                totalCell('$tStiker'),
                totalCell('$tPdam'),
                totalCell('$tSumur'),
                totalCell('$tDll'),
                totalCell('$tBeras'),
                totalCell('$tNonBeras'),
                totalCell('$tUp2k'),
                totalCell('$tPekarangan'),
                totalCell('$tIndustri'),
                totalCell('$tKerja'),
                totalCell(''),
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

  Future<Uint8List> generateProfilUsiaPdf({
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
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
      String text, {
      double? width,
      double? height,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
      PdfColor? backgroundColor,
      pw.Alignment alignment = pw.Alignment.center,
    }) {
      final content = pw.Container(
        width: width,
        height: height,
        padding: const pw.EdgeInsets.all(1),
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
        child: pw.Text(
          text,
          textAlign: alignment == pw.Alignment.centerLeft
              ? pw.TextAlign.left
              : pw.TextAlign.center,
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

    final ageGroups = [
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

    final prefixList = [
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

    Map<String, int> sums = {};
    for (var prefix in prefixList) {
      sums['${prefix}_P'] = 0;
      sums['${prefix}_W'] = 0;
    }
    sums['total_P'] = 0;
    sums['total_W'] = 0;

    for (var r in data) {
      for (var prefix in prefixList) {
        sums['${prefix}_P'] =
            (sums['${prefix}_P']!) +
            (int.tryParse(r['${prefix}_P']?.toString() ?? '0') ?? 0);
        sums['${prefix}_W'] =
            (sums['${prefix}_W']!) +
            (int.tryParse(r['${prefix}_W']?.toString() ?? '0') ?? 0);
      }
      sums['total_P'] =
          (sums['total_P']!) +
          (int.tryParse(r['total_P']?.toString() ?? '0') ?? 0);
      sums['total_W'] =
          (sums['total_W']!) +
          (int.tryParse(r['total_W']?.toString() ?? '0') ?? 0);
    }

    // ==========================================
    // PAGE 1: PORTRAIT
    // ==========================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          21.5 * PdfPageFormat.cm,
          33.0 * PdfPageFormat.cm,
        ),
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
                            ': ',
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

            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
              child: pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'UMUR',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'P',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        'W',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        noRightBorder: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  ...List.generate(ageGroups.length, (i) {
                    final pVal = sums['${prefixList[i]}_P']?.toString() ?? '0';
                    final wVal = sums['${prefixList[i]}_W']?.toString() ?? '0';
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(
                          ageGroups[i],
                          flex: 1,
                          height: 28,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          pVal,
                          flex: 1,
                          height: 28,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                        buildCell(
                          wVal,
                          flex: 1,
                          height: 28,
                          noRightBorder: true,
                          bottomBorder: true,
                          fontSize: 9,
                        ),
                      ],
                    );
                  }),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      buildCell(
                        'TOTAL',
                        flex: 1,
                        height: 28,
                        isHeader: true,
                        backgroundColor: PdfColors.yellow,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_P']?.toString() ?? '0',
                        flex: 1,
                        height: 28,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
                      ),
                      buildCell(
                        sums['total_W']?.toString() ?? '0',
                        flex: 1,
                        height: 28,
                        noRightBorder: true,
                        backgroundColor: PdfColors.yellow,
                        isHeader: true,
                        fontSize: 10,
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

    // ==========================================
    // PAGE 2: LANDSCAPE
    // ==========================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ),
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROFIL KEPENDUDUKAN (RINCIAN KELUARGA)',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.Text(
                'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
              ),
              pw.SizedBox(height: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 60,
                        child: pw.Text(
                          'NAMA',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': $namaKelompok',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
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
                          'RT / RW',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': $rt / $rw',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
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
                          'Kelurahan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': $kelurahan',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
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
                          'Kecamatan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': $kecamatan',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
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
                          'Kota',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': $kota',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                height: 30,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.yellow,
                  border: pw.Border(
                    top: pw.BorderSide(width: 0.5),
                    bottom: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    buildCell('NO', flex: 1, isHeader: true, fontSize: 8),
                    buildCell(
                      'Nama Kepala Keluarga',
                      flex: 4,
                      isHeader: true,
                      fontSize: 8,
                    ),
                    for (int i = 0; i < ageGroups.length; i++)
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(right: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              buildCell(
                                ageGroups[i],
                                height: 15,
                                isHeader: true,
                                noRightBorder: true,
                                bottomBorder: true,
                                fontSize: 6,
                              ),
                              pw.Container(
                                height: 15,
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell(
                                      'P',
                                      flex: 1,
                                      isHeader: true,
                                      fontSize: 6,
                                    ),
                                    buildCell(
                                      'W',
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
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            buildCell(
                              'Jumlah',
                              height: 15,
                              isHeader: true,
                              noRightBorder: true,
                              bottomBorder: true,
                              fontSize: 6,
                            ),
                            pw.Container(
                              height: 15,
                              child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell(
                                    'P',
                                    flex: 1,
                                    isHeader: true,
                                    fontSize: 6,
                                  ),
                                  buildCell(
                                    'W',
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
          );
        },
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // Data Rows
          for (int idx = 0; idx < data.length; idx++) {
            final row = data[idx];
            widgets.add(
              pw.Container(
                height: 20,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    buildCell((idx + 1).toString(), flex: 1, height: 20),
                    buildCell(
                      row['namaKeluarga']?.toString() ?? '',
                      flex: 4,
                      height: 20,
                      alignment: pw.Alignment.centerLeft,
                    ),
                    for (int i = 0; i < prefixList.length; i++) ...[
                      buildCell(
                        row['${prefixList[i]}_P']?.toString() ?? '0',
                        flex: 1,
                        height: 20,
                      ),
                      buildCell(
                        row['${prefixList[i]}_W']?.toString() ?? '0',
                        flex: 1,
                        height: 20,
                        noRightBorder: false,
                      ),
                    ],
                    buildCell(
                      row['total_P']?.toString() ?? '0',
                      flex: 1,
                      height: 20,
                    ),
                    buildCell(
                      row['total_W']?.toString() ?? '0',
                      flex: 1,
                      height: 20,
                      noRightBorder: true,
                    ),
                  ],
                ),
              ),
            );
          }

          // JUMLAH Row
          widgets.add(
            pw.Container(
              height: 20,
              decoration: const pw.BoxDecoration(
                color: PdfColors.yellow,
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  buildCell('', flex: 1, height: 20),
                  buildCell('JUMLAH', flex: 4, isHeader: true, height: 20),
                  for (int i = 0; i < prefixList.length; i++) ...[
                    buildCell(
                      sums['${prefixList[i]}_P'].toString(),
                      flex: 1,
                      isHeader: true,
                      height: 20,
                    ),
                    buildCell(
                      sums['${prefixList[i]}_W'].toString(),
                      flex: 1,
                      isHeader: true,
                      height: 20,
                      noRightBorder: false,
                    ),
                  ],
                  buildCell(
                    sums['total_P'].toString(),
                    flex: 1,
                    isHeader: true,
                    height: 20,
                  ),
                  buildCell(
                    sums['total_W'].toString(),
                    flex: 1,
                    isHeader: true,
                    height: 20,
                    noRightBorder: true,
                  ),
                ],
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateLampidPdfPerincian({
    required String namaKelompok,
    required List<Map<String, dynamic>> mutasiList,
    required String rt,
    required String rw,
    required String kelurahan,
    required String bulan,
    required String tahun,
  }) async {
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
            fontSize: fontSize ?? (isHeader ? 7 : 8),
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
                                                  fontSize: 5,
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
                                                        fontSize: 5,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 5,
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
                                                  fontSize: 5,
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
                                                        fontSize: 5,
                                                      ),
                                                      buildCell(
                                                        'TIDAK',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 5,
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
                                                  fontSize: 5,
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
                                                        fontSize: 5,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                        fontSize: 5,
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
                    ...mutasiList.asMap().entries.map((entry) {
                      final int i = entry.key + 1;
                      final row = entry.value;

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
                      final statusMeninggal = isKematian
                          ? (row['status_ibu']?.toString() ?? '')
                          : '';
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

                    if (mutasiList.isEmpty)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Tidak ada data mutasi',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                        ),
                      ),

                    // JUMLAH Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            flex:
                                11, // NO(1)+NAMA IBU(3)+NAMA SUAMI(3)+STATUS(4)
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              padding: const pw.EdgeInsets.only(left: 8),
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                'JUMLAH',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
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

  Future<Uint8List> generateForm1({
    required Map<String, dynamic> data,
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
    required String rw,
    required String rt,
    pw.Document? existingPdf,
  }) async {
    final pdf = existingPdf ?? pw.Document();

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          21.5 * PdfPageFormat.cm,
          33.0 * PdfPageFormat.cm,
        ), // Portrait
        margin: const pw.EdgeInsets.symmetric(vertical: 32, horizontal: 48),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text(
                  'Lampiran III-A',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'FORM I\nPENETAPAN SASARAN PENDATAAN DAN\nPENUGASAN KOORDINATOR KELOMPOK DASAWISMA PKK\nTINGKAT RT',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Kota/Kab.',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Kecamatan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Kelurahan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'RW',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'RT',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        ': $kabupaten',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        ': $kecamatan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        ': $kelurahan',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        ': $rw',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        ': $rt',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Hasil identifikasi sasaran pendataan Tingkat RT maka diperoleh data sebagai berikut:',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
              pw.SizedBox(height: 8),

              // Tabel 1
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  _buildEmptyTableRow(
                    [
                      '1.',
                      'Jumlah Kelompok dibentuk',
                      '${data['jumlahKelompok']}',
                    ],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['2.', 'Jumlah Bangunan', '${data['jumlahBangunan']}'],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    [
                      '3.',
                      'Jumlah Kepala Rumah Tangga (KRT)',
                      '${data['jumlahKrt']}',
                    ],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['4.', 'Jumlah Keluarga', '${data['jumlahKeluarga']}'],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['5.', 'Jumlah Individu', '${data['jumlahIndividu']}'],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              pw.Text(
                'Berdasarkan hasil identifikasi di atas, maka dibentuk Kelompok Dasawisma PKK beserta Penugasannya sebagai berikut:',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
              pw.SizedBox(height: 8),

              // Tabel 2 Custom Header (karena pw.Table tidak mendukung colSpan secara langsung)
              pw.Container(
                height: 32,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 0.5),
                    bottom: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    right: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 30,
                      alignment: pw.Alignment.center,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Text(
                        'NO',
                        style: pw.TextStyle(font: boldFont, fontSize: 8),
                      ),
                    ),
                    pw.Expanded(
                      flex: 25,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          'KELOMPOK\nDASAWISMA',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: boldFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 35,
                      child: pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              height: 18,
                              alignment: pw.Alignment.center,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              child: pw.Text(
                                'PENUGASAN\nKOORDINATOR DASAWISMA',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  pw.Expanded(
                                    flex: 10,
                                    child: pw.Container(
                                      alignment: pw.Alignment.center,
                                      decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                          right: pw.BorderSide(width: 0.5),
                                        ),
                                      ),
                                      child: pw.Text(
                                        'ID',
                                        style: pw.TextStyle(
                                          font: boldFont,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 25,
                                    child: pw.Container(
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(
                                        'NAMA',
                                        style: pw.TextStyle(
                                          font: boldFont,
                                          fontSize: 8,
                                        ),
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
                    pw.Expanded(
                      flex: 10,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          'JUMLAH\nBANGUNAN',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: boldFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 10,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          'JUMLAH\nKRT',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: boldFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 10,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          'JUMLAH\nKELUARGA',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: boldFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 10,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'JUMLAH\nINDIVIDU',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: boldFont, fontSize: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tabel 2 Data (Body)
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                  bottom: pw.BorderSide(width: 0.5),
                  verticalInside: pw.BorderSide(width: 0.5),
                  horizontalInside: pw.BorderSide(width: 0.5),
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(25),
                  2: const pw.FlexColumnWidth(10),
                  3: const pw.FlexColumnWidth(25),
                  4: const pw.FlexColumnWidth(10),
                  5: const pw.FlexColumnWidth(10),
                  6: const pw.FlexColumnWidth(10),
                  7: const pw.FlexColumnWidth(10),
                },
                children: [
                  for (
                    int i = 0;
                    i < (data['kelompokList'] as List).length;
                    i++
                  )
                    _buildEmptyTableRow(
                      [
                        '${i + 1}',
                        (data['kelompokList'][i]['namaKelompok'] as String),
                        (data['kelompokList'][i]['idKader']?.toString() ?? ''),
                        (data['kelompokList'][i]['namaKordinator']
                                ?.toString() ??
                            ''),
                        '${data['kelompokList'][i]['jumlahBangunan']}',
                        '${data['kelompokList'][i]['jumlahKrt']}',
                        '${data['kelompokList'][i]['jumlahKeluarga']}',
                        '${data['kelompokList'][i]['jumlahIndividu']}',
                      ],
                      font: regularFont,
                      height: 24,
                      alignments: [
                        pw.Alignment.center,
                        pw.Alignment.centerLeft,
                        pw.Alignment.center,
                        pw.Alignment.centerLeft,
                        pw.Alignment.center,
                        pw.Alignment.center,
                        pw.Alignment.center,
                        pw.Alignment.center,
                      ],
                    ),
                  for (int i = 0; i < 3; i++)
                    _buildEmptyTableRow(
                      [
                        '${(data['kelompokList'] as List).length + i + 1}',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                      ],
                      font: regularFont,
                      height: 24,
                      alignments: [
                        pw.Alignment.center,
                        pw.Alignment.centerLeft,
                        pw.Alignment.center,
                        pw.Alignment.centerLeft,
                        pw.Alignment.center,
                        pw.Alignment.center,
                        pw.Alignment.center,
                        pw.Alignment.center,
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 48),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Jakarta,',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Ketua Kelompok PKK RT $rt  .... ,',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 60),
                      pw.Container(
                        width: 180,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    if (existingPdf != null) return Uint8List(0);
    return pdf.save();
  }

  Future<Uint8List> generateForm2({
    required List<Map<String, dynamic>> dataList,
    pw.Document? existingPdf,
  }) async {
    final pdf = existingPdf ?? pw.Document();

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();

    for (final data in dataList) {
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            21.5 * PdfPageFormat.cm,
            33.0 * PdfPageFormat.cm,
          ), // Portrait
          margin: const pw.EdgeInsets.symmetric(vertical: 32, horizontal: 48),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    'Lampiran III-B',
                    style: pw.TextStyle(font: regularFont, fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'FORM II\nDATA KELOMPOK DASAWISMA PKK',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Header Info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            'Nama Kelompok',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 200,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            ': ${data['namaKelompok']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            'ID/Nama Koordinator',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 200,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            ': ${data['namaKordinator']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            'Jumlah Bangunan',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 200,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            ': ${data['jumlahBangunan']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Tabel Data
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.black,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(40),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(1),
                    5: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _buildAdvancedHeaderCell(
                          'No Urut\nBangunan',
                          regularFont,
                        ),
                        _buildAdvancedHeaderCell('Nama Bangunan', regularFont),
                        _buildAdvancedHeaderCell(
                          'Kode Bangunan\n(diisi dengan angka)',
                          regularFont,
                        ),
                        _buildAdvancedHeaderCell('Jumlah\nKRT', regularFont),
                        _buildAdvancedHeaderCell(
                          'Jumlah\nKeluarga',
                          regularFont,
                        ),
                        _buildAdvancedHeaderCell(
                          'Jumlah\nIndividu',
                          regularFont,
                        ),
                      ],
                    ),
                    for (
                      int i = 0;
                      i < (data['bangunanList'] as List).length;
                      i++
                    )
                      _buildEmptyTableRow(
                        [
                          (data['bangunanList'][i]['noUrutBangunan'] as String),
                          (data['bangunanList'][i]['namaBangunan'] as String),
                          (data['bangunanList'][i]['kodeBangunan'] as String),
                          '${data['bangunanList'][i]['jumlahKrt']}',
                          '${data['bangunanList'][i]['jumlahKeluarga']}',
                          '${data['bangunanList'][i]['jumlahIndividu']}',
                        ],
                        font: regularFont,
                        height: 16,
                        alignments: [
                          pw.Alignment.center,
                          pw.Alignment.centerLeft,
                          pw.Alignment.center,
                          pw.Alignment.center,
                          pw.Alignment.center,
                          pw.Alignment.center,
                        ],
                      ),

                    // Row JUMLAH
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: 20,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'JUMLAH',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                        ),
                        pw.Container(height: 20),
                        pw.Container(height: 20),
                        pw.Container(
                          height: 20,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${data['totalKrt']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                        pw.Container(
                          height: 20,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${data['totalKeluarga']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                        pw.Container(
                          height: 20,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${data['totalIndividu']}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Keterangan:\n1. Identitas Bangunan:',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                    pw.Text(
                      '   a. Diisi Nama Pemilik jika:\n      - Bangunan ditinggali oleh pemilik\n      - Bangunan Kos-kosan\n   b. Diisi Nama Penyewa jika:\n      - Bangunan Kontrakan\n      - Bangunan Apartemen/Rusun',
                      style: pw.TextStyle(font: regularFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '2. Kategori Bangunan:',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.SizedBox(
                      width: 300,
                      child: pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FlexColumnWidth(1),
                          2: const pw.FlexColumnWidth(3),
                          3: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.all(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              _buildAdvancedHeaderCell(
                                'Jenis Bangunan',
                                regularFont,
                                fontSize: 8,
                              ),
                              _buildAdvancedHeaderCell(
                                'Kode',
                                regularFont,
                                fontSize: 8,
                              ),
                              _buildAdvancedHeaderCell(
                                'Jenis Bangunan',
                                regularFont,
                                fontSize: 8,
                              ),
                              _buildAdvancedHeaderCell(
                                'Kode',
                                regularFont,
                                fontSize: 8,
                              ),
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Rumah Tinggal', '1', 'Rukan/Ruko', '8'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Kontrakan', '2', 'Kios/Toko/Warung', '9'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Kos-kosan', '3', 'Tempat Usaha Lainnya', '10'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Asrama/Mess', '4', 'Sekolah', '11'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Rusun', '5', 'Tempat Ibadah', '12'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Rumah Dinas', '6', 'Panti', '13'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                          _buildEmptyTableRow(
                            ['Apartemen', '7', 'Jenis Bangunan Lainnya', '14'],
                            font: regularFont,
                            height: 16,
                            fontSize: 8,
                            alignments: [
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                              pw.Alignment.centerLeft,
                              pw.Alignment.center,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    } // Close the for loop

    if (existingPdf != null) return Uint8List(0);
    return pdf.save();
  }

  Future<Uint8List> generateForm1And2({
    required Map<String, dynamic> dataForm1,
    required List<Map<String, dynamic>> dataForm2,
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
    required String rw,
    required String rt,
  }) async {
    final pdf = pw.Document();

    await generateForm1(
      data: dataForm1,
      kabupaten: kabupaten,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      rw: rw,
      rt: rt,
      existingPdf: pdf,
    );

    await generateForm2(dataList: dataForm2, existingPdf: pdf);

    return pdf.save();
  }

  Future<Uint8List> generateFormDataManual({
    required Map<String, dynamic> data,
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final ttf = font;
    final ttfBold = fontBold;

    // Kertas F4 Landscape
    final formatF4Landscape = const PdfPageFormat(
      33.0 * PdfPageFormat.cm,
      21.5 * PdfPageFormat.cm,
    );

    int totalBangunan = 0;
    int totalKrt = 0;
    int totalKk = 0;
    int totalIndividu = 0;

    Set<String> bangunanSet = {};
    Set<String> krtSet = {};
    Set<String> kkSet = {};

    final rowsList = (data['rows'] as List).cast<Map<String, dynamic>>();
    for (var r in rowsList) {
      if (r['noUrutBangunan']?.toString().isNotEmpty ?? false) {
        bangunanSet.add(r['noUrutBangunan'].toString());
      }
      if (r['nikKrt']?.toString().isNotEmpty ?? false) {
        krtSet.add(r['nikKrt'].toString());
      }
      if (r['noKk']?.toString().isNotEmpty ?? false) {
        kkSet.add(r['noKk'].toString());
      }
      if (r['individu']?.toString().isNotEmpty ?? false) {
        totalIndividu++;
      }
    }
    totalBangunan = bangunanSet.length;
    totalKrt = krtSet.length;
    totalKk = kkSet.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: formatF4Landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          String val(Map<String, dynamic> row, String key) {
            final v = row[key]?.toString();
            return (v == null || v.trim().isEmpty) ? '0' : v;
          }

          return [
            // Judul
            pw.Center(
              child: pw.Text(
                'DATA MANUAL TARGET SASARAN PENDATAAN',
                style: pw.TextStyle(font: ttfBold, fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 16),

            // Kop
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(15),
                2: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('RW', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(':', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(
                      data['rw'] ?? '',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox(height: 4),
                    pw.SizedBox(height: 4),
                    pw.SizedBox(height: 4),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('RT', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(':', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(
                      data['rt'] ?? '',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox(height: 4),
                    pw.SizedBox(height: 4),
                    pw.SizedBox(height: 4),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      'KELOMPOK',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(':', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(
                      data['kelompokName'] ?? '',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Tabel
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // NO
                1: const pw.FlexColumnWidth(2), // NO URUT BANGUNAN
                2: const pw.FlexColumnWidth(4), // NAMA BANGUNAN
                3: const pw.FlexColumnWidth(4), // NAMA KRT
                4: const pw.FlexColumnWidth(4), // NIK KRT
                5: const pw.FlexColumnWidth(3), // NO TLP
                6: const pw.FlexColumnWidth(4), // NAMA KEPALA KELUARGA
                7: const pw.FlexColumnWidth(4), // NOMOR KK
                8: const pw.FlexColumnWidth(5), // INDIVIDU
                9: const pw.FlexColumnWidth(1.5), // L/P
                10: const pw.FlexColumnWidth(4), // NIK INDIVIDU
                11: const pw.FlexColumnWidth(3), // TGL LAHIR
                12: const pw.FlexColumnWidth(2), // UMUR
                13: const pw.FlexColumnWidth(3), // STTS DGN KRT
                14: const pw.FlexColumnWidth(3), // STTS DGN KK
                15: const pw.FlexColumnWidth(3), // NOP
                16: const pw.FlexColumnWidth(2), // LB
                17: const pw.FlexColumnWidth(2), // LL
              },
              children: [
                // Header Row
                pw.TableRow(
                  repeat: true,
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildCell('NO', ttfBold, true, fontSize: 7),
                    _buildCell('NO URUT\nBANGUNAN', ttfBold, true, fontSize: 7),
                    _buildCell('NAMA BANGUNAN', ttfBold, true, fontSize: 7),
                    _buildCell('NAMA KRT', ttfBold, true, fontSize: 7),
                    _buildCell('NIK KRT', ttfBold, true, fontSize: 7),
                    _buildCell('NO TLP', ttfBold, true, fontSize: 7),
                    _buildCell(
                      'NAMA KEPALA\nKELUARGA',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ),
                    _buildCell('NOMOR KK', ttfBold, true, fontSize: 7),
                    _buildCell('INDIVIDU', ttfBold, true, fontSize: 7),
                    _buildCell('L/P', ttfBold, true, fontSize: 7),
                    _buildCell('NIK INDIVIDU', ttfBold, true, fontSize: 7),
                    _buildCell('TGL LAHIR', ttfBold, true, fontSize: 7),
                    _buildCell('UMUR', ttfBold, true, fontSize: 7),
                    _buildCell('STTS DGN KRT', ttfBold, true, fontSize: 7),
                    _buildCell('STTS DGN KK', ttfBold, true, fontSize: 7),
                    _buildCell('NOP', ttfBold, true, fontSize: 7),
                    _buildCell('LB', ttfBold, true, fontSize: 7),
                    _buildCell('LL', ttfBold, true, fontSize: 7),
                  ],
                ),

                // Data Rows
                for (int i = 0; i < (data['rows'] as List).length; i++)
                  pw.TableRow(
                    children: [
                      _buildCell('${i + 1}', ttf, true, fontSize: 6),
                      _buildCell(
                        val(data['rows'][i], 'noUrutBangunan'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'namaBangunan'),
                        ttf,
                        false,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'namaKrt'),
                        ttf,
                        false,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'nikKrt'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'noTlp'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'namaKepalaKeluarga'),
                        ttf,
                        false,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'noKk'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'individu'),
                        ttf,
                        false,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'lp'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'nikIndividu'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'tglLahir'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'umur'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'sttsKrt'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'sttsKk'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'nop'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'lb'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                      _buildCell(
                        val(data['rows'][i], 'll'),
                        ttf,
                        true,
                        fontSize: 6,
                      ),
                    ],
                  ),

                // Baris Total
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildCell('', ttfBold, true, fontSize: 7), // NO
                    _buildCell(
                      '$totalBangunan',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // NO URUT BANGUNAN
                    _buildCell(
                      'TOTAL',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // NAMA BANGUNAN
                    _buildCell('', ttfBold, true, fontSize: 7), // NAMA KRT
                    _buildCell(
                      '$totalKrt',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // NIK KRT
                    _buildCell('', ttfBold, true, fontSize: 7), // NO TLP
                    _buildCell(
                      '',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // NAMA KEPALA KELUARGA
                    _buildCell(
                      '$totalKk',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // NOMOR KK
                    _buildCell(
                      '$totalIndividu',
                      ttfBold,
                      true,
                      fontSize: 7,
                    ), // INDIVIDU
                    _buildCell('', ttfBold, true, fontSize: 7), // L/P
                    _buildCell('', ttfBold, true, fontSize: 7), // NIK INDIVIDU
                    _buildCell('', ttfBold, true, fontSize: 7), // TGL LAHIR
                    _buildCell('', ttfBold, true, fontSize: 7), // UMUR
                    _buildCell('', ttfBold, true, fontSize: 7), // STTS DGN KRT
                    _buildCell('', ttfBold, true, fontSize: 7), // STTS DGN KK
                    _buildCell('', ttfBold, true, fontSize: 7), // NOP
                    _buildCell('', ttfBold, true, fontSize: 7), // LB
                    _buildCell('', ttfBold, true, fontSize: 7), // LL
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}