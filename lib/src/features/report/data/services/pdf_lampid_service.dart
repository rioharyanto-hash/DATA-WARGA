import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfLampidService {
  Future<Uint8List> generateLampidPdf({
    required String? kelompokDawis,
    required String bulan,
    required String tahun,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

    final regularFont = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    final headerTextStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 10,
    );
    final cellTextStyle = pw.TextStyle(
      font: regularFont,
      fontSize: 8,
    );
    final boldCellTextStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 8,
    );

    pw.Widget _buildCell(
      String text, {
      bool isHeader = false,
      pw.Alignment alignment = pw.Alignment.centerLeft,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: isHeader ? pw.Alignment.center : alignment,
        child: pw.Text(
          text,
          textAlign: isHeader ? pw.TextAlign.center : (alignment == pw.Alignment.centerRight ? pw.TextAlign.right : (alignment == pw.Alignment.centerLeft ? pw.TextAlign.left : pw.TextAlign.center)),
          style: isHeader ? boldCellTextStyle : cellTextStyle,
        ),
      );
    }

    int totalL = 0;
    int totalP = 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(33.0 * PdfPageFormat.cm, 21.5 * PdfPageFormat.cm, marginAll: 32),
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'DATA KEJADIAN',
                style: headerTextStyle,
              ),
            ),
            pw.Center(
              child: pw.Text(
                'LAHIR, MATI, PINDAH DATANG',
                style: headerTextStyle,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('KELOMPOK : ${kelompokDawis ?? "SEMUA KADER"}', style: cellTextStyle),
                    pw.SizedBox(height: 4),
                    pw.Text('BULAN : $bulan', style: cellTextStyle),
                    pw.SizedBox(height: 4),
                    pw.Text('TAHUN : $tahun', style: cellTextStyle),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(width: 1), // This guarantees PERFECT grid lines always!
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(4),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
                6: const pw.FlexColumnWidth(1.5), // USIA
                7: const pw.FlexColumnWidth(2),
                8: const pw.FlexColumnWidth(3),
                9: const pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    _buildCell('NO', isHeader: true),
                    _buildCell('NAMA BANGUNAN', isHeader: true),
                    _buildCell('NAMA INDIVIDU', isHeader: true),
                    _buildCell('ALAMAT', isHeader: true),
                    _buildCell('LAKI-LAKI\n(L)', isHeader: true),
                    _buildCell('PEREMPUAN\n(P)', isHeader: true),
                    _buildCell('USIA', isHeader: true),
                    _buildCell('TANGGAL', isHeader: true),
                    _buildCell('KEJADIAN\nLAMPID', isHeader: true),
                    _buildCell('KETERANGAN', isHeader: true),
                  ],
                ),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    _buildCell('1', isHeader: true),
                    _buildCell('2', isHeader: true),
                    _buildCell('3', isHeader: true),
                    _buildCell('4', isHeader: true),
                    _buildCell('5', isHeader: true),
                    _buildCell('6', isHeader: true),
                    _buildCell('7', isHeader: true),
                    _buildCell('8', isHeader: true),
                    _buildCell('9', isHeader: true),
                    _buildCell('10', isHeader: true),
                  ],
                ),
                ...List.generate(data.length, (index) {
                  final row = data[index];
                  
                  String jk = row['jenis_kelamin']?.toString() ?? '';
                  if (jk.isEmpty) {
                    final nik = row['nik']?.toString() ?? '';
                    if (nik.length >= 16) {
                      final dayStr = nik.substring(6, 8);
                      final day = int.tryParse(dayStr);
                      if (day != null) {
                        jk = day > 40 ? 'Perempuan' : 'Laki-laki';
                      }
                    }
                  }
                  
                  bool isL = jk.toLowerCase() == 'laki-laki' || jk.toLowerCase() == 'l';
                  bool isP = jk.toLowerCase() == 'perempuan' || jk.toLowerCase() == 'p';
                  
                  if (isL) totalL++;
                  if (isP) totalP++;
                  
                  String tgl = row['tanggal_mutasi']?.toString() ?? '';
                  DateTime? dtMutasi;
                  if (tgl.isNotEmpty && tgl.contains('-')) {
                    try {
                      dtMutasi = DateTime.parse(tgl);
                      tgl = DateFormat('dd-MM-yyyy').format(dtMutasi);
                    } catch (e) {
                      // ignore
                    }
                  }
                  
                  String jenisMutasi = row['jenis_mutasi']?.toString() ?? '';
                  String usiaStr = '';
                  String tglLahirStr = row['tanggal_lahir']?.toString() ?? '';
                  if (tglLahirStr.isNotEmpty) {
                    try {
                      final tglLahir = DateTime.parse(tglLahirStr);
                      final refDate = dtMutasi ?? DateTime.now();
                      int age = refDate.year - tglLahir.year;
                      if (refDate.month < tglLahir.month || 
                          (refDate.month == tglLahir.month && refDate.day < tglLahir.day)) {
                        age--;
                      }
                      if (age >= 0) {
                        usiaStr = '$age';
                      }
                    } catch (e) {
                      // ignore
                    }
                  }
                  
                  return pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      _buildCell('${index + 1}', alignment: pw.Alignment.center),
                      _buildCell(row['nama_bangunan']?.toString() ?? ''),
                      _buildCell(row['nama_orang']?.toString() ?? ''),
                      _buildCell(row['alamat_lengkap']?.toString() ?? ''),
                      _buildCell(isL ? '1' : '', isHeader: true),
                      _buildCell(isP ? '1' : '', isHeader: true),
                      _buildCell(usiaStr, isHeader: true),
                      _buildCell(tgl, isHeader: true),
                      _buildCell(jenisMutasi),
                      _buildCell(row['keterangan']?.toString() ?? ''),
                    ],
                  );
                }),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    _buildCell(''),
                    _buildCell('JUMLAH', isHeader: true),
                    _buildCell('${data.length}', isHeader: true),
                    _buildCell(''),
                    _buildCell('$totalL', isHeader: true),
                    _buildCell('$totalP', isHeader: true),
                    _buildCell(''),
                    _buildCell(''),
                    _buildCell(''),
                    _buildCell(''),
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
