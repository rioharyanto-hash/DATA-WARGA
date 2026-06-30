import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\presentation\providers\report_provider.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  // We want to replace `final ringkasanData = {'rows': ringkasanRows};`
  // with padding logic + the original line.

  final replacement = '''
        if (ringkasanRows.isNotEmpty) {
          int remainder = ringkasanRows.length % 15;
          if (remainder != 0) {
            int needed = 15 - remainder;
            for (int i = 0; i < needed; i++) {
              ringkasanRows.add({});
            }
          }
        }
        final ringkasanData = {'rows': ringkasanRows};
''';

  content = content.replaceAll(
    "final ringkasanData = {'rows': ringkasanRows};",
    replacement,
  );

  file.writeAsStringSync(content);
  print(
    'Added empty row padding to all ringkasan reports in report_provider.dart.',
  );
}
