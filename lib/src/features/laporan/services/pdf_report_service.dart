import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/database/local_db_helper.dart';

class PdfReportService {
  Future<pw.Document> generateLaporanBulanan(String rt, String rw) async {
    final db = await LocalDbHelper.database;

    // Fetch data for Form I
    final form1Result = await db.rawQuery(
      '''
      SELECT 
        b.kelompok_dawis, 
        COUNT(DISTINCT b.id) as jml_bangunan,
        COUNT(DISTINCT k.id) as jml_krt,
        COUNT(DISTINCT kel.id) as jml_keluarga,
        COUNT(DISTINCT i.id) as jml_individu
      FROM bangunan b
      LEFT JOIN krt k ON k.id_bangunan = b.id
      LEFT JOIN keluarga kel ON kel.id_krt = k.id
      LEFT JOIN individu i ON i.id_keluarga = kel.id
      WHERE b.rt = ? AND b.rw = ?
      GROUP BY b.kelompok_dawis
    ''',
      [rt, rw],
    );

    // Fetch data for Form II
    final form2Result = await db.rawQuery(
      '''
      SELECT
        b.alamat_lengkap,
        b.kelompok_dawis,
        COUNT(DISTINCT k.id) as jml_krt,
        COUNT(DISTINCT kel.id) as jml_keluarga,
        COUNT(DISTINCT i.id) as jml_individu
      FROM bangunan b
      LEFT JOIN krt k ON k.id_bangunan = b.id
      LEFT JOIN keluarga kel ON kel.id_krt = k.id
      LEFT JOIN individu i ON i.id_keluarga = kel.id
      WHERE b.rt = ? AND b.rw = ?
      GROUP BY b.id, b.alamat_lengkap, b.kelompok_dawis
    ''',
      [rt, rw],
    );

    final pdf = pw.Document();

    // Form I Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PENETAPAN SASARAN PENDATAAN TINGKAT RT',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('RT: $rt / RW: $rw'),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Kelompok Dasawisma',
                  'Jml Bangunan',
                  'Jml KRT',
                  'Jml Keluarga',
                  'Jml Individu',
                ],
                data: form1Result.map((row) {
                  return [
                    row['kelompok_dawis']?.toString() ?? '-',
                    row['jml_bangunan'].toString(),
                    row['jml_krt'].toString(),
                    row['jml_keluarga'].toString(),
                    row['jml_individu'].toString(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    // Form II Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DATA KELOMPOK DASAWISMA PKK',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('RT: $rt / RW: $rw'),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Alamat Bangunan',
                  'Kelompok Dasawisma',
                  'Jml KRT',
                  'Jml Keluarga',
                  'Jml Individu',
                ],
                data: form2Result.map((row) {
                  return [
                    row['alamat_lengkap']?.toString() ?? '-',
                    row['kelompok_dawis']?.toString() ?? '-',
                    row['jml_krt'].toString(),
                    row['jml_keluarga'].toString(),
                    row['jml_individu'].toString(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
