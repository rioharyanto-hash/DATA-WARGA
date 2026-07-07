import 'dart:io';

void main() {
  var file = File('lib/src/features/report/data/services/pdf_perincian_service.dart');
  var content = file.readAsStringSync();

  // Fix signature
  String pattern = r'''  Future<Uint8List> generateProfilUsiaPdf\(\{
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
  \}\) async \{''';
  
  // To handle \r\n vs \n
  pattern = pattern.replaceAll('\n', r'\r?\n');
  
  RegExp exp = RegExp(pattern);
  content = content.replaceFirst(exp, '''  Future<Uint8List> generateProfilUsiaPdf({
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
    required String namaKader,
  }) async {''');
  
  // Fix namaKader usage
  String pattern2 = r'''                          pw\.Text\(
                            ': ',
                            style: pw\.TextStyle\(
                              font: regularFont,
                              fontSize: 10,
                            \),
                          \),''';
  pattern2 = pattern2.replaceAll('\n', r'\r?\n');
  content = content.replaceFirst(RegExp(pattern2), '''                          pw.Text(
                            ': \$namaKader',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),''');

  // Fix date
  String pattern3 = r'''                pw\.Text\(
                  ': ',
                  style: pw\.TextStyle\(font: regularFont, fontSize: 10\),
                \),''';
  pattern3 = pattern3.replaceAll('\n', r'\r?\n');
  content = content.replaceFirst(RegExp(pattern3), '''                pw.Text(
                  ': \${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][DateTime.now().month - 1]} \${DateTime.now().year}',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),''');

  file.writeAsStringSync(content);
  print("Updated pdf_perincian_service.dart successfully");
}
