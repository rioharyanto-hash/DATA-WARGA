import 'dart:io';

void main() {
  final content = File(
    'lib/src/features/report/data/repositories/report_repository.dart',
  ).readAsStringSync();
  final regex = RegExp(r'Future<[^>]+>\s+([a-zA-Z_][a-zA-Z0-9_]*)\(');
  for (var m in regex.allMatches(content)) {
    print(m.group(0));
  }
}
