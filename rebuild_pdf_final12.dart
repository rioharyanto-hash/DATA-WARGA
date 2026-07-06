// ignore_for_file: unused_element, unused_import, unused_local_variable
import 'dart:io';

void main() async {
  final srcFile = File(
    'lib/src/features/report/data/services/pdf_report_service.dart',
  );
  if (!await srcFile.exists()) return;
  final content = await srcFile.readAsString();

  final header =
      """// ignore_for_file: unused_element, unused_import, unused_local_variable
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

""";

  final ringkasanMethods = [
    'generateForm3',
    'generateRekapPkkPdf',
    'generatePotensiWargaPdf',
    'generateProfilUsiaRingkasanPortraitPdf',
    'generateLampidPdf',
  ];

  final perincianMethods = [
    'generateForm3',
    'generatePotensiWargaPdf',
    'generateProfilPendudukPdf',
    'generateYatimPiatuPdf',
    'generateRekapPkkPdf',
    'generateProfilUsiaPdf',
    'generateLampidPdf',
    'generateForm1',
    'generateForm2',
    'generateForm1And2',
    'generateFormDataManual',
  ];

  final helpers = """
  pw.Widget _buildAdvancedHeaderCell(
    String text,
    pw.Font font, {
    double fontSize = 8,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: fontSize),
      ),
    );
  }

  pw.Widget _buildCell(
    String text,
    pw.Font font,
    bool isBold, {
    double fontSize = 8,
  }) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.TableRow _buildEmptyTableRow(
    List<String> columns, {
    required pw.Font font,
    double height = 18,
    double fontSize = 8,
    List<pw.Alignment>? alignments,
  }) {
    return pw.TableRow(
      children: List.generate(columns.length, (index) {
        final text = columns[index];
        final alignment = (alignments != null && alignments.length > index)
            ? alignments[index]
            : pw.Alignment.center;

        final textAlign = alignment == pw.Alignment.centerLeft
            ? pw.TextAlign.left
            : (alignment == pw.Alignment.centerRight
                  ? pw.TextAlign.right
                  : pw.TextAlign.center);

        return pw.Container(
          height: height,
          padding: const pw.EdgeInsets.all(4),
          alignment: alignment,
          child: pw.Text(
            text,
            textAlign: textAlign,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        );
      }),
    );
  }
""";

  String extractMethod(String name) {
    int start = content.indexOf('Future<Uint8List> $name(');
    if (start == -1) start = content.indexOf('Future<Uint8List> $name (');
    if (start == -1) return '';

    int end = content.indexOf('Future<Uint8List>', start + 10);
    if (end == -1) {
      end = content.indexOf('final pdfReportServiceProvider', start + 10);
      if (end != -1) {
        int classBrace = content.lastIndexOf('}', end);
        if (classBrace != -1) {
          end = classBrace;
        }
      }
    }

    return content.substring(start, end).trim();
  }

  String ringkasanClass =
      header + "class PdfRingkasanService {\n\n" + helpers + "\n\n";
  for (final m in ringkasanMethods) {
    String mCode = extractMethod(m);
    if (m == 'generateForm3')
      mCode = mCode.replaceAll('generateForm3', 'generateForm3Ringkasan');
    if (m == 'generatePotensiWargaPdf')
      mCode = mCode.replaceAll(
        'generatePotensiWargaPdf',
        'generatePotensiWargaPdfRingkasan',
      );
    if (m == 'generateLampidPdf')
      mCode = mCode.replaceAll(
        'generateLampidPdf',
        'generateLampidPdfRingkasan',
      );
    ringkasanClass += mCode + "\n\n";
  }
  ringkasanClass += "}\n\n";
  ringkasanClass += """int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
""";

  String perincianClass =
      header + "class PdfPerincianService {\n\n" + helpers + "\n\n";
  for (final m in perincianMethods) {
    String mCode = extractMethod(m);
    if (m == 'generateForm3')
      mCode = mCode.replaceAll('generateForm3', 'generateForm3Perincian');
    if (m == 'generatePotensiWargaPdf')
      mCode = mCode.replaceAll(
        'generatePotensiWargaPdf',
        'generatePotensiWargaPdfPerincian',
      );
    if (m == 'generateRekapPkkPdf')
      mCode = mCode.replaceAll(
        'generateRekapPkkPdf',
        'generateRekapPkkPerincianPdf',
      );
    if (m == 'generateLampidPdf')
      mCode = mCode.replaceAll(
        'generateLampidPdf',
        'generateLampidPdfPerincian',
      );
    perincianClass += mCode + "\n\n";
  }
  perincianClass += "}\n\n";
  perincianClass += """int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
""";

  String applyLayoutFixes(String pContent) {
    // Normalize newlines to \n before doing indexOf
    pContent = pContent.replaceAll('\\r\\n', '\\n');

    pContent = pContent.replaceAll(
      '0: const pw.FlexColumnWidth(80),',
      '0: const pw.FlexColumnWidth(58.4),',
    );
    pContent = pContent.replaceAll(
      "alignment: pw.Alignment.center,\n                      child: pw.Text(\n                        '\${r['namaKrt']}',",
      "alignment: pw.Alignment.centerLeft,\n                      child: pw.Text(\n                        '\${r['namaKrt']}',",
    );
    pContent = pContent.replaceAll(
      "alignment: pw.Alignment.center,\n                      child: pw.Text(\n                        '\${r['namaKk']}',",
      "alignment: pw.Alignment.centerLeft,\n                      child: pw.Text(\n                        '\${r['namaKk']}',",
    );

    // Center Jumlah row visually
    pContent = pContent.replaceAll(
      "                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    'Jumlah',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),\n                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    '\$tKrt',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),\n                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    '\$tKk',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),",
      "                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    '',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),\n                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    'JUMLAH',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),\n                pw.Container(\n                  padding: const pw.EdgeInsets.all(2),\n                  alignment: pw.Alignment.center,\n                  child: pw.Text(\n                    '',\n                    style: pw.TextStyle(font: boldFont, fontSize: 6),\n                  ),\n                ),",
    );

    // Padding for header in generateForm3Perincian
    pContent = pContent.replaceAll(
      "          header: (context) {\n            return pw.Column(\n              crossAxisAlignment: pw.CrossAxisAlignment.start,\n              children: [\n                pw.Text(\n                  'DATA KUANTITAS',\n                  style: pw.TextStyle(font: boldFont, fontSize: 14),\n                ),\n                pw.SizedBox(height: 16),\n                pw.Table(\n                  columnWidths: {\n                    0: const pw.FixedColumnWidth(60),\n                    1: const pw.FixedColumnWidth(10),\n                    2: const pw.FixedColumnWidth(300),",
      "          header: (context) {\n            return pw.Padding(\n              padding: const pw.EdgeInsets.only(left: 145),\n              child: pw.Column(\n              crossAxisAlignment: pw.CrossAxisAlignment.start,\n              children: [\n                pw.Text(\n                  'DATA KUANTITAS',\n                  style: pw.TextStyle(font: boldFont, fontSize: 14),\n                ),\n                pw.SizedBox(height: 16),\n                pw.Table(\n                  columnWidths: {\n                    0: const pw.FixedColumnWidth(60),\n                    1: const pw.FixedColumnWidth(10),\n                    2: const pw.FixedColumnWidth(300),",
    );
    pContent = pContent.replaceAll(
      "                pw.Container(height: 40, child: tableHeaderWidget),\n              ],\n            );\n          },",
      "                pw.Container(height: 40, child: tableHeaderWidget),\n              ],\n            ),\n            );\n          },",
    );

    final colRegex = RegExp(
      r"pw\.Column\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.center,\s*children: \[\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*\]\s*\)",
      dotAll: true,
    );
    pContent = pContent.replaceAllMapped(colRegex, (match) {
      return "pw.Text('${match.group(1)}\\n${match.group(2)}', style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 6), textAlign: pw.TextAlign.center)";
    });

    final col3Regex = RegExp(
      r"pw\.Column\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.center,\s*children: \[\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*\]\s*\)",
      dotAll: true,
    );
    pContent = pContent.replaceAllMapped(col3Regex, (match) {
      return "pw.Text('${match.group(1)}\\n${match.group(2)}\\n${match.group(3)}', style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 6), textAlign: pw.TextAlign.center)";
    });

    final col4Regex = RegExp(
      r"pw\.Column\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.center,\s*children: \[\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*pw\.Text\(\s*'([^']+)',\s*style: pw\.TextStyle\(font: pw\.Font\.helveticaBold\(\), fontSize: 6\),\s*textAlign: pw\.TextAlign\.center,\s*\),\s*\]\s*\)",
      dotAll: true,
    );
    pContent = pContent.replaceAllMapped(col4Regex, (match) {
      return "pw.Text('${match.group(1)}\\n${match.group(2)}\\n${match.group(3)}\\n${match.group(4)}', style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 6), textAlign: pw.TextAlign.center)";
    });
    return pContent;
  }

  await File(
    'lib/src/features/report/data/services/pdf_perincian_service.dart',
  ).writeAsString(applyLayoutFixes(perincianClass));
  await File(
    'lib/src/features/report/data/services/pdf_ringkasan_service.dart',
  ).writeAsString(applyLayoutFixes(ringkasanClass));
  print('Rebuilt files with correct extractMethod!');
}
