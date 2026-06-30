import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  bool inBlankForm3 = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Future<Uint8List> generateBlankForm3() async {')) {
      inBlankForm3 = true;
    }
    if (inBlankForm3 && lines[i].contains('pw.Row(')) {
      for (int j = i; j <= i + 60; j++) {
        if (j >= 0 && j < lines.length) {
          print('${j + 1}: ${lines[j]}');
          if (lines[j].contains(');') && j > i + 10 && !lines[j].contains('buildCell')) break;
        }
      }
      break;
    }
  }
}
