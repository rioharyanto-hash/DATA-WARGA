import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();

  // Find generateForm3 table headers and replace them
  bool inForm3 = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Future<Uint8List> generateForm3({')) {
      inForm3 = true;
    }
    if (inForm3 && lines[i].contains('headerCell(\'JUMLAH KRT\'')) {
      lines[i] = lines[i].replaceAll('JUMLAH KRT', 'NAMA KRT');
      lines[i+1] = lines[i+1].replaceAll('JUMLAH KEPALA KELUARGA', 'NAMA KEPALA KELUARGA');
      break;
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Fixed Form 3 headers!');
}
