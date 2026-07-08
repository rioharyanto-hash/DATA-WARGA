import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  List<String> lines = await file.readAsLines();

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('isHeader: true') && lines[i].contains('fontSize: 8')) {
      lines[i] = lines[i].replaceAll('fontSize: 8', 'fontSize: 6');
    }
  }

  await file.writeAsString(lines.join('\n'));
  print("Updated header font sizes to 6.");
}
