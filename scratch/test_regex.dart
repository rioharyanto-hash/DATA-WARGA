import 'dart:io';

void main() { 
  var content = File('lib/src/features/report/data/services/pdf_report_service.dart').readAsStringSync(); 
  var idx = content.indexOf('generatePotensiWargaPdf('); 
  var endIdx = content.indexOf('pw.Table(', idx); 
  print('Found section from \$idx to \$endIdx'); 
  var section = content.substring(idx, endIdx); 
  print('Contains KRITERIA: \${section.contains('KRITERIA RUMAH')}'); 
  
  var reg = RegExp(r"flex:\s*12,\s*child:\s*pw\.Container\(\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderRight\),\s*child:\s*pw\.Column\(\s*children:\s*\[\s*pw\.Container\(\s*height:\s*12,\s*decoration:\s*pw\.BoxDecoration\(border:\s*borderBottom\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\('KRITERIA RUMAH'");
  print('Match regex 1: \${reg.hasMatch(section)}'); 
  if (!reg.hasMatch(section)) {
    print('Let us find flex: 12');
    var matches = RegExp(r"flex:\s*12").allMatches(section);
    for (var m in matches) {
      print('Found flex: 12 at \${m.start}');
      print(section.substring(m.start, m.start + 200));
    }
  }
}
