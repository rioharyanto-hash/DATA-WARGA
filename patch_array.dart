import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final startMethod =
      'Future<Uint8List> generateProfilUsiaRingkasanPortraitPdf(';
  final methodIndex = content.indexOf(startMethod);

  if (methodIndex != -1) {
    var beforeMethod = content.substring(0, methodIndex);
    var afterMethod = content.substring(methodIndex);

    afterMethod = afterMethod.replaceFirst(
      '            ],\n          );\n        },\n      ),\n    );',
      '            ];\n        },\n      ),\n    );',
    );

    file.writeAsStringSync(beforeMethod + afterMethod);
    print('Fixed array closing');
  } else {
    print('Method not found');
  }
}
