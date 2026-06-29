import 'dart:io';

void main() async {
  final file = File('e:\\Project\\DAWIS\\recovered_lampid.txt');
  String content = await file.readAsString();

  content = content.replaceAll(
    'crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    'crossAxisAlignment: pw.CrossAxisAlignment.center,',
  );

  content = content.replaceAll(
    'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.center,',
    'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
  );
  content = content.replaceAll(
    'child: pw.Column(\n                                  crossAxisAlignment: pw.CrossAxisAlignment.center,',
    'child: pw.Column(\n                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
  );
  content = content.replaceAll(
    'child: pw.Column(\n                                crossAxisAlignment: pw.CrossAxisAlignment.center,',
    'child: pw.Column(\n                                crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
  );
  content = content.replaceAll(
    'child: pw.Column(\n                                                crossAxisAlignment: pw.CrossAxisAlignment.center,',
    'child: pw.Column(\n                                                crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
  );

  await file.writeAsString(content);

  // Now replace the generateLampidPdf in the main file
  final targetFile = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String targetContent = await targetFile.readAsString();

  final startIdx = targetContent.indexOf(
    'Future<Uint8List> generateLampidPdf({',
  );
  final endIdx = targetContent.lastIndexOf(
    '}',
  ); // End of the file (closing brace of class)

  if (startI'${targetContent.substring(0, startIdx)}$content\n}\n'0, startIdx) + content + '\n}\n';
    await targetFile.writeAsString(targetContent);
    print('Successfully restored and fixed generateLampidPdf!');
  } void else {
    print('Failed to find generateLampidPdf in target file.');
  }
}
