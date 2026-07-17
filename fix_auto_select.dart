import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/data_warga/presentation/screens/data_warga_screen.dart',
  );
  String content = file.readAsStringSync();

  final pattern = RegExp(
    r"if\s*\(\s*selectedId\s*==\s*null\s*&&\s*list\.isNotEmpty\s*\)\s*\{\s*WidgetsBinding\.instance\.addPostFrameCallback\(\(\_\)\s*\{\s*ref\s*\.read\(selectedBangunanIdProvider\.notifier\)\s*\.select\(list\.first\.id\);\s*\}\);\s*\}",
  );

  final replacement = '''
                    if (isDesktop && selectedId == null && list.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(selectedBangunanIdProvider.notifier)
                            .select(list.first.id);
                      });
                    }''';

  if (content.contains(pattern)) {
    content = content.replaceFirst(pattern, replacement);
    file.writeAsStringSync(content);
    print('Auto-select fixed.');
  } else {
    print('Pattern not found.');
  }
}
