import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('DATA KUANTITAS\'') && i > 6500) {
      for (int j = i - 50; j <= i; j++) {
         if (lines[j].contains('Future<Uint8List>')) {
           print('Found function at line ${j + 1}: ${lines[j]}');
         }
      }
      break;
    }
  }
}
