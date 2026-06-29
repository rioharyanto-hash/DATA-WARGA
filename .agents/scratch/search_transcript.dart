import 'dart:io';
import 'dart:convert';

void main() async {
  final transcriptPath =
      r'C:\Users\user\.gemini\antigravity-ide\brain\863c3a9b-3e69-4f4b-aa7a-5786ce56735d\.system_generated\logs\transcript_full.jsonl';
  final file = File(transcriptPath);

  if (!await file.exists()) {
    print('File not found');
    return;
  }

  final lines = await file.readAsLines();
  for (final line in lines) {
    try {
      final data = json.decode(line);
      final type = data['type'] as String?;
      final source = data['source'] as String?;
      final toolCalls = data['tool_calls'] as List<dynamic>?;

      if (type == 'PLANNER_RESPONSE' &&
          source == 'MODEL' &&
          toolCalls != null) {
        for (final call in toolCalls) {
          final args = call['args'];
          if (args != null && args['CommandLine'] != null) {
            final content = args['CommandLine'] as String;
            if (content.contains('Future<Uint8List> generateYatimPiatuPdf')) {
              await File('extracted_cmd_yatim.txt').writeAsString(content);
            }
            if (content.contains(
              'Future<Uint8List> generateProfilPendudukPdf',
            )) {
              await File('extracted_cmd_profil.txt').writeAsString(content);
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
