import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  // Change default font sizes in buildCell
  content = content.replaceAll(
    'fontSize: fontSize ?? (isHeader ? 5 : 6)',
    'fontSize: fontSize ?? (isHeader ? 6 : 8)',
  );

  // Use Regex to find buildCell calls with isHeader: true and explicitly set fontSize to 6
  // Regex to match `buildCell(..., isHeader: true, ..., fontSize: X)` or similar
  // Actually, let's just use a simple regex for `fontSize: \d+` on lines containing `isHeader: true`
  List<String> lines = content.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('isHeader: true') && lines[i].contains('fontSize:')) {
      lines[i] = lines[i].replaceAll(RegExp(r'fontSize:\s*\d+'), 'fontSize: 6');
    }
  }

  await file.writeAsString(lines.join('\n'));
  print("Updated header fonts to 6");
}
