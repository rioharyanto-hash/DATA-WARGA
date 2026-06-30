import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  // Line 252 (was changed to rt, but it takes Map<String, dynamic> data! So we should probably revert it back to ${data['rt'] ?? '...'} if that's what it was!)
  // Wait, let's just change it back to ${data['rt'] ?? '...'}
  lines[251] = lines[251].replaceAll(r"pw.Text(rt, style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('${data['rt'] ?? '...'}', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 258
  lines[257] = lines[257].replaceAll(r"pw.Text(periode, style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('${data['tahun']}', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  file.writeAsStringSync(lines.join('\n'));
  print('Fixed line 258!');
}
