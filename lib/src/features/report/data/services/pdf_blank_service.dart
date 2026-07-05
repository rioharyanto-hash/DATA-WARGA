import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfBlankService {
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

  Future<Uint8List> generateBlankFormRekap() async {
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
            fontSize: isHeader ? 6 : 8,
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
                'REKAPITULASI',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.Text(
                'CATATAN DATA DAN KEGIATAN WARGA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.Text(
                'KELOMPOK DASAWISMA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.SizedBox(height: 16),

              // Header Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'DASA WISMA',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            width: 100,
                            child: pw.Text(
                              'RT',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            width: 100,
                            child: pw.Text(
                              'RW',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            width: 100,
                            child: pw.Text(
                              'DESA / KELURAHAN',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            width: 100,
                            child: pw.Text(
                              'TAHUN',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabel Rekapitulasi
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 45,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('NO', width: 20, isHeader: true),
                          buildCell(
                            'NAMA KEPALA RUMAH\nTANGGA',
                            flex: 3,
                            isHeader: true,
                          ),
                          buildCell('JML KK', flex: 1, isHeader: true),
                          pw.Expanded(
                            flex: 11,
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
                                    'JUMLAH ANGGOTA KELUARGA',
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
                                                  'TOTAL',
                                                  flex: 1,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                ),
                                                pw.Expanded(
                                                  flex: 1,
                                                  child: pw.Row(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      buildCell(
                                                        'L',
                                                        flex: 1,
                                                        isHeader: true,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
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
                                                  'BALITA',
                                                  flex: 1,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                ),
                                                pw.Expanded(
                                                  flex: 1,
                                                  child: pw.Row(
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      buildCell(
                                                        'L',
                                                        flex: 1,
                                                        isHeader: true,
                                                      ),
                                                      buildCell(
                                                        'P',
                                                        flex: 1,
                                                        isHeader: true,
                                                        noRightBorder: true,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        buildCell(
                                          'PUS',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'WUS',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'IBU\nHAMIL',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'IBU\nMENYUSUI',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'LANSIA',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          '3 BUTA',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'BERKE-\nBUTUHAN\nKHUSUS',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 6,
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
                                    'KRITERIA RUMAH',
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
                                          'SEHAT\nLAYAK HUNI',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'TIDAK SEHAT\nLAYAK HUNI',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'MEMILIKI TMP.\nPEMB. SAMPAH',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'MEMILIKI\nSPAL',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'MEMILIKI\nJAMBAN\nKELUARGA',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'MENEMPEL\nSTIKER P4K',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
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
                                    'SUMBER AIR KELUARGA',
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
                                          'PDAM',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'SUMUR',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'DLL',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
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
                                    'MAKANAN POKOK',
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
                                          'BERAS',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'NON BERAS',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 4,
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
                                    'WARGA MENGIKUTI KEGIATAN',
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
                                          'UP2K',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'PEMANFAATAN\nTANAH\nPEKARANGAN',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'INDUSTRI\nRUMAH\nTANGGA',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'KERJA\nBAKTI',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildCell(
                            'KET',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                          ),
                        ],
                      ),
                    ),
                    // Row 2: Sub Headers (Column Numbers)
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('1', width: 20, isHeader: true),
                          buildCell('2', flex: 3, isHeader: true),
                          buildCell('3', flex: 1, isHeader: true),
                          buildCell('4', flex: 1, isHeader: true),
                          buildCell('5', flex: 1, isHeader: true),
                          buildCell('6', flex: 1, isHeader: true),
                          buildCell('7', flex: 1, isHeader: true),
                          buildCell('8', flex: 1, isHeader: true),
                          buildCell('9', flex: 1, isHeader: true),
                          buildCell('10', flex: 1, isHeader: true),
                          buildCell('11', flex: 1, isHeader: true),
                          buildCell('12', flex: 1, isHeader: true),
                          buildCell('13', flex: 1, isHeader: true),
                          buildCell('14', flex: 1, isHeader: true),
                          buildCell('15', flex: 1, isHeader: true),
                          buildCell('16', flex: 1, isHeader: true),
                          buildCell('17', flex: 1, isHeader: true),
                          buildCell('18', flex: 1, isHeader: true),
                          buildCell('19', flex: 1, isHeader: true),
                          buildCell('20', flex: 1, isHeader: true),
                          buildCell('21', flex: 1, isHeader: true),
                          buildCell('22', flex: 1, isHeader: true),
                          buildCell('23', flex: 1, isHeader: true),
                          buildCell('24', flex: 1, isHeader: true),
                          buildCell('25', flex: 1, isHeader: true),
                          buildCell('26', flex: 1, isHeader: true),
                          buildCell('27', flex: 1, isHeader: true),
                          buildCell('28', flex: 1, isHeader: true),
                          buildCell('29', flex: 1, isHeader: true),
                          buildCell(
                            '30',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                          ),
                        ],
                      ),
                    ),
                    // Empty Data Rows
                    for (int i = 1; i <= 10; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('$i', width: 20),
                            buildCell('', flex: 3),
                            for (int j = 0; j < 28; j++)
                              buildCell('', flex: 1, noRightBorder: j == 27),
                          ],
                        ),
                      ),
                    for (int i = 0; i < 6; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('', width: 20),
                            buildCell('', flex: 3),
                            for (int j = 0; j < 28; j++)
                              buildCell('', flex: 1, noRightBorder: j == 27),
                          ],
                        ),
                      ),
                    // Jumlah Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('', width: 20),
                          buildCell('JUMLAH', flex: 3, isHeader: true),
                          buildCell('0', flex: 1, isHeader: true),
                          for (int j = 0; j < 26; j++) buildCell('-', flex: 1),
                          buildCell('', flex: 1, noRightBorder: true),
                        ],
                      ),
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
  /// FORM PROFIL KEPENDUDUKAN - RINGKASAN (TEMPLATE KOSONG)
  /// Format: Portrait, F4
  /// =========================================================================
  Future<Uint8List> generateBlankFormProfilUsiaRingkasan() async {
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
      pw.Alignment alignment = pw.Alignment.center,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(8),
        alignment: alignment,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: noRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 1.0),
            bottom: bottomBorder
                ? const pw.BorderSide(width: 1.0)
                : pw.BorderSide.none,
          ),
        ),
        child: pw.Text(
          text,
          textAlign: alignment == pw.Alignment.center
              ? pw.TextAlign.center
              : pw.TextAlign.left,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 12 : 11),
          ),
        ),
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

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          21.5 * PdfPageFormat.cm,
          33.0 * PdfPageFormat.cm,
        ), // Portrait F4
        margin: const pw.EdgeInsets.all(48),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROFIL KEPENDUDUKAN',
                style: pw.TextStyle(font: boldFont, fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                style: pw.TextStyle(font: regularFont, fontSize: 12),
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
                        width: 80,
                        child: pw.Text(
                          'NAMA',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          'Kelompok',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          'RT / RW',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          'Kelurahan',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          'Kecamatan',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          'Kota',
                          style: pw.TextStyle(font: regularFont, fontSize: 11),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Tabel Profil Umur Ringkasan
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 32,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.yellow,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell(
                            'UMUR',
                            flex: 2,
                            isHeader: true,
                            bottomBorder: true,
                          ),
                          buildCell(
                            'P',
                            flex: 2,
                            isHeader: true,
                            bottomBorder: true,
                          ),
                          buildCell(
                            'W',
                            flex: 2,
                            isHeader: true,
                            bottomBorder: true,
                            noRightBorder: true,
                          ),
                        ],
                      ),
                    ),
                    // Data Rows
                    for (int i = 0; i < ageGroups.length; i++)
                      pw.Container(
                        height: 24,
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell(
                              ageGroups[i],
                              flex: 2,
                              bottomBorder: i != ageGroups.length - 1,
                            ),
                            buildCell(
                              '',
                              flex: 2,
                              bottomBorder: i != ageGroups.length - 1,
                            ),
                            buildCell(
                              '',
                              flex: 2,
                              bottomBorder: i != ageGroups.length - 1,
                              noRightBorder: true,
                            ),
                          ],
                        ),
                      ),
                    // TOTAL Row
                    pw.Container(
                      height: 24,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.yellow,
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('TOTAL', flex: 2, isHeader: true),
                          buildCell('0', flex: 2),
                          buildCell('0', flex: 2, noRightBorder: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// =========================================================================
  /// FORM PROFIL KEPENDUDUKAN (TEMPLATE KOSONG)
  /// Format: Landscape, F4
  /// =========================================================================
  Future<Uint8List> generateBlankFormProfilUsia() async {
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

    final List<String> ageGroups = [
      '0 - 4',
      '5 - 9th',
      '10 - 14th',
      '15 - 19',
      '20 - 24',
      '25 - 29',
      '30 - 34',
      '35 - 39',
      '40 - 44',
      '45 - 49',
      '50 - 54',
      '55 - 59',
      '60 - 64',
      '65 - 69',
      '70 - 74',
      '75 +',
      'Jumlah',
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.5 * PdfPageFormat.cm,
        ), // Landscape F4
        margin: const pw.EdgeInsets.all(32), // 1.1 cm margin
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROFIL KEPENDUDUKAN',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.Text(
                'Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
              ),
              pw.SizedBox(height: 16),

              // Header Info
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
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kelompok',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'RT / RW',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kelurahan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kecamatan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kota',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabel Profil Umur
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 30,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.yellow,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('NO', flex: 1, isHeader: true, fontSize: 8),
                          buildCell(
                            'Nama Keluarga',
                            flex: 4,
                            isHeader: true,
                            fontSize: 8,
                          ),
                          for (int i = 0; i < ageGroups.length; i++)
                            pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: i == ageGroups.length - 1
                                        ? pw.BorderSide.none
                                        : const pw.BorderSide(width: 0.5),
                                  ),
                                ),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    buildCell(
                                      ageGroups[i],
                                      flex: 1,
                                      isHeader: true,
                                      noRightBorder: true,
                                      bottomBorder: true,
                                      fontSize: 6,
                                    ),
                                    pw.Expanded(
                                      flex: 1,
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
                    // Empty Data Rows
                    for (int i = 0; i < 15; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('', flex: 1),
                            buildCell('', flex: 4),
                            for (int j = 0; j < ageGroups.length * 2; j++)
                              buildCell(
                                '',
                                flex: 1,
                                noRightBorder: j == ageGroups.length * 2 - 1,
                              ),
                          ],
                        ),
                      ),
                    // TOTAL Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('', flex: 1),
                          buildCell('TOTAL', flex: 4, isHeader: true),
                          for (int j = 0; j < ageGroups.length * 2; j++)
                            buildCell(
                              '',
                              flex: 1,
                              noRightBorder: j == ageGroups.length * 2 - 1,
                            ),
                        ],
                      ),
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
  /// FORM DATA POTENSI WARGA (TERISI)
  /// Format: Landscape, F4
  /// =========================================================================

  Future<Uint8List> generateBlankFormDataPotensiWarga() async {
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
                'DATA POTENSI WARGA',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.Text(
                'KELOMPOK PKK RW',
                style: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
              pw.SizedBox(height: 16),

              // Header Info
              pw.Row(
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
                              'RW',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                              'DUSUN / LINGKUNGAN',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                              'DESA / KELURAHAN',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                              'TAHUN',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                              'PERIODE',
                              style: pw.TextStyle(font: boldFont, fontSize: 8),
                            ),
                          ),
                          pw.Text(
                            ': ',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabel Data Potensi Warga
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 48,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('NO', flex: 1, isHeader: true, fontSize: 5),
                          buildCell(
                            'NAMA BANGUNAN',
                            flex: 4,
                            isHeader: true,
                            fontSize: 5,
                          ),
                          buildCell(
                            'JML\nKRT',
                            flex: 1,
                            isHeader: true,
                            fontSize: 5,
                          ),
                          buildCell(
                            'JML\nKK',
                            flex: 1,
                            isHeader: true,
                            fontSize: 5,
                          ),

                          // TOTAL
                          pw.Expanded(
                            flex: 2,
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
                                    'TOTAL',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
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

                          // BALITA
                          pw.Expanded(
                            flex: 4,
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
                                    'BALITA',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
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
                                          fontSize: 5,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'AKTIF\nPOSYANDU',
                                                  flex: 2,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 4,
                                                ),
                                                pw.Expanded(
                                                  flex: 1,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          buildCell(
                            'PUS',
                            flex: 1,
                            isHeader: true,
                            fontSize: 5,
                          ),

                          // PENGGUNAAN ALAT KB
                          pw.Expanded(
                            flex: 8,
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
                                    'PENGGUNAAN ALAT KB',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
                                      children: [
                                        buildCell(
                                          'TIDAK\nKB',
                                          flex: 1,
                                          isHeader: true,
                                          fontSize: 5,
                                        ),
                                        buildCell(
                                          'PIL',
                                          flex: 1,
                                          isHeader: true,
                                          fontSize: 5,
                                        ),
                                        buildCell(
                                          'IUD',
                                          flex: 1,
                                          isHeader: true,
                                          fontSize: 5,
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            alignment: pw.Alignment.center,
                                            decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                right: pw.BorderSide(
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: pw.Transform.rotateBox(
                                              angle: 1.5708, // 90 degrees
                                              child: pw.Text(
                                                'IMPLAN',
                                                style: pw.TextStyle(
                                                  font: boldFont,
                                                  fontSize: 5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            alignment: pw.Alignment.center,
                                            decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                right: pw.BorderSide(
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: pw.Transform.rotateBox(
                                              angle: 1.5708,
                                              child: pw.Text(
                                                'SUNTIK',
                                                style: pw.TextStyle(
                                                  font: boldFont,
                                                  fontSize: 5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Container(
                                            alignment: pw.Alignment.center,
                                            decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                right: pw.BorderSide(
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: pw.Transform.rotateBox(
                                              angle: 1.5708,
                                              child: pw.Text(
                                                'KONDOM',
                                                style: pw.TextStyle(
                                                  font: boldFont,
                                                  fontSize: 5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        buildCell(
                                          'STERIL',
                                          flex: 1,
                                          isHeader: true,
                                          fontSize: 4,
                                        ),
                                        buildCell(
                                          'LAINN\nYA',
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

                          // REMAJA
                          pw.Expanded(
                            flex: 4,
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
                                    'REMAJA (10-18) TH',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
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
                                          fontSize: 5,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'AKTIF\nPOSREM',
                                                  flex: 2,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 4,
                                                ),
                                                pw.Expanded(
                                                  flex: 1,
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
                                border: pw.Border(
                                  right: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell(
                                    'LANSIA',
                                    flex: 1,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
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
                                          fontSize: 5,
                                        ),
                                        pw.Expanded(
                                          flex: 2,
                                          child: pw.Container(
                                            child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.stretch,
                                              children: [
                                                buildCell(
                                                  'AKTIF POSLAN',
                                                  flex: 2,
                                                  isHeader: true,
                                                  noRightBorder: true,
                                                  bottomBorder: true,
                                                  fontSize: 4,
                                                ),
                                                pw.Expanded(
                                                  flex: 1,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // BERKEBUTUHAN KHUSUS
                          pw.Expanded(
                            flex: 2,
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
                                    'BERKEBUTUHAN\nKHUSUS',
                                    flex: 2,
                                    isHeader: true,
                                    noRightBorder: true,
                                    bottomBorder: true,
                                    fontSize: 5,
                                  ),
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Row(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
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
                            'KET',
                            flex: 1,
                            isHeader: true,
                            noRightBorder: true,
                            fontSize: 5,
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

                    // Empty Data Rows
                    for (int i = 1; i <= 15; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
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
                                    j == 1 ? '$i' : '',
                                    style: pw.TextStyle(
                                      font: regularFont,
                                      fontSize: 6,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // TOTAL Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            flex: 2,
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
                                  fontSize: 6,
                                ),
                              ),
                            ),
                          ),
                          for (int j = 3; j <= 33; j++)
                            pw.Expanded(
                              flex: 1,
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
                                  j == 33 ? '' : '0',
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 6,
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
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// =========================================================================
  /// FORM IBU HAMIL, MELAHIRKAN, NIFAS, IBU MENINGGAL, KELAHIRAN, KEMATIAN
  /// Format: Landscape, F4
  /// =========================================================================
  Future<Uint8List> generateBlankFormIbuHamil() async {
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(width: 0.5),
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

                    // Empty Data Rows
                    for (int i = 1; i <= 10; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell(i == 1 ? '1' : '', flex: 1, fontSize: 7),
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
  Future<Uint8List> generateBlankForm1({
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
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
                        ': .....................................................',
                        style: pw.TextStyle(font: regularFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        ': .....................................................',
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
                    ['1.', 'Jumlah Kelompok dibentuk', ''],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['2.', 'Jumlah Bangunan', ''],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['3.', 'Jumlah Kepala Rumah Tangga (KRT)', ''],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['4.', 'Jumlah Keluarga', ''],
                    font: regularFont,
                    height: 24,
                    alignments: [
                      pw.Alignment.center,
                      pw.Alignment.centerLeft,
                      pw.Alignment.center,
                    ],
                  ),
                  _buildEmptyTableRow(
                    ['5.', 'Jumlah Individu', ''],
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
                  for (int i = 1; i <= 5; i++)
                    _buildEmptyTableRow(
                      ['$i', '', '', '', '', '', '', ''],
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
                        'Ketua Kelompok PKK RT      .... ,',
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

  /// =========================================================================
  /// FORM II: DATA KELOMPOK DASAWISMA PKK (TEMPLATE KOSONG)
  /// Format: Portrait
  /// =========================================================================
  /// =========================================================================
  Future<Uint8List> generateBlankForm2({pw.Document? existingPdf}) async {
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
                          style: pw.TextStyle(font: regularFont, fontSize: 10),
                        ),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          style: pw.TextStyle(font: regularFont, fontSize: 10),
                        ),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          style: pw.TextStyle(font: regularFont, fontSize: 10),
                        ),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabel Data
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
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
                      _buildAdvancedHeaderCell('Jumlah\nKeluarga', regularFont),
                      _buildAdvancedHeaderCell('Jumlah\nIndividu', regularFont),
                    ],
                  ),
                  for (int i = 1; i <= 19; i++)
                    _buildEmptyTableRow(
                      ['$i', '', '', '', '', ''],
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
                      pw.Container(), // empty
                      _buildAdvancedHeaderCell(
                        'JUMLAH',
                        regularFont,
                        fontSize: 7,
                      ),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
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

    if (existingPdf != null) return Uint8List(0);
    return pdf.save();
  }

  Future<Uint8List> generateBlankForm1And2({
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
  }) async {
    final pdf = pw.Document();

    await generateBlankForm1(
      kabupaten: kabupaten,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      existingPdf: pdf,
    );

    await generateBlankForm2(existingPdf: pdf);

    return pdf.save();
  }

  /// =========================================================================
  /// FORM III: DATA KUANTITAS (TEMPLATE KOSONG)
  /// Format: Landscape, F4
  /// =========================================================================

  Future<Uint8List> generateBlankForm3() async {
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
            fontSize: isHeader ? 6 : 8,
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
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DATA KUANTITAS',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.SizedBox(height: 16),

              // Header Info
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
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kelompok',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'RT / RW',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kelurahan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kecamatan',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
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
                          'Kota',
                          style: pw.TextStyle(font: regularFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Text(
                          'Jakarta Timur',
                          style: pw.TextStyle(font: boldFont, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabel Data Kuantitas (Custom Layout to fix Colspan issues)
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row 1: Main Headers
                    pw.Container(
                      height: 45,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.yellow,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('NO', width: 20, isHeader: true),
                          buildCell('NAMA KRT', flex: 3, isHeader: true),
                          buildCell(
                            'NAMA KEPALA KELUARGA',
                            flex: 4,
                            isHeader: true,
                          ),
                          pw.Expanded(
                            flex: 8,
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
                                    'Jumlah dan Komposisi Penduduk',
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
                                          'LAKI-LAKI',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'PEREMPUAN',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Jumlah',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Balita\n(0-5 Thn)',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Anak\n(6-9 Thn)',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Remaja\n(10-24 Thn)',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Dewasa\n(25-59 Thn)',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Lansia\n(60 + Thn)',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildCell(
                            'Jumlah\nKeluarga',
                            flex: 1,
                            isHeader: true,
                          ),
                          buildCell(
                            'Jumlah\nPasangan\nUsia Subur (PUS)',
                            flex: 1,
                            isHeader: true,
                          ),
                          pw.Expanded(
                            flex: 8,
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
                                    'Jumlah Kesertaan Ber-KB',
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
                                          'MOW/Steril\nWanita',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'MOP/Steril\nPria',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'IUD/Spiral\nAKDR',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Implant/\nSusuk',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Suntik',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Pil',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Kondom',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Jumlah\nPeserta KB',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 5,
                            child: pw.Container(
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  buildCell(
                                    'Bukan Peserta KB',
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
                                          'TIAL',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'IAT',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'IAS',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Hamil',
                                          flex: 1,
                                          isHeader: true,
                                        ),
                                        buildCell(
                                          'Jumlah Bukan\nPeserta KB',
                                          flex: 1,
                                          isHeader: true,
                                          noRightBorder: true,
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
                    // Row 2: Sub Headers (Column Numbers)
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('1', width: 20, isHeader: true),
                          buildCell('2', flex: 3, isHeader: true),
                          buildCell('3', flex: 4, isHeader: true),
                          buildCell(
                            '4',
                            flex: 8,
                            isHeader: true,
                          ), // 1+1+1+5 = 8 columns
                          buildCell('5', flex: 1, isHeader: true),
                          buildCell('6', flex: 1, isHeader: true),
                          buildCell('7', flex: 8, isHeader: true),
                          buildCell(
                            '8',
                            flex: 5,
                            isHeader: true,
                            noRightBorder: true,
                          ),
                        ],
                      ),
                    ),
                    // Empty Data Rows
                    for (int i = 0; i < 19; i++)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell('', width: 20),
                            buildCell('', flex: 3),
                            buildCell('', flex: 4),
                            for (int j = 0; j < 23; j++)
                              buildCell('', flex: 1, noRightBorder: j == 22),
                          ],
                        ),
                      ),
                    // Jumlah Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.yellow,
                        border: pw.Border(top: pw.BorderSide(width: 0.5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          buildCell('', width: 20),
                          buildCell(
                            'Jumlah',
                            flex: 7,
                            isHeader: false,
                          ), // Spans NAMA KRT (3) + KEPALA KELUARGA (4)
                          for (int j = 0; j < 23; j++)
                            buildCell('', flex: 1, noRightBorder: j == 22),
                        ],
                      ),
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
  /// FORM DATA MANUAL TARGET SASARAN PENDATAAN
  /// Format: Landscape, F4
  /// =========================================================================
  Future<Uint8List> generateBlankFormDataManual() async {
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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: formatF4Landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
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
                      '.......................................',
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
                      '.......................................',
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
                      '.......................................',
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

                // Empty Rows
                for (int i = 1; i <= 20; i++)
                  pw.TableRow(
                    children: List.generate(
                      18,
                      (index) => pw.Container(
                        height: 20,
                        alignment: pw.Alignment.center,
                        child: index == 0
                            ? pw.Text(
                                '$i',
                                style: pw.TextStyle(font: ttf, fontSize: 8),
                              )
                            : null,
                      ),
                    ),
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

final pdfBlankServiceProvider = Provider<PdfBlankService>((ref) {
  return PdfBlankService();
});
