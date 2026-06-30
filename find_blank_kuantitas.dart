import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  bool inBlankForm = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('DATA KUANTITAS (TEMPLATE KOSONG)')) {
      inBlankForm = true;
      for (int j = i - 5; j <= i + 10; j++) {
        print('${j + 1}: ${lines[j]}');
      }
      break;
    }
  }
}
