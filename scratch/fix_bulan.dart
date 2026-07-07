import 'dart:io';

void main() {
  final path = 'lib/src/features/report/data/services/pdf_perincian_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final target = '''    required String kota,
  }) async {''';
  final replacement = '''    required String kota,
    String bulanTahun = '',
  }) async {''';
  
  // Note: Handle different line endings just in case
  content = content.replaceAll(
    '    required String kota,\n  }) async {',
    '    required String kota,\n    String bulanTahun = \'\',\n  }) async {'
  );
  content = content.replaceAll(
    '    required String kota,\r\n  }) async {',
    '    required String kota,\r\n    String bulanTahun = \'\',\r\n  }) async {'
  );

  file.writeAsStringSync(content);
  print('Replaced parameter');
}
