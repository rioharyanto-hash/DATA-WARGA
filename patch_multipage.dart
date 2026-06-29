import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  // Replace pw.Page with pw.MultiPage for generateProfilUsiaRingkasanPortraitPdf
  final startMethod =
      'Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf(';
  final methodIndex = content.indexOf(startMethod);

  if (methodIndex != -1) {
    var beforeMethod = content.substring(0, methodIndex);
    var afterMethod = content.substring(methodIndex);

    afterMethod = afterMethod.replaceFirst(
      'pdf.addPage(\n      pw.Page(',
      'pdf.addPage(\n      pw.MultiPage(',
    );

    afterMethod = afterMethod.replaceFirst(
      'build: (pw.Context context) {\n          return pw.Column(\n            crossAxisAlignment: pw.CrossAxisAlignment.start,\n            children: [',
      'build: (pw.Context context) {\n          return [',
    );

    file.writeAsStringSync(beforeMethod + afterMethod);
    print('Patched successfully');
  } else {
    print('Method not found');
  }
}
