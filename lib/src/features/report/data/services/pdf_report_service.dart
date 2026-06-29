import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportService {
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

    // Width definitions
    final wNo = 15.0;
    final wNama = 65.0;
    final wKk = 20.0;

    final wLp = 15.0;
    final wAge = 18.0;
    final wKriteria = 22.0;

    // Totals
    int totalKk = 0,
        totL = 0,
        totP = 0,
        balitaL = 0,
        balitaP = 0,
        pus = 0,
        wus = 0,
        hamil = 0,
        menyusui = 0,
        lansia = 0,
        buta = 0,
        khusus = 0;
    int sehat = 0, tdkSehat = 0, sampah = 0, spal = 0, jamban = 0, stiker = 0;
    int pdam = 0, sumur = 0, dll = 0;
    int beras = 0, nonBeras = 0;
    int up2k = 0, pekarangan = 0, industri = 0, kerja = 0;

    final rowsData = data['rows'] as List<dynamic>? ?? [];

    pw.Widget buildHeader() {
      final style = pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold);
      final border = pw.Border.all(width: 0.5);
      final borderRight = pw.Border(right: pw.BorderSide(width: 0.5));
      final borderBottom = pw.Border(bottom: pw.BorderSide(width: 0.5));

      pw.Widget headerCell(String text, double w, [pw.Border? b]) {
        return pw.Expanded(
          flex: w.toInt(),
          child: pw.Container(
            decoration: pw.BoxDecoration(border: b ?? borderRight),
            child: pw.Center(
              child: pw.Text(
                text,
                style: style,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        );
      }

      return pw.Container(
        height: 36,
        decoration: pw.BoxDecoration(border: border),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // 1, 2, 3
            headerCell('NO', wNo),
            headerCell('NAMA KEPALA\nRUMAH TANGGA', wNama),
            headerCell('JML\nKK', wKk),
            // JUMLAH ANGGOTA KELUARGA
            pw.Expanded(
              flex: (wLp * 4 + wAge * 7).toInt(),
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
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // TOTAL
                          pw.Expanded(
                            flex: (wLp * 2).toInt(),
                            child: pw.Container(
                              decoration: pw.BoxDecoration(border: borderRight),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    height: 12,
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
                                          child: pw.Center(
                                            child: pw.Text('P', style: style),
                                          ),
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
                            flex: (wLp * 2).toInt(),
                            child: pw.Container(
                              decoration: pw.BoxDecoration(border: borderRight),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    height: 12,
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
                                          child: pw.Center(
                                            child: pw.Text('P', style: style),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          headerCell('PUS', wAge),
                          headerCell('WUS', wAge),
                          headerCell('IBU\nHAMIL', wAge),
                          headerCell('IBU\nMENYUSUI', wAge),
                          headerCell('LANSIA', wAge),
                          headerCell('3\nBUTA', wAge),
                          headerCell(
                            'BERKE\nBUTUHAN\nKHUSUS',
                            wAge,
                            pw.Border(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // KRITERIA RUMAH
            pw.Expanded(
              flex: (wKriteria * 6).toInt(),
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
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          headerCell('SEHAT\nLAYAK\nHUNI', wKriteria),
                          headerCell('TIDAK\nSEHAT\nLAYAK HUNI', wKriteria),
                          headerCell(
                            'MEMILIKI\nTMP.\nPEMB.\nSAMPAH',
                            wKriteria,
                          ),
                          headerCell('MEMILIKI\nSPAL', wKriteria),
                          headerCell('MEMILIKI\nJAMBAN\nKELUARGA', wKriteria),
                          headerCell(
                            'MENEMPEL\nSTIKER\nP4K',
                            wKriteria,
                            pw.Border(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SUMBER AIR KELUARGA
            pw.Expanded(
              flex: (wAge * 3).toInt(),
              child: pw.Container(
                decoration: pw.BoxDecoration(border: borderRight),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 12,
                      decoration: pw.BoxDecoration(border: borderBottom),
                      child: pw.Center(
                        child: pw.Text('SUMBER AIR', style: style),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          headerCell('PDAM', wAge),
                          headerCell('SUMUR', wAge),
                          headerCell('DLL', wAge, pw.Border()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // MAKANAN POKOK
            pw.Expanded(
              flex: (wAge * 2).toInt(),
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
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          headerCell('BERAS', wAge),
                          headerCell('NON\nBERAS', wAge, pw.Border()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // WARGA MENGIKUTI KEGIATAN
            pw.Expanded(
              flex: (wKriteria * 4).toInt(),
              child: pw.Container(
                decoration: pw.BoxDecoration(border: borderRight),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 12,
                      decoration: pw.BoxDecoration(border: borderBottom),
                      child: pw.Center(
                        child: pw.Text(
                          'WARGA MENGIKUTI KEGIATAN',
                          style: style,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          headerCell('UP2K', wKriteria),
                          pw.Expanded(
                            flex: wKriteria.toInt(),
                            child: pw.Container(
                              decoration: pw.BoxDecoration(border: borderRight),
                              child: pw.Center(
                                child: pw.Text(
                                  'PEMAN\nFAATAN\nPEKA\nRANGAN',
                                  style: pw.TextStyle(
                                    fontSize: 4,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          headerCell('INDUSTRI\nRUMAH\nTANGGA', wKriteria),
                          headerCell('KERJA\nBAKTI', wKriteria, pw.Border()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: wAge.toInt(),
              child: pw.Container(
                decoration: const pw.BoxDecoration(),
                child: pw.Center(child: pw.Text('KET', style: style)),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildNumbers() {
      final style = pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold);
      final border = pw.Border(
        left: pw.BorderSide(width: 0.5),
        right: pw.BorderSide(width: 0.5),
        bottom: pw.BorderSide(width: 0.5),
      );
      final borderRight = pw.Border(
        right: pw.BorderSide(width: 0.5),
        bottom: pw.BorderSide(width: 0.5),
      );

      pw.Widget numCell(String text, double w, [pw.Border? b]) {
        return pw.Expanded(
          flex: w.toInt(),
          child: pw.Container(
            height: 10,
            decoration: pw.BoxDecoration(border: b ?? borderRight),
            child: pw.Center(child: pw.Text(text, style: style)),
          ),
        );
      }

      return pw.Row(
        children: [
          numCell('1', wNo, border),
          numCell('2', wNama),
          numCell('3', wKk),
          numCell('4', wLp),
          numCell('5', wLp),
          numCell('6', wLp),
          numCell('7', wLp),
          numCell('8', wAge),
          numCell('9', wAge),
          numCell('10', wAge),
          numCell('11', wAge),
          numCell('12', wAge),
          numCell('13', wAge),
          numCell('14', wAge),
          numCell('15', wKriteria),
          numCell('16', wKriteria),
          numCell('17', wKriteria),
          numCell('18', wKriteria),
          numCell('19', wKriteria),
          numCell('20', wKriteria),
          numCell('21', wAge),
          numCell('22', wAge),
          numCell('23', wAge),
          numCell('24', wAge),
          numCell('25', wAge),
          numCell('26', wKriteria),
          numCell('27', wKriteria),
          numCell('28', wKriteria),
          numCell('29', wKriteria),
          numCell('30', wAge),
        ],
      );
    }

    pw.Widget buildRow(int index, Map<String, dynamic> r, bool isTotal) {
      final style = pw.TextStyle(
        fontSize: 6,
        fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
      );

      pw.Widget valCell(
        String text,
        double w, [
        pw.Alignment align = pw.Alignment.center,
      ]) {
        return pw.Expanded(
          flex: w.toInt(),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(right: pw.BorderSide(width: 0.5)),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 1,
                vertical: 1,
              ),
              child: pw.Align(
                alignment: align,
                child: pw.Text(text, style: style),
              ),
            ),
          ),
        );
      }

      return pw.Container(
        height: 14,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(width: 0.5),
            right: pw.BorderSide(width: 0.5),
            bottom: pw.BorderSide(width: 0.5),
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            valCell(isTotal ? '' : '${index + 1}', wNo),
            valCell(
              isTotal ? 'JUMLAH' : (r['namaKrt']?.toString() ?? ''),
              wNama,
              isTotal ? pw.Alignment.center : pw.Alignment.centerLeft,
            ),
            valCell(r['jmlKk']?.toString() ?? '0', wKk),
            valCell(r['jiwaLaki']?.toString() ?? '0', wLp),
            valCell(r['jiwaPerempuan']?.toString() ?? '0', wLp),
            valCell(r['balitaLaki']?.toString() ?? '0', wLp),
            valCell(r['balitaPerempuan']?.toString() ?? '0', wLp),
            valCell(r['pus']?.toString() ?? '0', wAge),
            valCell(r['wus']?.toString() ?? '0', wAge),
            valCell(r['ibuHamil']?.toString() ?? '0', wAge),
            valCell(r['ibuMenyusui']?.toString() ?? '0', wAge),
            valCell(r['lansia']?.toString() ?? '0', wAge),
            valCell(r['buta']?.toString() ?? '0', wAge),
            valCell(r['berkebutuhanKhusus']?.toString() ?? '0', wAge),
            valCell(r['rumahSehat']?.toString() ?? '0', wKriteria),
            valCell(r['rumahTidakSehat']?.toString() ?? '0', wKriteria),
            valCell(r['punyaTempatSampah']?.toString() ?? '0', wKriteria),
            valCell(r['punyaSpal']?.toString() ?? '0', wKriteria),
            valCell(r['punyaJamban']?.toString() ?? '0', wKriteria),
            valCell(r['tempelStiker']?.toString() ?? '0', wKriteria),
            valCell(r['sumberAirPdam']?.toString() ?? '0', wAge),
            valCell(r['sumberAirSumur']?.toString() ?? '0', wAge),
            valCell(r['sumberAirLainnya']?.toString() ?? '0', wAge),
            valCell(r['makananBeras']?.toString() ?? '0', wAge),
            valCell(r['makananNonBeras']?.toString() ?? '0', wAge),
            valCell(r['ikutUp2k']?.toString() ?? '0', wKriteria),
            valCell(r['pekarangan']?.toString() ?? '0', wKriteria),
            valCell(r['industriRT']?.toString() ?? '0', wKriteria),
            valCell(r['kerjaBakti']?.toString() ?? '0', wKriteria),
            valCell(r['keterangan']?.toString() ?? '0', wAge),
          ],
        ),
      );
    }

    // Calculate totals
    for (var r in rowsData) {
      totalKk += _parseInt(r['jmlKk']);
      totL += _parseInt(r['jiwaLaki']);
      totP += _parseInt(r['jiwaPerempuan']);
      balitaL += _parseInt(r['balitaLaki']);
      balitaP += _parseInt(r['balitaPerempuan']);
      pus += _parseInt(r['pus']);
      wus += _parseInt(r['wus']);
      hamil += _parseInt(r['ibuHamil']);
      menyusui += _parseInt(r['ibuMenyusui']);
      lansia += _parseInt(r['lansia']);
      buta += _parseInt(r['buta']);
      khusus += _parseInt(r['berkebutuhanKhusus']);
      sehat += _parseInt(r['rumahSehat']);
      tdkSehat += _parseInt(r['rumahTidakSehat']);
      sampah += _parseInt(r['punyaTempatSampah']);
      spal += _parseInt(r['punyaSpal']);
      jamban += _parseInt(r['punyaJamban']);
      stiker += _parseInt(r['tempelStiker']);
      pdam += _parseInt(r['sumberAirPdam']);
      sumur += _parseInt(r['sumberAirSumur']);
      dll += _parseInt(r['sumberAirLainnya']);
      beras += _parseInt(r['makananBeras']);
      nonBeras += _parseInt(r['makananNonBeras']);
      up2k += _parseInt(r['ikutUp2k']);
      pekarangan += _parseInt(r['pekarangan']);
      industri += _parseInt(r['industriRT']);
      kerja += _parseInt(r['kerjaBakti']);
    }

    final totalRowData = {
      'jmlKk': totalKk,
      'jiwaLaki': totL,
      'jiwaPerempuan': totP,
      'balitaLaki': balitaL,
      'balitaPerempuan': balitaP,
      'pus': pus,
      'wus': wus,
      'ibuHamil': hamil,
      'ibuMenyusui': menyusui,
      'lansia': lansia,
      'buta': buta,
      'berkebutuhanKhusus': khusus,
      'rumahSehat': sehat,
      'rumahTidakSehat': tdkSehat,
      'punyaTempatSampah': sampah,
      'punyaSpal': spal,
      'punyaJamban': jamban,
      'tempelStiker': stiker,
      'sumberAirPdam': pdam,
      'sumberAirSumur': sumur,
      'sumberAirLainnya': dll,
      'makananBeras': beras,
      'makananNonBeras': nonBeras,
      'ikutUp2k': up2k,
      'pekarangan': pekarangan,
      'industriRT': industri,
      'kerjaBakti': kerja,
    };

    final year = DateTime.now().year.toString();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          33.0 * PdfPageFormat.cm,
          21.0 * PdfPageFormat.cm,
          marginAll: 1 * PdfPageFormat.cm,
        ),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'REKAPITULASI\nCATATAN DATA DAN KEGIATAN WARGA\nKELOMPOK DASAWISMA',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('DASA WISMA', namaKelompok),
                      _buildInfoRow('RT', rt),
                      _buildInfoRow('RW', rw),
                      _buildInfoRow('DESA / KELURAHAN', desa),
                      _buildInfoRow('TAHUN', year),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              buildHeader(),
              buildNumbers(),
            ],
          );
        },
        build: (pw.Context context) {
          List<pw.Widget> children = [];
          for (int i = 0; i < rowsData.length; i++) {
            children.add(
              buildRow(i, rowsData[i] as Map<String, dynamic>, false),
            );
          }
          if (rowsData.isEmpty) {
            // empty lines
            for (int i = 0; i < 5; i++) {
              children.add(buildRow(i, {}, false));
            }
          }
          children.add(buildRow(0, totalRowData, true));

          return [pw.Column(children: children)];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildInfoRow(String label, String value) {
    final labelStyle = pw.TextStyle(fontSize: 8);
    return pw.Row(
      children: [
        pw.SizedBox(width: 100, child: pw.Text(label, style: labelStyle)),
        pw.Text(': ', style: labelStyle),
        pw.Text(value, style: labelStyle),
      ],
    );
  }

  /// =========================================================================
  /// FORM REKAPITULASI: CATATAN DATA DAN KEGIATAN WARGA (TEMPLATE KOSONG)
  /// Format: Landscape, F4
  /// =========================================================================
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
  Future<Uint8List> generateProfilUsiaPdf({
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
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
                  ': ',
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
  Future<Uint8List> generateFormDataPotensiWarga({
    required List<Map<String, dynamic>> data,
    required String kelompokName,
    required String pkkRw,
    required String dusun,
    required String desa,
    required String tahun,
    required String periode,
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

    // Split data into chunks of 15 rows to handle page breaks
    const itemsPerPage = 15;
    final pages = (data.length / itemsPerPage).ceil();
    final totalPages = pages > 0 ? pages : 1;

    // Hitung Total (Baris terakhir)
    int tKrt = 0;
    int tKk = 0;
    int tL = 0;
    int tP = 0;
    int tBalitaL = 0;
    int tBalitaP = 0;
    int tAktifPosyanduL = 0;
    int tAktifPosyanduP = 0;
    int tPus = 0;
    int tTidakKb = 0;
    int tKbPil = 0;
    int tKbIud = 0;
    int tKbImplan = 0;
    int tKbSuntik = 0;
    int tKbKondom = 0;
    int tKbSteril = 0;
    int tKbLainnya = 0;
    int tRemajaL = 0;
    int tRemajaP = 0;
    int tAktifPosremL = 0;
    int tAktifPosremP = 0;
    int tLansiaL = 0;
    int tLansiaP = 0;
    int tAktifPoslanL = 0;
    int tAktifPoslanP = 0;
    int tDifabelL = 0;
    int tDifabelP = 0;

    for (var r in data) {
      tKrt += r['jmlKrt'] as int? ?? 0;
      tKk += r['jmlKk'] as int? ?? 0;
      tL += r['L'] as int? ?? 0;
      tP += r['P'] as int? ?? 0;
      tBalitaL += r['balitaL'] as int? ?? 0;
      tBalitaP += r['balitaP'] as int? ?? 0;
      tAktifPosyanduL += r['balitaAktifL'] as int? ?? 0;
      tAktifPosyanduP += r['balitaAktifP'] as int? ?? 0;
      tPus += r['pus'] as int? ?? 0;
      tTidakKb += r['tidakKb'] as int? ?? 0;
      tKbPil += r['kbPil'] as int? ?? 0;
      tKbIud += r['kbIud'] as int? ?? 0;
      tKbImplan += r['kbImplan'] as int? ?? 0;
      tKbSuntik += r['kbSuntik'] as int? ?? 0;
      tKbKondom += r['kbKondom'] as int? ?? 0;
      tKbSteril += r['kbSteril'] as int? ?? 0;
      tKbLainnya += r['kbLainnya'] as int? ?? 0;
      tRemajaL += r['remajaL'] as int? ?? 0;
      tRemajaP += r['remajaP'] as int? ?? 0;
      tAktifPosremL += r['remajaAktifL'] as int? ?? 0;
      tAktifPosremP += r['remajaAktifP'] as int? ?? 0;
      tLansiaL += r['lansiaL'] as int? ?? 0;
      tLansiaP += r['lansiaP'] as int? ?? 0;
      tAktifPoslanL += r['lansiaAktifL'] as int? ?? 0;
      tAktifPoslanP += r['lansiaAktifP'] as int? ?? 0;
      tDifabelL += r['berkebutuhanL'] as int? ?? 0;
      tDifabelP += r['berkebutuhanP'] as int? ?? 0;
    }

    for (int pIndex = 0; pIndex < totalPages; pIndex++) {
      final start = pIndex * itemsPerPage;
      final end = (start + itemsPerPage) > data.length
          ? data.length
          : (start + itemsPerPage);
      final pageData = data.sublist(start, end);

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
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
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
                              child: pw.Text(
                                pkkRw,
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
                                'DUSUN / LINGKUNGAN',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
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
                              child: pw.Text(
                                dusun,
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
                                'DESA / KELURAHAN',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
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
                              child: pw.Text(
                                desa,
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
                                'TAHUN',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
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
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 140,
                              child: pw.Text(
                                'PERIODE',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8,
                                ),
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
                              child: pw.Text(
                                periode,
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
                pw.SizedBox(height: 16),

                // Tabel Data Potensi Warga
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1.0),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Row 1: Main Headers
                      pw.Container(
                        height: 48,
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            buildCell(
                              'NO',
                              flex: 1,
                              isHeader: true,
                              fontSize: 5,
                            ),
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
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
                                                crossAxisAlignment: pw
                                                    .CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  buildCell(
                                                    'AKTIF POSYANDU',
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
                                                          .center,
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
                                        children: [
                                          buildCell(
                                            'TIDAK\nKB',
                                            flex: 1,
                                            isHeader: true,
                                            fontSize: 4,
                                          ),
                                          buildCell(
                                            'PIL',
                                            flex: 1,
                                            isHeader: true,
                                            fontSize: 4,
                                          ),
                                          buildCell(
                                            'IUD',
                                            flex: 1,
                                            isHeader: true,
                                            fontSize: 4,
                                          ),
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Container(
                                              alignment: pw.Alignment.center,
                                              decoration:
                                                  const pw.BoxDecoration(
                                                    border: pw.Border(
                                                      right: pw.BorderSide(
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                              child: pw.Transform.rotateBox(
                                                angle: 1.5708,
                                                child: pw.Text(
                                                  'IMPLAN',
                                                  style: pw.TextStyle(
                                                    font: boldFont,
                                                    fontSize: 4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Container(
                                              alignment: pw.Alignment.center,
                                              decoration:
                                                  const pw.BoxDecoration(
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
                                                    fontSize: 4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Container(
                                              alignment: pw.Alignment.center,
                                              decoration:
                                                  const pw.BoxDecoration(
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
                                                    fontSize: 4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            flex: 1,
                                            child: pw.Container(
                                              alignment: pw.Alignment.center,
                                              decoration:
                                                  const pw.BoxDecoration(
                                                    border: pw.Border(
                                                      right: pw.BorderSide(
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                              child: pw.Transform.rotateBox(
                                                angle: 1.5708,
                                                child: pw.Text(
                                                  'STERIL',
                                                  style: pw.TextStyle(
                                                    font: boldFont,
                                                    fontSize: 4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          buildCell(
                                            'LAINN\nYA',
                                            flex: 1,
                                            isHeader: true,
                                            noRightBorder: true,
                                            fontSize: 4,
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
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
                                                crossAxisAlignment: pw
                                                    .CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  buildCell(
                                                    'AKTIF POSREM',
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
                                                          .center,
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
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
                                                crossAxisAlignment: pw
                                                    .CrossAxisAlignment
                                                    .center,
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
                                                          .center,
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
                                      pw.CrossAxisAlignment.center,
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
                                            pw.CrossAxisAlignment.center,
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
                                flex: (j == 2) ? 4 : 1,
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

                      // Data Rows
                      for (var r in pageData)
                        pw.Container(
                          height: 16,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell(
                                r['no']?.toString() ?? '',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['namaBangunan']?.toString() ?? '',
                                flex: 4,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['jmlKrt']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['jmlKk']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['L']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['P']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['balitaL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['balitaP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['balitaAktifL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['balitaAktifP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['pus']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['tidakKb']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbPil']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbIud']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbImplan']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbSuntik']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbKondom']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbSteril']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['kbLainnya']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['remajaL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['remajaP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['remajaAktifL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['remajaAktifP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['lansiaL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['lansiaP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['lansiaAktifL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['lansiaAktifP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['berkebutuhanL']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['berkebutuhanP']?.toString() ?? '0',
                                flex: 1,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['ket']?.toString() ?? '',
                                flex: 1,
                                noRightBorder: true,
                                fontSize: 6,
                              ),
                            ],
                          ),
                        ),

                      // TOTAL Row if it's the last page
                      if (pIndex == totalPages - 1)
                        pw.Container(
                          height: 16,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell(
                                'JUMLAH',
                                flex: 5,
                                isHeader: true,
                                fontSize: 6,
                              ), // merges NO and BANGUNAN
                              buildCell(
                                tKrt.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKk.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tBalitaL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tBalitaP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPosyanduL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPosyanduP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tPus.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tTidakKb.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbPil.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbIud.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbImplan.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbSuntik.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbKondom.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbSteril.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tKbLainnya.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tRemajaL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tRemajaP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPosremL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPosremP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tLansiaL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tLansiaP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPoslanL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tAktifPoslanP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tDifabelL.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                tDifabelP.toString(),
                                flex: 1,
                                isHeader: true,
                                fontSize: 6,
                              ),
                              buildCell(
                                '',
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
              ],
            );
          },
        ),
      );
    }

    if (data.isEmpty) {
      // add empty page if no data so PDF isn't corrupt
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            33.0 * PdfPageFormat.cm,
            21.5 * PdfPageFormat.cm,
          ),
          build: (pw.Context context) {
            return pw.Center(child: pw.Text("Tidak ada data."));
          },
        ),
      );
    }

    return pdf.save();
  }

  /// =========================================================================
  /// FORM DATA POTENSI WARGA (TEMPLATE KOSONG)
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
  Future<Uint8List> generateForm3({required Map<String, dynamic> data}) async {
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
      pw.Alignment alignment = pw.Alignment.center,
      double? fontSize,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(2),
        alignment: alignment,
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

    final rows = (data['rows'] as List).cast<Map<String, dynamic>>();

    int totalL = 0, totalP = 0, totalJumlah = 0;
    int totalBalita = 0,
        totalAnak = 0,
        totalRemaja = 0,
        totalDewasa = 0,
        totalLansia = 0;
    int totalKeluarga = 0, totalPus = 0;
    int totalMow = 0,
        totalMop = 0,
        totalIud = 0,
        totalImplant = 0,
        totalSuntik = 0,
        totalPil = 0,
        totalKondom = 0,
        totalKb = 0;
    int totalTial = 0,
        totalIat = 0,
        totalIas = 0,
        totalHamil = 0,
        totalBukanKb = 0;

    for (var row in rows) {
      totalL += _parseInt(row['L']);
      totalP += _parseInt(row['P']);
      totalJumlah += _parseInt(row['jumlah']);
      totalBalita += _parseInt(row['balita']);
      totalAnak += _parseInt(row['anak']);
      totalRemaja += _parseInt(row['remaja']);
      totalDewasa += _parseInt(row['dewasa']);
      totalLansia += _parseInt(row['lansia']);
      totalKeluarga += _parseInt(row['jumlahKeluarga']);
      totalPus += _parseInt(row['pus']);
      totalMow += _parseInt(row['mow']);
      totalMop += _parseInt(row['mop']);
      totalIud += _parseInt(row['iud']);
      totalImplant += _parseInt(row['implant']);
      totalSuntik += _parseInt(row['suntik']);
      totalPil += _parseInt(row['pil']);
      totalKondom += _parseInt(row['kondom']);
      totalKb += _parseInt(row['jumlahKb']);
      totalTial += _parseInt(row['tial']);
      totalIat += _parseInt(row['iat']);
      totalIas += _parseInt(row['ias']);
      totalHamil += _parseInt(row['hamil']);
      totalBukanKb += _parseInt(row['jumlahBukanKb']);
    }

    final int chunk = 18;
    for (var i = 0; i < rows.length; i += chunk) {
      final isLastPage = i + chunk >= rows.length;
      final pageRows = rows.skip(i).take(chunk).toList();

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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            data['namaKader']?.toString() ?? '',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            data['kelompokName']?.toString() ?? '',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            '${data['rt'] ?? ''} / ${data['rw'] ?? ''}',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            data['kelurahan']?.toString() ?? '',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            data['kecamatan']?.toString() ?? '',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
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
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            data['kota']?.toString() ?? '',
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
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                            buildCell('4', flex: 8, isHeader: true),
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
                      // Data Rows
                      for (var r in pageRows)
                        pw.Container(
                          height: 16,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell(r['no']?.toString() ?? '', width: 20),
                              buildCell(
                                r['namaKrt']?.toString() ?? '',
                                flex: 3,
                                alignment: pw.Alignment.centerLeft,
                                fontSize: 6,
                              ),
                              buildCell(
                                r['namaKk']?.toString() ?? '',
                                flex: 4,
                                alignment: pw.Alignment.centerLeft,
                                fontSize: 6,
                              ),
                              buildCell(r['L']?.toString() ?? '0', flex: 1),
                              buildCell(r['P']?.toString() ?? '0', flex: 1),
                              buildCell(
                                r['jumlah']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['balita']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(r['anak']?.toString() ?? '0', flex: 1),
                              buildCell(
                                r['remaja']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['dewasa']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['lansia']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['jumlahKeluarga']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(r['pus']?.toString() ?? '0', flex: 1),
                              buildCell(r['mow']?.toString() ?? '0', flex: 1),
                              buildCell(r['mop']?.toString() ?? '0', flex: 1),
                              buildCell(r['iud']?.toString() ?? '0', flex: 1),
                              buildCell(
                                r['implant']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['suntik']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(r['pil']?.toString() ?? '0', flex: 1),
                              buildCell(
                                r['kondom']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(
                                r['jumlahKb']?.toString() ?? '0',
                                flex: 1,
                              ),
                              buildCell(r['tial']?.toString() ?? '0', flex: 1),
                              buildCell(r['iat']?.toString() ?? '0', flex: 1),
                              buildCell(r['ias']?.toString() ?? '0', flex: 1),
                              buildCell(r['hamil']?.toString() ?? '0', flex: 1),
                              buildCell(
                                r['jumlahBukanKb']?.toString() ?? '0',
                                flex: 1,
                                noRightBorder: true,
                              ),
                            ],
                          ),
                        ),
                      // Fill empty rows if needed
                      if (pageRows.length < chunk)
                        for (int j = 0; j < (chunk - pageRows.length); j++)
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
                                for (int k = 0; k < 23; k++)
                                  buildCell(
                                    '',
                                    flex: 1,
                                    noRightBorder: k == 22,
                                  ),
                              ],
                            ),
                          ),
                      // Jumlah Row (only on last page)
                      if (isLastPage)
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
                              buildCell('Jumlah', flex: 7, isHeader: false),
                              buildCell(
                                totalL.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalP.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalJumlah.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalBalita.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalAnak.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalRemaja.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalDewasa.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalLansia.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalKeluarga.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalPus.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalMow.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalMop.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalIud.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalImplant.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalSuntik.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalPil.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalKondom.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalKb.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalTial.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalIat.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalIas.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalHamil.toString(),
                                flex: 1,
                                isHeader: false,
                              ),
                              buildCell(
                                totalBukanKb.toString(),
                                flex: 1,
                                isHeader: false,
                                noRightBorder: true,
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
    }

    // Empty state handling
    if (rows.isEmpty) {
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
                pw.Text(
                  'Tidak ada data.',
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

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

  /// =========================================================================
  /// FORM DATA MANUAL TARGET SASARAN PENDATAAN
  /// Format: Landscape, F4
  /// =========================================================================
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

  Future<Uint8List> generateLampidPdf({
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
  Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf({
    required Map<String, int> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
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
      pw.Alignment alignment = pw.Alignment.center,
      PdfColor backgroundColor = PdfColors.white,
    }) {
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
        child: pw.Text(
          text,
          textAlign: alignment == pw.Alignment.centerLeft
              ? pw.TextAlign.left
              : pw.TextAlign.center,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 10 : 10),
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
                              'Kelompok',
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
                  ': ',
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
                        flex: 3,
                        isHeader: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                      buildCell(
                        'W',
                        flex: 3,
                        isHeader: true,
                        noRightBorder: true,
                        bottomBorder: true,
                        backgroundColor: PdfColors.yellow,
                      ),
                    ],
                  ),
                  // Rows
                  ...List.generate(ageGroups.length, (i) {
                    final pVal = data['${prefixList[i]}_P']?.toString() ?? '0';
                    final wVal = data['${prefixList[i]}_W']?.toString() ?? '0';
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        buildCell(ageGroups[i], flex: 2, bottomBorder: true),
                        buildCell(pVal, flex: 3, bottomBorder: true),
                        buildCell(
                          wVal,
                          flex: 3,
                          noRightBorder: true,
                          bottomBorder: true,
                        ),
                      ],
                    );
                  }),
                  // Footer (TOTAL)
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
                        data['total_P']?.toString() ?? '0',
                        flex: 3,
                        backgroundColor: PdfColors.yellow,
                      ),
                      buildCell(
                        data['total_W']?.toString() ?? '0',
                        flex: 3,
                        noRightBorder: true,
                        backgroundColor: PdfColors.yellow,
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
}

final pdfReportServiceProvider = Provider<PdfReportService>((ref) {
  return PdfReportService();
});

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
