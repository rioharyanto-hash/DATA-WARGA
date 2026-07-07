import 'dart:io';

void fixFile(String filePath, String functionName) {
  var file = File(filePath);
  var content = file.readAsStringSync();

  int idx = content.indexOf(functionName);
  if (idx == -1) {
    print("Function $functionName not found in $filePath");
    return;
  }

  // Fix the height in buildDataRow
  String oldRowStart = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.yellow) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  height: 20,''';
                  
  String newRowStart = '''          pw.TableRow buildDataRow(List<String> values, {bool isTotal = false}) {
            return pw.TableRow(
              decoration: isTotal ? const pw.BoxDecoration(color: PdfColors.yellow) : null,
              children: List.generate(values.length, (i) {
                final alignment = (i == 1 || i == 2) ? pw.Alignment.centerLeft : pw.Alignment.center;
                return pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 20),''';

  content = content.replaceFirst(oldRowStart, newRowStart, idx);

  // Fix header flex values
  String oldHeader = '''          pw.Expanded(
            flex: 12,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('SEHAT\\nLAYAK HUNI', 3),
                        headerCell('TIDAK SEHAT\\nLAYAK HUNI', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          headerCell('PUNYA\\nTEMPAT\\nSAMPAH', 3),
          headerCell('PUNYA\\nSPAL', 3),
          headerCell('PUNYA\\nJAMBAN\\nKELUARGA', 3),
          headerCell('TEMPEL\\nSTIKER\\nP4K', 3),
          pw.Expanded(
            flex: 18,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('PDAM', 3),
                        headerCell('SUMUR', 3),
                        headerCell('DLL', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 12,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('BERAS', 3),
                        headerCell('NON BERAS', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 24,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('UP2K', 3),
                        headerCell('PEMANFAATAN\\nPEKARANGAN', 3),
                        headerCell('INDUSTRI\\nRUMAH TANGGA', 3),
                        headerCell('KERJA BAKTI', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),''';

  String newHeader = '''          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('KRITERIA RUMAH', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('SEHAT\\nLAYAK HUNI', 3),
                        headerCell('TIDAK SEHAT\\nLAYAK HUNI', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          headerCell('PUNYA\\nTEMPAT\\nSAMPAH', 3),
          headerCell('PUNYA\\nSPAL', 3),
          headerCell('PUNYA\\nJAMBAN\\nKELUARGA', 3),
          headerCell('TEMPEL\\nSTIKER\\nP4K', 3),
          pw.Expanded(
            flex: 90,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('SUMBER AIR KELUARGA', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('PDAM', 3),
                        headerCell('SUMUR', 3),
                        headerCell('DLL', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 60,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('MAKANAN POKOK', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('BERAS', 3),
                        headerCell('NON BERAS', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 120,
            child: pw.Container(
              decoration: pw.BoxDecoration(border: borderRight),
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 12,
                    decoration: pw.BoxDecoration(border: borderBottom),
                    child: pw.Center(
                      child: pw.Text('WARGA MENGIKUTI KEGIATAN', style: style),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        headerCell('UP2K', 3),
                        headerCell('PEMANFAATAN\\nPEKARANGAN', 3),
                        headerCell('INDUSTRI\\nRUMAH TANGGA', 3),
                        headerCell('KERJA BAKTI', 3, pw.Border()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),''';

  content = content.replaceFirst(oldHeader, newHeader, idx);
  file.writeAsStringSync(content);
  print("Updated \$filePath successfully");
}

void main() {
  fixFile('lib/src/features/report/data/services/pdf_perincian_service.dart', 'generatePotensiWargaPdfPerincian(');
}
