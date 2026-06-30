import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var lines = file.readAsLinesSync();
  
  // Line 252
  lines[251] = lines[251].replaceAll(r"pw.Text('${data['rt'] ?? '...'}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text(rt, style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 258
  lines[257] = lines[257].replaceAll(r"pw.Text('${data['tahun']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text(periode, style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 2729
  lines[2728] = lines[2728].replaceAll(r"pw.Text('${data['rw']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('...', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 2730
  lines[2729] = lines[2729].replaceAll(r"pw.Text('${data['kelurahan']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('...', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 2731
  lines[2730] = lines[2730].replaceAll(r"pw.Text('${data['kecamatan']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('...', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 2732
  lines[2731] = lines[2731].replaceAll(r"pw.Text('${data['tahun']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('...', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  // Line 6376
  lines[6375] = lines[6375].replaceAll(r"pw.Text('${data['rt']} / ${data['rw']}', style: pw.TextStyle(font: regularFont, fontSize: 10))", r"pw.Text('...', style: pw.TextStyle(font: regularFont, fontSize: 10))");
  
  file.writeAsStringSync(lines.join('\n'));
  print('Fixed blank forms!');
}
