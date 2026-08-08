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

    final List<Map<String, dynamic>> mutableDataList = List.from(dataList);

    // 1. Sort by nama_kelompok
    mutableDataList.sort((a, b) {
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

    final List<List<dynamic>> tableData = [];

    for (int i = 0; i < mutableDataList.length; i++) {
      final row = mutableDataList[i];
      final jmlRumah = int.tryParse(row['jml_rumah']?.toString() ?? '0') ?? 0;
      final jmlKeluarga =
          int.tryParse(row['jml_keluarga']?.toString() ?? '0') ?? 0;
      final jmlWargaL =
          int.tryParse(row['jml_warga_l']?.toString() ?? '0') ?? 0;
      final jmlWargaP =
          int.tryParse(row['jml_warga_p']?.toString() ?? '0') ?? 0;
      final jmlBayiL = int.tryParse(row['jml_bayi_l']?.toString() ?? '0') ?? 0;
      final jmlBayiP = int.tryParse(row['jml_bayi_p']?.toString() ?? '0') ?? 0;
      final jmlMeninggal =
          int.tryParse(row['jml_meninggal']?.toString() ?? '0') ?? 0;
      final jmlPindah = int.tryParse(row['jml_pindah']?.toString() ?? '0') ?? 0;
      final jmlPindahan =
          int.tryParse(row['jml_pindahan']?.toString() ?? '0') ?? 0;

      totalRumah += jmlRumah;
      totalKeluarga += jmlKeluarga;
      totalWargaL += jmlWargaL;
      totalWargaP += jmlWargaP;
      totalBayiL += jmlBayiL;
      totalBayiP += jmlBayiP;
      totalMeninggal += jmlMeninggal;
      totalPindah += jmlPindah;
      totalPindahan += jmlPindahan;

      tableData.add([
        (i + 1).toString(),
        row['nama_kader']?.toString() ?? '',
        row['nama_kelompok']?.toString() ?? '',
        row['rt']?.toString() ?? '',
        jmlRumah.toString(),
        jmlKeluarga.toString(),
        jmlWargaL.toString(),
        jmlWargaP.toString(),
        jmlBayiL.toString(),
        jmlBayiP.toString(),
        jmlMeninggal.toString(),
        jmlPindah.toString(),
        jmlPindahan.toString(),
      ]);
    }

    // 3. Add JUMLAH row
    tableData.add([
      '',
      'JUMLAH',
      '',
      '',
      totalRumah.toString(),
      totalKeluarga.toString(),
      totalWargaL.toString(),
      totalWargaP.toString(),
      totalBayiL.toString(),
      totalBayiP.toString(),
      totalMeninggal.toString(),
      totalPindah.toString(),
      totalPindahan.toString(),
    ]);

    // Headers matching the reference image layout:
    // JUMLAH WARGA YANG DIDATA -> L | P
    // JUMLAH BAYI YANG DIDATA -> L | P
    final headers = [
      'NO',
      'NAMA KADER',
      'NAMA KELOMPOK',
      'RT',
      'JML\nRUMAH\nDIDATA',
      'JUMLAH\nKELUARGA\nDIDATA',
      'JUMLAH WARGA\nYANG DIDATA\nL',
      'JUMLAH WARGA\nYANG DIDATA\nP',
      'JUMLAH BAYI\nYANG DIDATA\nL',
      'JUMLAH BAYI\nYANG DIDATA\nP',
      'JUMLAH\nWARGA\nMENINGGAL',
      'JUMLAH\nWARGA\nPINDAH',
      'JUMLAH\nWARGA\nPINDAHAN',
    ];

    final lastRowIndex = tableData.length - 1;

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
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
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
                3: const pw.FlexColumnWidth(0.5),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.0),
                6: const pw.FlexColumnWidth(1.0),
                7: const pw.FlexColumnWidth(1.0),
                8: const pw.FlexColumnWidth(1.0),
                9: const pw.FlexColumnWidth(1.0),
                10: const pw.FlexColumnWidth(1.0),
                11: const pw.FlexColumnWidth(1.0),
                12: const pw.FlexColumnWidth(1.0),
              },
              oddCellStyle: const pw.TextStyle(fontSize: 9),
              cellDecoration: (index, data, rowNum) {
                // Bold the last row (JUMLAH)
                if (rowNum == lastRowIndex) {
                  return const pw.BoxDecoration(color: PdfColors.grey100);
                }
                return const pw.BoxDecoration();
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
