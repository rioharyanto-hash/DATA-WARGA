import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/report/presentation/screens/report_screen.dart',
  );
  String content = file.readAsStringSync();

  // Find the 'actions: [' inside AppBar
  final appBarIndex = content.indexOf('appBar: AppBar(');
  if (appBarIndex != -1) {
    final actionsIndex = content.indexOf('actions: [', appBarIndex);
    if (actionsIndex != -1) {
      final insertIndex = actionsIndex + 'actions: ['.length;

      final refreshButton = '''
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              ref.invalidate(kelompokDawisListProvider);
              ref.invalidate(reportControllerProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memuat ulang data laporan...')),
              );
            },
          ),''';

      content =
          content.substring(0, insertIndex) +
          refreshButton +
          content.substring(insertIndex);
      file.writeAsStringSync(content);
      print('Refresh button added successfully.');
    } else {
      print('Could not find actions: [');
    }
  } else {
    print('Could not find appBar: AppBar(');
  }
}
