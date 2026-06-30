import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  final lines = file.readAsLinesSync();
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('pw.Container(')) {
      bool hasColor = false;
      bool hasDecoration = false;
      
      for (int j = i; j < i + 10 && j < lines.length; j++) {
        if (lines[j].contains('color:')) hasColor = true;
        if (lines[j].contains('decoration:')) hasDecoration = true;
        if (lines[j].contains('child:') || lines[j].contains(')')) break;
      }
      
      if (hasColor && hasDecoration) {
        print('Line ${i + 1}: Container with both color and decoration');
      }
    }
  }
}
