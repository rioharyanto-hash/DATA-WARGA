import 'package:excel/excel.dart';
import 'package:dawis/core/database/local_db_helper.dart';

class ExcelReportService {
  Future<List<int>> generateSummaryExcel(String rt, String rw) async {
    final excel = Excel.createExcel();

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }

    // Sheet 1: IBU HAMIL,MENYUSUI
    final sheetIbu = excel['IBU HAMIL,MENYUSUI'];
    sheetIbu.appendRow([
      TextCellValue('NO'),
      TextCellValue('NAMA IBU'),
      TextCellValue('STATUS (HAMIL/MENYUSUI)'),
      TextCellValue('NAMA SUAMI'),
      TextCellValue('ALAMAT'),
    ]);

    // Sheet 2: POTENSI
    final sheetPotensi = excel['POTENSI'];
    sheetPotensi.appendRow([
      TextCellValue('NO'),
      TextCellValue('NAMA KRT'),
      TextCellValue('SUMBER AIR'),
      TextCellValue('PEMBUANGAN SAMPAH'),
      TextCellValue('PEMANFAATAN PEKARANGAN'),
    ]);

    // Sheet 3: PROFIL
    final sheetProfil = excel['PROFIL'];
    sheetProfil.appendRow([
      TextCellValue('NO'),
      TextCellValue('NAMA KEPALA KELUARGA'),
      TextCellValue('KELOMPOK DASA WISMA'),
      TextCellValue('JUMLAH ANGGOTA KELUARGA'),
      TextCellValue('ALAMAT'),
    ]);

    // Sheet 4: KUANTITAS
    final sheetKuantitas = excel['KUANTITAS'];
    sheetKuantitas.appendRow([
      TextCellValue('NO'),
      TextCellValue('RT'),
      TextCellValue('RW'),
      TextCellValue('JUMLAH KRT'),
      TextCellValue('JUMLAH KELUARGA'),
      TextCellValue('JUMLAH LAKI-LAKI'),
      TextCellValue('JUMLAH PEREMPUAN'),
    ]);

    // Sheet 5: REKAPITULASI
    final sheetRekap = excel['REKAPITULASI'];
    sheetRekap.appendRow([
      TextCellValue('URAIAN'),
      TextCellValue('JUMLAH'),
      TextCellValue('KETERANGAN'),
    ]);

    final db = await LocalDbHelper.database;

    // Query data
    final bangunanList = await db.query(
      'bangunan',
      where: 'CAST(rt AS INTEGER) = ? AND CAST(rw AS INTEGER) = ?',
      whereArgs: [int.tryParse(rt) ?? 0, int.tryParse(rw) ?? 0],
    );

    int rowProfil = 1;
    for (final b in bangunanList) {
      final idBangunan = b['id'] as String;
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [idBangunan],
      );

      for (final k in krtList) {
        final idKrt = k['id'] as String;
        final keluargaList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [idKrt],
        );

        for (final kel in keluargaList) {
          final idKeluarga = kel['id'] as String;
          final individuList = await db.query(
            'individu',
            where: 'id_keluarga = ?',
            whereArgs: [idKeluarga],
          );

          sheetProfil.appendRow([
            IntCellValue(rowProfil),
            TextCellValue(k['nama_krt']?.toString() ?? ''),
            TextCellValue(b['kelompok_dawis']?.toString() ?? ''),
            IntCellValue(individuList.length),
            TextCellValue(b['alamat_lengkap']?.toString() ?? ''),
          ]);
          rowProfil++;
        }
      }
    }

    return excel.encode() ?? [];
  }

  Future<List<int>> generateUsiaSekolahExcel(
    List<Map<String, dynamic>> data,
    String kelompok,
    String bulan,
  ) async {
    final excel = Excel.createExcel();

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }

    final sheet = excel['DATA USIA SEKOLAH'];

    // Header
    sheet.appendRow([TextCellValue('DATA ANAK USIA 5 - 6 TAHUN $kelompok')]);
    sheet.appendRow([
      TextCellValue('KELURAHAN UTAN KAYU UTARA, KECAMATAN MATRAMAN'),
    ]);
    sheet.appendRow([TextCellValue('PERIODE : $bulan ${DateTime.now().year}')]);
    sheet.appendRow([]);

    // Columns
    sheet.appendRow([
      TextCellValue('NO'),
      TextCellValue('NAMA ORANG TUA'),
      TextCellValue('NIK ORANG TUA'),
      TextCellValue('NAMA ANAK'),
      TextCellValue('NIK ANAK'),
      TextCellValue('TANGGAL LAHIR'),
      TextCellValue('USIA (TAHUN, BULAN)'),
      TextCellValue('ALAMAT'),
      TextCellValue('NO HP'),
      TextCellValue('PENDIDIKAN TERAKHIR'),
      TextCellValue('KETERANGAN'),
    ]);

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(item['nama_ortu'] ?? '-'),
        TextCellValue(item['nik_ortu'] ?? '-'),
        TextCellValue(item['nama_anak'] ?? '-'),
        TextCellValue(item['nik_anak'] ?? '-'),
        TextCellValue(item['tanggal_lahir'] ?? '-'),
        TextCellValue(item['usia_format'] ?? '-'),
        TextCellValue(item['alamat'] ?? '-'),
        TextCellValue(item['no_hp'] ?? '-'),
        TextCellValue(item['pendidikan_terakhir'] ?? '-'),
        TextCellValue(item['alasan_belum_sekolah'] ?? '-'),
      ]);
    }

    return excel.encode() ?? [];
  }
}
