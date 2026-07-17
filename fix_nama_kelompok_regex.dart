import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_user_screen.dart',
  );
  String content = file.readAsStringSync();

  final pattern = RegExp(
    r"Column\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*const\s*Text\(\s*'Nama Kelompok'[\s\S]*?DropdownButtonHideUnderline\(\s*child:\s*DropdownButton<String>\(",
  );
  final replacement = '''InputDecorator(
  decoration: const InputDecoration(
    labelText: 'Nama Kelompok',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  ),
  child: Row(
    children: [
      const Text('BUAH GOWOK 010.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(''';

  content = content.replaceFirst(pattern, replacement);

  final patternEnd = RegExp(
    r"\}\),\s*onChanged:\s*\(val\)\s*=>\s*setState\(\s*\(\)\s*=>\s*_dawisNoUrut\s*=\s*val,\s*\),\s*\),\s*\),\s*],\s*\),\s*\),\s*\],\s*\),\s*const\s*SizedBox\(height:\s*16\),",
  );

  final replacementEnd = '''}),
  onChanged: (val) => setState(() => _dawisNoUrut = val),
),
),
],
),
),
const SizedBox(height: 16),''';

  content = content.replaceFirst(patternEnd, replacementEnd);

  file.writeAsStringSync(content);
  print('Done.');
}
