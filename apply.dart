import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  final rekapSrc = File('C:/Users/user/.gemini/antigravity-ide/brain/89c964af-5c51-4a47-b2e6-a41f4678cbdd/patch_pdf_rekapitulasi.dart').readAsStringSync();
  final kuantitasSrc = File('C:/Users/user/.gemini/antigravity-ide/brain/89c964af-5c51-4a47-b2e6-a41f4678cbdd/patch_pdf_kuantitas.dart').readAsStringSync();
  final potensiSrc = File('C:/Users/user/.gemini/antigravity-ide/brain/89c964af-5c51-4a47-b2e6-a41f4678cbdd/patch_pdf_potensi.dart').readAsStringSync();

  String extractMethod(String source) {
    final start = source.indexOf("final replacement = '''");
    if (start == -1) return '';
    final end = source.lastIndexOf("''';");
    if (end == -1) return '';
    return source.substring(start + 23, end);
  }

  final rekapReplace = extractMethod(rekapSrc);
  final kuantitasReplace = extractMethod(kuantitasSrc);
  final potensiReplace = extractMethod(potensiSrc);
  
  if (rekapReplace.isEmpty || kuantitasReplace.isEmpty || potensiReplace.isEmpty) {
    print('Failed to extract replacement methods');
    return;
  }
  
  String replaceInContent(String text, String methodName, String replacement) {
    final start = text.indexOf('  Future<Uint8List> ' + methodName + '(');
    if (start == -1) {
        print('Could not find start for ' + methodName);
        return text;
    }
    // Find next method
    final end = text.indexOf('  Future<Uint8List> ', start + 10);
    if (end == -1) {
        print('Could not find end for ' + methodName);
        return text; 
    }
    return text.substring(0, start) + replacement + text.substring(end);
  }

  content = replaceInContent(content, 'generateRekapPkkPdf', rekapReplace);
  content = replaceInContent(content, 'generateForm3', kuantitasReplace);
  content = replaceInContent(content, 'generateFormDataPotensiWarga', potensiReplace);

  file.writeAsStringSync(content);
  print('Patches applied successfully!');
}
