import 'dart:io';

void main() {
  final path =
      r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();

  // Add helper function if not exists
  if (!content.contains('int _parseInt(dynamic val)')) {
    content += '''\n
int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
''';
  }

  // Replace all instances of `(var['key'] as int? ?? 0)` or `(var[key] as int? ?? 0)`
  // Regex: \(([a-zA-Z0-9_]+)\[([^\]]+)\] as int\? \?\? 0\)
  final regex = RegExp(r'\(([a-zA-Z0-9_]+)\[([^\]]+)\] as int\? \?\? 0\)');

  content = content.replaceAllMapped(regex, (match) {
    return '_parseInt(${match.group(1)}[${match.group(2)}])';
  });

  // Remove `&& !isLastPage` from generateForm3 padding logic to allow padding on last page
  content = content.replaceAll(
    'if (pageRows.length < chunk && !isLastPage)',
    'if (pageRows.length < chunk)',
  );

  file.writeAsStringSync(content);
  print(
    'Replaced all risky int? casts with _parseInt helper in pdf_report_service.dart.',
  );
}
