import 'dart:io';

void main() {
  final files = [
    {
      'path':
          'lib/src/features/settings/presentation/screens/user_list_screen.dart',
      'filename': 'Template_Import_Kader.xlsx',
    },
    {
      'path':
          'lib/src/features/settings/presentation/screens/pengurus_list_screen.dart',
      'filename': 'Template_Import_Pengurus.xlsx',
    },
  ];

  for (final item in files) {
    final file = File(item['path']!);
    var content = file.readAsStringSync();

    final regex = RegExp(
      r'final downloadsDir = await getDownloadsDirectory\(\);.*?throw Exception\('
      'Katalog Downloads tidak ditemukan'
      ');s*}',
      dotAll: true,
    );

    final newDownloadStr =
        '''
      if (kIsWeb) {
        final base64data = base64Encode(bytes);
        final anchor = html.AnchorElement(href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,\$base64data')
          ..setAttribute('download', '${item['filename']}')
          ..click();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template berhasil diunduh.')),
          );
        }
      } else {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final filePath = '\\\${downloadsDir.path}\\\\\\\\${item['filename']}';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Template berhasil disimpan di \\\$filePath')),
            );
          }
        } else {
          throw Exception('Katalog Downloads tidak ditemukan');
        }
      }''';

    if (regex.hasMatch(content) && !content.contains('kIsWeb')) {
      content = content.replaceFirst(regex, newDownloadStr);
    }

    file.writeAsStringSync(content);
    print("Updated ${item['path']!}");
  }
}
