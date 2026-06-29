import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final providerDef = '''
final pdfReportServiceProvider = Provider<PdfReportService>((ref) {
  return PdfReportService();
''';

  final portraitStart = content.indexOf(
    '  /// =========================================================================\n  /// FORM PROFIL KEPENDUDUKAN - RINGKASAN (TERISI)',
  );

  if (portraitStart != -1) {
    // Extract the whole method till the end of the file
    final methodContent = content.substring(portraitStart);

    // The method content ends with `});` because of the bad replacement.
    // Let's remove it and fix the file structure.
    content = content.substring(0, portraitStart);

    // It should end with `return PdfReportService();\n` from the provider def, which we also need to fix.
    // Let's restore the end of the file properly.

    // Restore the provider block completely at the end
    // First, remove the malformed provider block
    final providerStart = content.indexOf(
      'final pdfReportServiceProvider = Provider<PdfReportService>((ref) {',
    );
    content = content.substring(0, providerStart);

    // Clean up trailing whitespace
    content = content.trimRight();

    // Now content ends at the last method inside the class. BUT wait, does it have the closing brace for the class?
    // Let's check if the class closing brace is there.
    if (!content.endsWith('}')) {
      content += '\n}';
    }

    // Clean up the methodContent
    var cleanMethodContent = methodContent;
    cleanMethodContent = cleanMethodContent.replaceAll(
      '});',
      '',
    ); // Remove the trailing provider brace

    // Now, insert the cleanMethodContent BEFORE the class closing brace
    final classEnd = content.lastIndexOf('}');
    content = content.replaceRange(
      classEnd,
      classEnd + 1,
      cleanMethodContent +
          '\n}\n\nfinal pdfReportServiceProvider = Provider<PdfReportService>((ref) {\n  return PdfReportService();\n});\n',
    );

    file.writeAsStringSync(content);
    print('Fixed method location');
  } else {
    print('Method not found');
  }
}
