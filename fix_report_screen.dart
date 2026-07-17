import 'dart:io';

void main() async {
  final file = File(
    'lib/src/features/report/presentation/screens/report_screen.dart',
  );
  String content = await file.readAsString();

  final regex = RegExp(
    r'''Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(context\)\s*=>\s*ReportPreviewScreen\((.*?)\s*\),\s*\),\s*\);''',
    dotAll: true,
  );

  content = content.replaceAllMapped(regex, (match) {
    final innerArgs = match.group(1)!;

    var dictStr = innerArgs
        .replaceAll('isRingkasan:', "\\'isRingkasan\\':")
        .replaceAll('title:', "\\'title\\':")
        .replaceAll('generatePdf:', "\\'generatePdf\\':");

    return '''context.push(
      '/report-preview',
      extra: {
        \$dictStr
      },
    );'''
        .replaceAll('\$dictStr', dictStr);
  });

  await file.writeAsString(content);
}
