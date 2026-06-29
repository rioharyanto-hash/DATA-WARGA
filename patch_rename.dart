import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  content = content.replaceAll(
    'Future<Uint8List> generateProfilUsiaRingkasanPdf(',
    'Future<Uint8List> generateProfilUsiaPdf(',
  );
  content = content.replaceAll(
    'PROFIL KEPENDUDUKAN (RINGKASAN)',
    'PROFIL KEPENDUDUKAN',
  );

  file.writeAsStringSync(content);
  print('Done renaming');
}
