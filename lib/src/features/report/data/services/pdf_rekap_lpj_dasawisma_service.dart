import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfRekapLpjDasawismaService {
  Future<Uint8List> generate(
    List<Map<String, dynamic>> dataList,
    String rw,
    String monthYear,
    String? kelurahan,
    String? kecamatan,
  ) async {
    final pdf = pw.Document();

    // 1. Sort by nama_kelompok
    dataList.sort((a, b) {
      final nameA = a['nama_kelompok']?.toString() ?? '';
      final nameB = b['nama_kelompok']?.toString() ?? '';
      return nameA.compareTo(nameB);
    });

    // 2. Calculate Totals
    int totalRumah = 0;
    int totalKeluarga = 0;
    int totalWargaL = 0;
    int totalWargaP = 0;
    int totalBayiL = 0;
    int totalBayiP = 0;
    int totalMeninggal = 0;
    int totalPindah = 0;
    int totalPindahan = 0;

    for (var row in dataList) {
      totalRumah += int.tryParse(row['jml_rumah']?.toString() ?? '0') ?? 0;
      totalKeluarga +=
          int.tryParse(row['jml_keluarga']?.toString() ?? '0') ?? 0;
      totalWargaL += int.tryParse(row['jml_warga_l']?.toString() ?? '0') ?? 0;
      totalWargaP += int.tryParse(row['jml_warga_p']?.toString() ?? '0') ?? 0;
      totalBayiL += int.tryParse(row['jml_bayi_l']?.toString() ?? '0') ?? 0;
      totalBayiP += int.tryParse(row['jml_bayi_p']?.toString() ?? '0') ?? 0;
      totalMeninggal +=
          int.tryParse(row['jml_meninggal']?.toString() ?? '0') ?? 0;
      totalPindah += int.tryParse(row['jml_pindah']?.toString() ?? '0') ?? 0;
      totalPindahan +=
          int.tryParse(row['jml_pindahan']?.toString() ?? '0') ?? 0;
    }

    // Helper for simple cell
    pw.Widget _buildCell(
      String text, {
      pw.Alignment align = pw.Alignment.center,
      bool isHeader = false,
      bool isBold = false,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        alignment: align,
        color: isHeader ? PdfColors.grey200 : null,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isHeader ? 8 : 9,
            fontWeight: isBold || isHeader
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
      );
    }

    // Helper for split header cell (L/P)
    pw.Widget _buildSplitHeader(String title) {
      return pw.Container(
        color: PdfColors.grey200,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text(
                title,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Divider(height: 1, thickness: 1, color: PdfColors.black),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'L',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.Container(width: 1, color: PdfColors.black),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'P',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Helper for split data cell (L/P)
    pw.Widget _buildSplitData(String valL, String valP, {bool isBold = false}) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text(
                valL,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
          pw.Container(width: 1, color: PdfColors.black),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text(
                valP,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final tableRows = <pw.TableRow>[];

    // 1. Header Row
    tableRows.add(
      pw.TableRow(
        children: [
          _buildCell('NO', isHeader: true),
          _buildCell('NAMA KADER', isHeader: true),
          _buildCell('NAMA KELOMPOK', isHeader: true),
          _buildCell('RT', isHeader: true),
          _buildCell('JML RUMAH\nDIDATA', isHeader: true),
          _buildCell('JUMLAH\nKELUARGA\nDIDATA', isHeader: true),
          _buildSplitHeader('JUMLAH WARGA\nYANG DIDATA'),
          _buildSplitHeader('JUMLAH BAYI\nYANG DIDATA'),
          _buildCell('JUMLAH\nWARGA\nMENINGGAL', isHeader: true),
          _buildCell('JUMLAH\nWARGA\nPINDAH', isHeader: true),
          _buildCell('JUMLAH\nWARGA\nPINDAHAN', isHeader: true),
        ],
      ),
    );

    // 2. Data Rows
    for (int i = 0; i < dataList.length; i++) {
      final row = dataList[i];
      tableRows.add(
        pw.TableRow(
          children: [
            _buildCell((i + 1).toString()),
            _buildCell(
              row['nama_kader']?.toString() ?? '',
              align: pw.Alignment.centerLeft,
            ),
            _buildCell(
              row['nama_kelompok']?.toString() ?? '',
              align: pw.Alignment.centerLeft,
            ),
            _buildCell(row['rt']?.toString() ?? ''),
            _buildCell(row['jml_rumah']?.toString() ?? '0'),
            _buildCell(row['jml_keluarga']?.toString() ?? '0'),
            _buildSplitData(
              row['jml_warga_l']?.toString() ?? '0',
              row['jml_warga_p']?.toString() ?? '0',
            ),
            _buildSplitData(
              row['jml_bayi_l']?.toString() ?? '0',
              row['jml_bayi_p']?.toString() ?? '0',
            ),
            _buildCell(row['jml_meninggal']?.toString() ?? '0'),
            _buildCell(row['jml_pindah']?.toString() ?? '0'),
            _buildCell(row['jml_pindahan']?.toString() ?? '0'),
          ],
        ),
      );
    }

    // 3. Footer / JUMLAH Row
    tableRows.add(
      pw.TableRow(
        children: [
          _buildCell(''),
          _buildCell('JUMLAH', isBold: true, align: pw.Alignment.center),
          _buildCell(''),
          _buildCell(''),
          _buildCell(totalRumah.toString(), isBold: true),
          _buildCell(totalKeluarga.toString(), isBold: true),
          _buildSplitData(
            totalWargaL.toString(),
            totalWargaP.toString(),
            isBold: true,
          ),
          _buildSplitData(
            totalBayiL.toString(),
            totalBayiP.toString(),
            isBold: true,
          ),
          _buildCell(totalMeninggal.toString(), isBold: true),
          _buildCell(totalPindah.toString(), isBold: true),
          _buildCell(totalPindahan.toString(), isBold: true),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return [
            pw.Text(
              'REKAPAN LPJ DASAWISMA RW $rw',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            if (kelurahan != null && kecamatan != null)
              pw.Text(
                'KELURAHAN $kelurahan KECAMATAN $kecamatan',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            pw.Text(
              'BULAN $monthYear',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(0.8),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.2),
                6: const pw.FlexColumnWidth(2.0),
                7: const pw.FlexColumnWidth(2.0),
                8: const pw.FlexColumnWidth(1.2),
                9: const pw.FlexColumnWidth(1.0),
                10: const pw.FlexColumnWidth(1.2),
              },
              children: tableRows,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
