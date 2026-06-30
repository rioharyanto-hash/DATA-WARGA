import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(r"\${", r"${");

  file.writeAsStringSync(content);
  print('Unescaped variables 2!');
}
