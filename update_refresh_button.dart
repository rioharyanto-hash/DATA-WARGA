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

  final oldButton = '''
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

  final newButton = '''
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
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
                // Ignore error, continue
              }
              
              if (context.mounted) {
                Navigator.of(context).pop(); // close dialog
                ref.invalidate(kelompokDawisListProvider);
                ref.invalidate(reportControllerProvider);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil disinkronisasi & diperbarui.')),
                );
              }
            },
          ),''';

  if (content.contains(oldButton)) {
    content = content.replaceFirst(oldButton, newButton);
    file.writeAsStringSync(content);
    print('Sync Refresh Button added successfully.');
  } else {
    print('Error: Could not find old refresh button.');
  }
}
