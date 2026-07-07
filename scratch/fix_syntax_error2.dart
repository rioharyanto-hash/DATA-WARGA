import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart'
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // The target is buildDataRow inside generatePotensiWargaPdfPerincian and generatePotensiWargaPdf
    // We can just find the functions and replace the FIRST `height: 20` after `pw.TableRow buildDataRow(`
    
    final functions = [
      'generatePotensiWargaPdfPerincian(',
      'generatePotensiWargaPdf(',
    ];
    
    for (var func in functions) {
      int funcIdx = content.indexOf(func);
      if (funcIdx == -1) continue;
      
      int buildRowIdx = content.indexOf('buildDataRow(', funcIdx);
      if (buildRowIdx == -1) continue;
      
      int containerIdx = content.indexOf('return pw.Container(', buildRowIdx);
      if (containerIdx == -1) continue;
      
      int heightIdx = content.indexOf('height: 20,', containerIdx);
      if (heightIdx != -1 && heightIdx < containerIdx + 300) {
        content = content.replaceRange(heightIdx, heightIdx + 11, 'constraints: const pw.BoxConstraints(minHeight: 20),');
      }
    }
    
    file.writeAsStringSync(content);
  }
  print('Added constraints properly');
}
