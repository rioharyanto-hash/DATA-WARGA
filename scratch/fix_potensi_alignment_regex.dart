import 'dart:io';

void main() {
  final files = [
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
    'lib/src/features/report/data/services/pdf_report_service.dart'
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // Instead of replacing the whole block, let's use regex to find the specific flexes inside tableHeaderWidget.
    // The easiest way is to find the function, then find the tableHeaderWidget, then replace the specific flexes inside it.
    
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
      
      // Now, replace the flex values in this section.
      // KRITERIA RUMAH uses flex 12, MAKANAN POKOK uses flex 12.
      // SUMBER AIR KELUARGA uses flex 18.
      // WARGA MENGIKUTI KEGIATAN uses flex 24.
      
      section = section.replaceAll(
        RegExp(r"flex:\s*12,\s*child:\s*pw\.Container\(\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderRight\),\s*child:\s*pw\.Column\(\s*children:\s*\[\s*pw\.Container\(\s*height:\s*12,\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderBottom\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\('KRITERIA RUMAH'"),
        "flex: 60,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('KRITERIA RUMAH'"
      );
      
      section = section.replaceAll(
        RegExp(r"flex:\s*12,\s*child:\s*pw\.Container\(\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderRight\),\s*child:\s*pw\.Column\(\s*children:\s*\[\s*pw\.Container\(\s*height:\s*12,\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderBottom\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\('MAKANAN POKOK'"),
        "flex: 60,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('MAKANAN POKOK'"
      );
      
      section = section.replaceAll(
        RegExp(r"flex:\s*18,\s*child:\s*pw\.Container\(\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderRight\),\s*child:\s*pw\.Column\(\s*children:\s*\[\s*pw\.Container\(\s*height:\s*12,\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderBottom\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\('SUMBER AIR KELUARGA'"),
        "flex: 90,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('SUMBER AIR KELUARGA'"
      );
      
      section = section.replaceAll(
        RegExp(r"flex:\s*24,\s*child:\s*pw\.Container\(\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderRight\),\s*child:\s*pw\.Column\(\s*children:\s*\[\s*pw\.Container\(\s*height:\s*12,\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderBottom\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\('WARGA MENGIKUTI KEGIATAN'"),
        "flex: 120,\n            child: pw.Container(\n              decoration: pw.BoxDecoration(border: borderRight),\n              child: pw.Column(\n                children: [\n                  pw.Container(\n                    height: 12,\n                    decoration: pw.BoxDecoration(border: borderBottom),\n                    child: pw.Center(\n                      child: pw.Text('WARGA MENGIKUTI KEGIATAN'"
      );
      
      content = content.replaceRange(idx, endIdx, section);
    }
    
    file.writeAsStringSync(content);
  }
}
