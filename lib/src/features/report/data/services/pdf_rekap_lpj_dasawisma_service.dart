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

    final List<List<dynamic>> tableData = [];

    for (int i = 0; i < dataList.length; i++) {
      final row = dataList[i];
      tableData.add([
        (i + 1).toString(),
        row['nama_kader']?.toString() ?? '',
        row['nama_kelompok']?.toString() ?? '',
        row['rt']?.toString() ?? '',
        row['jml_rumah']?.toString() ?? '0',
        row['jml_keluarga']?.toString() ?? '0',
        row['jml_warga_l']?.toString() ?? '0',
        row['jml_warga_p']?.toString() ?? '0',
        row['jml_bayi_l']?.toString() ?? '0',
        row['jml_bayi_p']?.toString() ?? '0',
        row['jml_meninggal']?.toString() ?? '0',
        row['jml_pindah']?.toString() ?? '0',
        row['jml_pindahan']?.toString() ?? '0',
      ]);
    }

    final headers = [
      'NO',
      'NAMA KADER',
      'NAMA KELOMPOK',
      'RT',
      'JML RUMAH DIDATA',
      'JUMLAH KELUARGA DIDATA',
      'JUMLAH WARGA\nYANG DIDATA\nL',
      'JUMLAH WARGA\nYANG DIDATA\nP',
      'JUMLAH BAYI\nYANG DIDATA\nL',
      'JUMLAH BAYI\nYANG DIDATA\nP',
      'JUMLAH\nWARGA\nMENINGGAL',
      'JUMLAH\nWARGA\nPINDAH',
      'JUMLAH\nWARGA\nPINDAHAN',
    ];

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
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: tableData,
              border: pw.TableBorder.all(width: 1),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
                9: pw.Alignment.center,
                10: pw.Alignment.center,
                11: pw.Alignment.center,
                12: pw.Alignment.center,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(0.8),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.2),
                6: const pw.FlexColumnWidth(1.0),
                7: const pw.FlexColumnWidth(1.0),
                8: const pw.FlexColumnWidth(1.0),
                9: const pw.FlexColumnWidth(1.0),
                10: const pw.FlexColumnWidth(1.2),
                11: const pw.FlexColumnWidth(1.0),
                12: const pw.FlexColumnWidth(1.2),
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
