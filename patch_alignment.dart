import 'dart:io';

void main() {
  final file = File(
    r'E:\Project\DAWIS\lib\src\features\report\data\services\pdf_report_service.dart',
  );
  var content = file.readAsStringSync();

  // Find buildCell in generateProfilUsiaRingkasanPdf
  final startMethod = content.indexOf(
    'Future<Uint8List> generateProfilUsiaRingkasanPdf',
  );
  if (startMethod == -1) {
    print('Method not found');
    return;
  }

  final buildCellStart = content.indexOf('pw.Widget buildCell(', startMethod);
  final buildCellEnd = content.indexOf('if (flex != null) {', buildCellStart);

  final originalBuildCell = content.substring(buildCellStart, buildCellEnd);

  final newBuildCell = '''pw.Widget buildCell(
      String text, {
      double? width,
      int? flex,
      bool isHeader = false,
      bool noRightBorder = false,
      bool bottomBorder = false,
      double? fontSize,
      pw.Alignment alignment = pw.Alignment.center,
    }) {
      final content = pw.Container(
        width: width,
        padding: const pw.EdgeInsets.all(1),
        alignment: alignment,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: noRightBorder
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.5),
            bottom: bottomBorder
                ? const pw.BorderSide(width: 0.5)
                : pw.BorderSide.none,
          ),
        ),
        child: pw.Text(
          text,
          textAlign: alignment == pw.Alignment.centerLeft ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: fontSize ?? (isHeader ? 6 : 8),
          ),
        ),
      );

      ''';

  content = content.replaceRange(buildCellStart, buildCellEnd, newBuildCell);
  file.writeAsStringSync(content);
  print('Patched buildCell alignment successfully');
}
