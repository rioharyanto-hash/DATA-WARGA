import 'dart:io';

void main() {
  final dir = Directory('e:/Project/DAWIS/lib/src/features');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();

    if (content.contains('appBar: AppBar(')) {
      // Find the AppBar block
      final RegExp appBarRegex = RegExp(
        r'appBar:\s*AppBar\((.*?)\),?\s*(body:|bottomNavigationBar:)',
        dotAll: true,
      );

      final match = appBarRegex.firstMatch(content);
      if (match != null) {
        String appBarContent = match.group(1)!;

        List<String> issues = [];

        // Check for hardcoded bad backgrounds
        if (appBarContent.contains('backgroundColor: Colors.white')) {
          issues.add('Has white background');
        }
        if (appBarContent.contains('backgroundColor: Colors.transparent')) {
          issues.add('Has transparent background');
        }

        // Check for dark text
        if (appBarContent.contains('Colors.black')) {
          issues.add('Has black color');
        }
        if (appBarContent.contains('Colors.grey')) {
          issues.add('Has grey color');
        }
        if (appBarContent.contains('_charcoal')) {
          issues.add('Has _charcoal color');
        }
        if (appBarContent.contains('_textDark')) {
          issues.add('Has _textDark color');
        }
        if (appBarContent.contains('_primaryDark')) {
          issues.add('Has _primaryDark color');
        }

        if (issues.isNotEmpty) {
          print('${file.path}:\n  - ${issues.join(", ")}');
        }
      }
    }
  }
}
