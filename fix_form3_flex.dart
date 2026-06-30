import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  // Group 1: flex 40 -> 200
  content = content.replaceFirst('flex: 40,', 'flex: 200,', content.indexOf('headerCell(\'NAMA KEPALA KELUARGA\', 3),'));
  
  // Group 2: flex 40 -> 240
  content = content.replaceFirst('flex: 40,', 'flex: 240,', content.indexOf('headerCell(\'Jumlah\\nPasangan\\nUsia Subur\\n(PUS)\', 3.5),'));
  
  // Group 3: flex 20 -> 170
  content = content.replaceFirst('flex: 20,', 'flex: 170,', content.indexOf('headerCell(\'Jumlah\\nPasangan\\nUsia Subur\\n(PUS)\', 3.5),')); // wait, the 20 is after group 2
  
  file.writeAsStringSync(content);
  print('Fixed Form 3 flexes!');
}
