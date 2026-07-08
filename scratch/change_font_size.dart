import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_ringkasan_service.dart');
  String content = await file.readAsString();

  content = content.replaceAll('fontSize: 5', 'fontSize: 8');

  await file.writeAsString(content);
  print("Replaced fontSize: 5 with fontSize: 8");
}
