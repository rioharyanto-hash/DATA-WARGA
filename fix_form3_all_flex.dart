import 'dart:io';

void main() {
  final path = 'lib/src/features/report/data/services/pdf_report_service.dart';
  final file = File(path);
  var content = file.readAsStringSync();
  
  // Find generateForm3 boundaries
  int startIndex = content.indexOf('Future<Uint8List> generateForm3({');
  int endIndex = content.indexOf('pw.Widget _buildAdvancedHeaderCell', startIndex);
  if (startIndex == -1 || endIndex == -1) {
    print('Failed to find generateForm3 bounds');
    return;
  }
  
  String form3Code = content.substring(startIndex, endIndex);
  
  // Replace tableHeaderWidget
  String newHeader = '''    final tableHeaderWidget = pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow,
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          headerCell('NO', 1),
          headerCell('NAMA KRT', 3),
          headerCell('NAMA KEPALA KELUARGA', 4),
          pw.Expanded(
            flex: 80,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(child: pw.Text('Jumlah dan Komposisi Penduduk', style: style)),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('LAKI-LAKI', 1),
                        headerCell('PEREMPUAN', 1),
                        headerCell('Jumlah', 1),
                        headerCell('Balita\\n(0-5 Thn)', 1),
                        headerCell('Anak\\n(6-9 Thn)', 1),
                        headerCell('Remaja\\n(10-24 Thn)', 1),
                        headerCell('Dewasa\\n(25-59 Thn)', 1),
                        headerCell('Lansia\\n(60+ Thn)', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          headerCell('Jumlah\\nKeluarga', 1),
          headerCell('Jumlah\\nPasangan\\nUsia Subur\\n(PUS)', 1),
          pw.Expanded(
            flex: 80,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(child: pw.Text('Jumlah Kesertaan Ber-KB', style: style)),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('MOW/Steril\\nWanita', 1),
                        headerCell('MOP/Steril\\nPria', 1),
                        headerCell('IUD/Spiral\\nAKDR', 1),
                        headerCell('Implant/\\nSusuk', 1),
                        headerCell('Suntik', 1),
                        headerCell('Pil', 1),
                        headerCell('Kondom', 1),
                        headerCell('Jumlah\\nPeserta KB', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 50,
            child: pw.Container(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(child: pw.Text('Bukan Peserta KB', style: style)),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('TIAL', 1),
                        headerCell('IAT', 1),
                        headerCell('IAS', 1),
                        headerCell('Hamil', 1),
                        headerCell('Jumlah Bukan\\nPeserta KB', 1, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );''';
    
  // find start and end of tableHeaderWidget inside form3Code
  int thwStart = form3Code.indexOf('    final tableHeaderWidget = pw.Container(');
  int thwEnd = form3Code.indexOf('    final columnWidths = <int, pw.TableColumnWidth>{');
  if (thwStart == -1 || thwEnd == -1) {
    print('Failed to find tableHeaderWidget in generateForm3');
    return;
  }
  
  form3Code = form3Code.substring(0, thwStart) + newHeader + '\n\n' + form3Code.substring(thwEnd);
  
  String newColumnWidths = '''    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(3),
      2: const pw.FlexColumnWidth(4),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1),
      5: const pw.FlexColumnWidth(1),
      6: const pw.FlexColumnWidth(1),
      7: const pw.FlexColumnWidth(1),
      8: const pw.FlexColumnWidth(1),
      9: const pw.FlexColumnWidth(1),
      10: const pw.FlexColumnWidth(1),
      11: const pw.FlexColumnWidth(1),
      12: const pw.FlexColumnWidth(1),
      13: const pw.FlexColumnWidth(1),
      14: const pw.FlexColumnWidth(1),
      15: const pw.FlexColumnWidth(1),
      16: const pw.FlexColumnWidth(1),
      17: const pw.FlexColumnWidth(1),
      18: const pw.FlexColumnWidth(1),
      19: const pw.FlexColumnWidth(1),
      20: const pw.FlexColumnWidth(1),
      21: const pw.FlexColumnWidth(1),
      22: const pw.FlexColumnWidth(1),
      23: const pw.FlexColumnWidth(1),
      24: const pw.FlexColumnWidth(1),
      25: const pw.FlexColumnWidth(1),
    };''';
    
  int cwStart = form3Code.indexOf('    final columnWidths = <int, pw.TableColumnWidth>{');
  int cwEnd = form3Code.indexOf('};', cwStart) + 2;
  
  if (cwStart == -1) {
    print('Failed to find columnWidths');
    return;
  }
  
  form3Code = form3Code.substring(0, cwStart) + newColumnWidths + form3Code.substring(cwEnd);
  
  content = content.substring(0, startIndex) + form3Code + content.substring(endIndex);
  
  file.writeAsStringSync(content);
  print('Successfully patched Form 3 to match blank form widths exactly.');
}
