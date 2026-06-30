import 'dart:io';

void main() {
  final file = File('lib/src/features/report/presentation/screens/report_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'DropdownButtonFormField<bool>(\n          value: _isRingkasan,',
    'DropdownButton<bool>(\n          value: _isRingkasan,\n          isExpanded: true,'
  );
  file.writeAsStringSync(content);
  print('Fixed info warning!');
}
