import 'dart:io';

void main() async {
  final dir = Directory('lib');
  if (!await dir.exists()) {
    print('lib directory not found');
    return;
  }

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity);
    }
  }
}

Future<void> processFile(File file) async {
  String content = await file.readAsString();
  String original = content;

  content = removeStyleFrom(content, 'style: ElevatedButton.styleFrom(');
  content = removeStyleFrom(content, 'style: OutlinedButton.styleFrom(');
  content = removeStyleFrom(content, 'style: FilledButton.styleFrom(');
  content = removeStyleFrom(content, 'style: TextButton.styleFrom(');

  content = content.replaceAll(
    'Colors.blue.shade700',
    'Theme.of(context).colorScheme.primary',
  );
  content = content.replaceAll(
    'Colors.blue.shade900',
    'Theme.of(context).colorScheme.primary',
  );

  if (content != original) {
    await file.writeAsString(content);
    print('Updated: ${file.path}');
  }
}

String removeStyleFrom(String content, String targetStr) {
  int idx = 0;
  while (true) {
    idx = content.indexOf(targetStr, idx);
    if (idx == -1) break;

    int openParens = 0;
    int endIdx = -1;
    for (int i = idx + targetStr.length; i < content.length; i++) {
      if (content[i] == '(') {
        openParens++;
      } else if (content[i] == ')') {
        if (openParens == 0) {
          endIdx = i;
          break;
        } else {
          openParens--;
        }
      }
    }

    if (endIdx != -1) {
      int removeEnd = endIdx + 1;
      if (removeEnd < content.length && content[removeEnd] == ',') {
        removeEnd++;
      }
      content = content.substring(0, idx) + content.substring(removeEnd);
    } else {
      idx++;
    }
  }
  return content;
}
