import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  String content = await file.readAsString();

  final startIdx = content.indexOf('Future<Uint8List> generateLampidPdf({');
  // We need to cut off everything after generateLampidPdf and replace it with recovered_lampid.txt
  if (startIdx != -1) {
    String recovered = await File(
      'e:\\Project\\DAWIS\\recovered_lampid.txt',
    ).readAsString();

    // Fix crossAxisAlignment in recovered
    recovered = recovered.replaceAll(
      'crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
      'crossAxisAlignment: pw.CrossAxisAlignment.center,',
    );
    recovered = recovered.replaceAll(
      'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.center,',
      'child: pw.Column(\n                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    );
    recovered = recovered.replaceAll(
      'child: pw.Column(\n                                  crossAxisAlignment: pw.CrossAxisAlignment.center,',
      'child: pw.Column(\n                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    );
    recovered = recovered.replaceAll(
      'child: pw.Column(\n                                crossAxisAlignment: pw.CrossAxisAlignment.center,',
      'child: pw.Column(\n                                crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    );
    recovered = recovered.replaceAll(
      'child: pw.Column(\n                                                crossAxisAlignment: pw.CrossAxisAlignment.center,',
      'child: pw.Column(\n                                                crossAxisAlignment: pw.CrossAxisAlignment.stretch,',
    );

    content = content.substring(0, startIdx) + recovered;
    await file.writeAsString(content);
    print('Fixed!');
  }
}
