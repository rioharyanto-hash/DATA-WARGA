import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/pengurus_list_screen.dart',
  );
  var content = file.readAsStringSync();

  // 1. Add imports
  if (!content.contains('path_provider.dart')) {
    content = content.replaceFirst(
      "import 'package:dawis/src/features/laporan/services/data_transfer_service.dart';",
      "import 'package:dawis/src/features/laporan/services/data_transfer_service.dart';\nimport 'package:path_provider/path_provider.dart';\nimport 'dart:io';",
    );
  }

  // 2. Add _downloadTemplate method
  if (!content.contains('_downloadTemplate')) {
    final downloadMethod = '''
  Future<void> _downloadTemplate() async {
    try {
      final service = DataTransferService();
      final bytes = await service.generateImportTemplatePengurus();

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final filePath = '\${downloadsDir.path}\\\\Template_Import_Pengurus.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Template berhasil disimpan di \$filePath')),
          );
        }
      } else {
        throw Exception('Katalog Downloads tidak ditemukan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan template: \$e')));
      }
    }
  }

  @override''';
    content = content.replaceFirst(
      '@override\n  Widget build(BuildContext context) {',
      '$downloadMethod\n  Widget build(BuildContext context) {',
    );
  }

  // 3. Add icon button
  if (!content.contains("tooltip: 'Download Template Pengurus'")) {
    final actionsStr = '''
        actions: [
          IconButton(
            tooltip: 'Download Template Pengurus',
            icon: const Icon(Icons.download),
            onPressed: _isImporting ? null : _downloadTemplate,
          ),
          IconButton(
            tooltip: 'Import Excel RT/RW',
''';
    content = content.replaceFirst('''
        actions: [
          IconButton(
            tooltip: 'Import Excel RT/RW',
''', actionsStr);
  }

  file.writeAsStringSync(content);
  print('Updated pengurus_list_screen.dart');
}
