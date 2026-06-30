import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  if (content.contains('Future<Uint8List> generateForm3Ringkasan(')) {
    print('Already has generateForm3Ringkasan');
    return;
  }
  
  // Find generateForm3
  int startIndex = content.indexOf('Future<Uint8List> generateForm3({');
  int endIndex = content.indexOf('Future<Uint8List> generateBlankForm3()', startIndex);
  
  if (startIndex == -1 || endIndex == -1) {
    print('Could not find generateForm3');
    return;
  }
  
  String form3Code = content.substring(startIndex, endIndex);
  
  // Create ringkasan code
  String ringkasanCode = form3Code.replaceAll('generateForm3', 'generateForm3Ringkasan');
  // Change headers for ringkasan
  ringkasanCode = ringkasanCode.replaceAll('NAMA KRT', 'KELOMPOK DAWIS');
  ringkasanCode = ringkasanCode.replaceAll('NAMA KEPALA KELUARGA', 'JUMLAH KK'); // Wait, the column 2 is KELOMPOK, 3 is JUMLAH KK? No, it should be 4 columns.
  
}
