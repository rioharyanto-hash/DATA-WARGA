import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_pengurus_screen.dart',
  );
  String content = file.readAsStringSync();

  content = content.replaceAll(
    'InputDecoration(',
    'InputDecoration(floatingLabelBehavior: FloatingLabelBehavior.always, ',
  );

  file.writeAsStringSync(content);
  print('Done.');
}
