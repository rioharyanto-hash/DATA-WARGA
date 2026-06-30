import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  bool inForm3 = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Future<Uint8List> generateForm3({')) {
      inForm3 = true;
    }
    if (inForm3 && lines[i].contains('final columnWidths = <int, pw.TableColumnWidth>{')) {
      double totalFlex = 0;
      double flex0to2 = 0;
      for (int j = i + 1; j <= i + 30; j++) {
        if (lines[j].contains('}')) break;
        final match = RegExp(r'FlexColumnWidth\(([\d\.]+)\)').firstMatch(lines[j]);
        if (match != null) {
          final flex = double.parse(match.group(1)!);
          totalFlex += flex;
          if (j - i - 1 <= 2) {
             flex0to2 += flex;
          }
        }
      }
      print('Total Table Flex: $totalFlex, Flex 0-2: $flex0to2');
      break;
    }
  }
}
