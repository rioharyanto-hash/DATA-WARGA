import 'dart:io';

void main() {
  final file = File('lib/src/features/report/data/services/pdf_report_service.dart');
  var content = file.readAsStringSync();
  
  String search = 'pw.TableRow(children: [pw.Text(\'RT / RW\', style: pw.TextStyle(font: regularFont, fontSize: 10)), pw.Text(\':\', style: pw.TextStyle(font: regularFont, fontSize: 10)), pw.Text(\'...\', style: pw.TextStyle(font: regularFont, fontSize: 10))]),';
  String replace = 'pw.TableRow(children: [pw.Text(\'RT / RW\', style: pw.TextStyle(font: regularFont, fontSize: 10)), pw.Text(\':\', style: pw.TextStyle(font: regularFont, fontSize: 10)), pw.Text(\'\${data[\\\'rt\\\'] ?? \\\'\\\'} / \${data[\\\'rw\\\'] ?? \\\'\\\'}\', style: pw.TextStyle(font: regularFont, fontSize: 10))]),';
  
  if (content.contains(search)) {
    content = content.replaceAll(search, replace);
    file.writeAsStringSync(content);
    print('Fixed RT/RW in Form 3');
  } else {
    print('Could not find search string');
  }
}
