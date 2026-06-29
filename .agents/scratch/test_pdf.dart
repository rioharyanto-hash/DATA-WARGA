import 'package:dawis/src/features/report/data/services/pdf_report_service.dart';

void main() async {
  try {
    final service = PdfReportService();
    await service.generateBlankFormIbuHamil();
    print('Blank form generated successfully');
  } catch (e) {
    print('Blank form failed: $e');
  }

  try {
    final service = PdfReportService();
    await service.generateLampidPdf(namaKelompok: 'Test', mutasiList: []);
    print('Lampid form generated successfully');
  } catch (e) {
    print('Lampid form failed: $e');
  }
}
