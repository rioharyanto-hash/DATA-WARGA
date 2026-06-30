import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  final oldArray = '''
    final ageGroups = [
      '0 - 4',
      '5 - 9',
      '10 - 14',
      '15 - 19',
      '20 - 24',
      '25 - 29',
      '30 - 34',
      '35 - 39',
      '40 - 44',
      '45 - 49',
      '50 - 54',
      '55 - 59',
      '60 - 64',
      '65 - 69',
      '70 - 74',
      '75 +',
    ];
''';

  final newArray = '''
    final ageGroups = [
      '0 - 4 Tahun',
      '5 - 9 Tahun',
      '10 - 14 Tahun',
      '15 - 19 Tahun',
      '20 - 24 Tahun',
      '25 - 29 Tahun',
      '30 - 34 Tahun',
      '35 - 39 Tahun',
      '40 - 44 Tahun',
      '45 - 49 Tahun',
      '50 - 54 Tahun',
      '55 - 59 Tahun',
      '60 - 64 Tahun',
      '65 - 69 Tahun',
      '70 - 74 Tahun',
      '75 Tahun',
    ];
''';

  // Make sure we only replace the second occurrence which belongs to Portrait,
  // or replace both if the user wants it everywhere. The user's portrait image explicitly has "Tahun".
  content = content.replaceFirst(oldArray, newArray); // first is landscape
  content = content.replaceFirst(oldArray, newArray); // second is portrait
  // The first form also might benefit from "Tahun" or not, but it's safe to update.

  file.writeAsStringSync(content);
  print('Updated ageGroups text');
}
