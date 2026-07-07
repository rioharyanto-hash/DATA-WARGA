import 'dart:io';

void main() {
  var file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
'''  Future<Uint8List> generateProfilUsiaPdf({
    required Map<String, dynamic> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
  }) async {''',
'''  Future<Uint8List> generateProfilUsiaPdf({
    required Map<String, dynamic> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
    required String namaKader,
  }) async {'''
  );

  // Note: generateProfilUsiaPdf might have `List<Map<String, dynamic>> data` or `Map<String, dynamic> data`. Let's use regex to be safe.
  String pattern = r'''  Future<Uint8List> generateProfilUsiaPdf\(\{
    required List<Map<String, dynamic>> data,
    required String namaKelompok,
    required String rt,
    required String rw,
    required String kelurahan,
    required String kecamatan,
    required String kota,
  \}\) async \{''';
  
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
  
  content = content.replaceFirst(
'''                          pw.Text(
                            ': ',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),''',
'''                          pw.Text(
                            ': \$namaKader',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                            ),
                          ),'''
  );

  content = content.replaceFirst(
'''                pw.Text(
                  ': ',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),''',
'''                pw.Text(
                  ': \${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][DateTime.now().month - 1]} \${DateTime.now().year}',
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),'''
  );

  file.writeAsStringSync(content);
  print("Updated pdf_report_service.dart successfully");
}
