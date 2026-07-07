import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart'
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    final functions = [
      'generatePotensiWargaPdfPerincian(',
      'generatePotensiWargaPdf(',
    ];
    
    for (var func in functions) {
      int idx = content.indexOf(func);
      if (idx == -1) continue;
      
      int endIdx = content.indexOf('pw.Table(', idx);
      if (endIdx == -1) endIdx = content.length;
      
      String section = content.substring(idx, endIdx);
      
      // Since `dart format` might format `style: style` in different ways (like newlines),
      // let's just do a simpler search!
      
      // We know there are four Expanded widgets with flex in the header.
      // KRITERIA RUMAH uses flex: 12
      // SUMBER AIR KELUARGA uses flex: 18
      // MAKANAN POKOK uses flex: 12
      // WARGA MENGIKUTI KEGIATAN uses flex: 24
      
      // Let's find "KRITERIA RUMAH" and walk backwards to the previous "flex: "
      section = fixFlex(section, "KRITERIA RUMAH", "flex: 60");
      section = fixFlex(section, "SUMBER AIR KELUARGA", "flex: 90");
      section = fixFlex(section, "MAKANAN POKOK", "flex: 60");
      section = fixFlex(section, "WARGA MENGIKUTI KEGIATAN", "flex: 120");
      
      content = content.replaceRange(idx, endIdx, section);
    }
    
    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}

String fixFlex(String section, String keyword, String newFlex) {
  int kwIdx = section.indexOf(keyword);
  if (kwIdx == -1) return section;
  
  int flexIdx = section.lastIndexOf('flex: ', kwIdx);
  if (flexIdx == -1) return section;
  
  // Find the comma after flex
  int commaIdx = section.indexOf(',', flexIdx);
  if (commaIdx == -1) return section;
  
  String oldFlex = section.substring(flexIdx, commaIdx);
  print('Found \$oldFlex for \$keyword');
  
  return section.replaceRange(flexIdx, commaIdx, newFlex);
}
