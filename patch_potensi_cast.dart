import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\presentation\providers\report_provider.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final oldString = '''
        final Map<String, int> sums = {};
        for (var r in dataList) {
          for (var key in r.keys) {
            if (key != 'namaWarga' && key != 'keterangan') {
              sums[key] = (sums[key] ?? 0) + (r[key] as int? ?? 0);
            }
          }
        }
''';

  final newString = '''
        final Map<String, int> sums = {};
        for (var r in dataList) {
          for (var key in r.keys) {
            if (key != 'namaWarga' && key != 'keterangan') {
              var val = r[key];
              int intVal = 0;
              if (val is int) {
                intVal = val;
              } else if (val is String) {
                intVal = int.tryParse(val) ?? 0;
              }
              sums[key] = (sums[key] ?? 0) + intVal;
            }
          }
        }
''';

  if (content.contains(oldString)) {
    content = content.replaceAll(oldString, newString);
    file.writeAsStringSync(content);
    print('Potensi Warga Ringkasan type cast patched!');
  } else {
    print('Failed to find oldString.');
  }
}
