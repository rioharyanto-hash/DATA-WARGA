import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/report/presentation/screens/report_screen.dart',
  );
  String content = file.readAsStringSync();

  content = content.replaceAll(
    "import '../../../../core/services/sync_service.dart';",
    "import '../../../../../core/services/sync_service.dart';",
  );

  file.writeAsStringSync(content);
  print('Import path fixed.');
}
