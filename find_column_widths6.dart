import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  bool inBlankForm3 = false;
  int foundCount = 0;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Future<Uint8List> generateBlankForm3() async {')) {
      inBlankForm3 = true;
    }
    if (inBlankForm3 && lines[i].contains('columnWidths')) {
      foundCount++;
      if (foundCount == 2) {
        print('Found 2nd columnWidths around line ${i + 1}');
        for (int j = i - 5; j <= i + 15; j++) {
          if (j >= 0 && j < lines.length) {
            print('${j + 1}: ${lines[j]}');
          }
        }
        break;
      }
    }
  }
}
