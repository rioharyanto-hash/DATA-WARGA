import 'dart:io';

void main() async {
  final file = File(
    r'C:\Users\user\.gemini\antigravity-ide\brain\863c3a9b-3e69-4f4b-aa7a-5786ce56735d\.system_generated\logs\transcript_full.jsonl',
  );
  final lines = await file.readAsLines();

  // We are looking for the exact replace_file_content that replaced generateLampidPdf
  for (var line in lines.reversed) {
    if (line.contains('generateLampidPdf({') &&
        line.contains('ReplacementContent')) {
      // Find the replacement content string
      try {
        final startIdx = line.indexOf('"ReplacementContent":"');
        if (startIdx != -1) {
          final endIdx = line.indexOf('","StartLine":', startIdx);
          if (endIdx != -1) {
            String content = line.substring(startIdx + 22, endIdx);
            // It's JSON encoded, so it has escaped newlines \\n and quotes \\"
            content = content
                .replaceAll('\\n', '\n')
                .replaceAll('\\"', '"')
                .replaceAll('\\\\', '\\');
            await File(
              'e:\\Project\\DAWIS\\recovered_lampid.txt',
            ).writeAsString(content);
            print('Found and extracted to recovered_lampid.txt');
            return;
          }
        }
      } catch (e) {
        // ignore
      }
    }
  }
  print('Not found in transcript.');
}
