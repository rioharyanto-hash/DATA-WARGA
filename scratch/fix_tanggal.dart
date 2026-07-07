import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_ringkasan_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart',
    'lib/src/features/report/data/services/pdf_blank_service.dart',
    'lib/src/features/report/presentation/providers/report_provider.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;

    String content = f.readAsStringSync();
    
    if (file.contains('report_provider.dart')) {
      content = content.replaceAllMapped(RegExp(r"'tahun':\s*tahun,"), (match) {
        return "'tahun': tahun,\n          'bulan': ref.read(reportBulanProvider),\n          'periode': ref.read(reportBulanProvider),";
      });
      // also replace in DataMap initialization if any
    } else {
      content = content.replaceAll(
          "_potensiInfoRow('PERIODE', '...', boldFont, regularFont),", 
          "_potensiInfoRow('PERIODE', data['periode']?.toString() ?? data['bulan']?.toString() ?? '...', boldFont, regularFont),");

      // Replace hardcoded "..." for "PERIODE" in Table Rows
      content = content.replaceAll(
          "pw.Text('...',", 
          "pw.Text(data['periode']?.toString() ?? data['bulan']?.toString() ?? '...',");
    }

    f.writeAsStringSync(content);
    print('Updated $file');
  }
}
