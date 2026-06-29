import 'package:flutter_test/flutter_test.dart';
import 'package:dawis/src/features/report/data/services/pdf_report_service.dart';

void main() {
  test('PDF Generation generates blank form without error', () async {
    final service = PdfReportService();
    await service.generateBlankFormIbuHamil();
  });

  test('PDF Generation generates lampid form without error', () async {
    final service = PdfReportService();
    await service.generateLampidPdf(namaKelompok: 'Test', mutasiList: []);
  });

  test(
    'PDF Generation generates lampid form with one row without error',
    () async {
      final service = PdfReportService();
      await service.generateLampidPdf(
        namaKelompok: 'Test',
        mutasiList: [
          {
            'nama': 'Test Ibu',
            'nama_suami': 'Test Suami',
            'status_kematian_ibu': 'Ya',
            'nama_bayi': 'Test Bayi',
            'jenis_kelamin_bayi': 'Laki-laki',
            'tanggal_lahir': '2023-01-01',
            'punya_akte': 'Ya',
            'meninggal_bayi': 'Ya',
            'keterangan': 'Ket',
          },
        ],
      );
    },
  );
}
