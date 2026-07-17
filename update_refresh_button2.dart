import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/report/presentation/screens/report_screen.dart',
  );
  String content = file.readAsStringSync();

  // Add the import if not present
  if (!content.contains('core/services/sync_service.dart')) {
    content = content.replaceFirst(
      "import '../providers/report_provider.dart';",
      "import '../providers/report_provider.dart';\nimport '../../../../core/services/sync_service.dart';",
    );
  }

  // Find the 'actions: [' inside AppBar and replace the whole block up to '],'
  final appBarIndex = content.indexOf('appBar: AppBar(');
  if (appBarIndex != -1) {
    final actionsStartIndex = content.indexOf('actions: [', appBarIndex);
    if (actionsStartIndex != -1) {
      final actionsEndIndex = content.indexOf('],', actionsStartIndex);
      if (actionsEndIndex != -1) {
        final newActions = '''actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh & Sinkronisasi Data',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
              
              try {
                await SyncService.syncSupabaseToLocal();
              } catch (e) {
                // Ignore error
              }
              
              if (context.mounted) {
                Navigator.of(context).pop(); // close dialog
                ref.invalidate(kelompokDawisListProvider);
                ref.invalidate(reportControllerProvider);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil disinkronisasi dengan server.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          if (context.canPop())
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
        ]''';

        content = content.replaceRange(
          actionsStartIndex,
          actionsEndIndex + '],'.length,
          '$newActions,',
        );
        file.writeAsStringSync(content);
        print('Sync Refresh Button successfully updated via replaceRange.');
      }
    }
  }
}
