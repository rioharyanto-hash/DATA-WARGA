import 'package:pdf/widgets.dart' as pw;

/// Utility class untuk menstandarisasi pembuatan PDF form di seluruh aplikasi.
class PdfFormBuilder {
  /// Membuat Header Form standar (Judul dan Metadata)
  /// [titleLines] adalah baris judul utama (misal: "DATA POTENSI WARGA")
  /// [infoMap] adalah key-value metadata (misal: {"NAMA KELOMPOK": "Melati"})
  /// [infoAlignment] mengatur letak metadata (default rata tengah)
  static pw.Widget buildFormHeader({
    required List<String> titleLines,
    required Map<String, String> infoMap,
    required pw.Font boldFont,
    required pw.Font regularFont,
    double titleFontSize = 10,
    double infoFontSize = 10,
    pw.MainAxisAlignment infoAlignment = pw.MainAxisAlignment.center,
    double spacing = 12,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        for (var title in titleLines)
          pw.Text(
            title,
            style: pw.TextStyle(font: boldFont, fontSize: titleFontSize),
            textAlign: pw.TextAlign.center,
          ),
        pw.SizedBox(height: spacing),
        pw.Row(
          mainAxisAlignment: infoAlignment,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (var entry in infoMap.entries) ...[
                  _buildInfoRow(
                    label: entry.key,
                    value: entry.value,
                    boldFont: boldFont,
                    regularFont: regularFont,
                    fontSize: infoFontSize,
                  ),
                  pw.SizedBox(height: 2),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: spacing),
      ],
    );
  }

  static pw.Widget _buildInfoRow({
    required String label,
    required String value,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required double fontSize,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(label,
              style: pw.TextStyle(font: boldFont, fontSize: fontSize)),
        ),
        pw.Text(' : ', style: pw.TextStyle(font: boldFont, fontSize: fontSize)),
        pw.Text(value,
            style: pw.TextStyle(font: regularFont, fontSize: fontSize)),
      ],
    );
  }

  /// Membangun cell tabel standar dengan border lengkap.
  /// Ini sering digunakan saat membangun custom header (yang butuh rowspan/colspan manual).
  static pw.Widget buildHeaderCell(
    String text,
    pw.Font font, {
    double fontSize = 8,
    pw.Alignment alignment = pw.Alignment.center,
    bool noRightBorder = false,
    bool noBottomBorder = false,
  }) {
    return pw.Container(
      alignment: alignment,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: noRightBorder
              ? pw.BorderSide.none
              : const pw.BorderSide(width: 0.5),
          bottom: noBottomBorder
              ? pw.BorderSide.none
              : const pw.BorderSide(width: 0.5),
        ),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize),
        textAlign: alignment == pw.Alignment.center
            ? pw.TextAlign.center
            : (alignment == pw.Alignment.centerLeft
                ? pw.TextAlign.left
                : pw.TextAlign.right),
      ),
    );
  }

  /// Membuat Data Row standar dengan padding dan alignment yang dapat diatur
  static pw.TableRow buildDataRow({
    required List<String> values,
    required pw.Font font,
    double fontSize = 6,
    double minHeight = 16,
    List<pw.Alignment>? alignments,
  }) {
    return pw.TableRow(
      children: List.generate(values.length, (index) {
        final alignment = (alignments != null && alignments.length > index)
            ? alignments[index]
            : pw.Alignment.center;
        
        final textAlign = alignment == pw.Alignment.centerLeft
            ? pw.TextAlign.left
            : (alignment == pw.Alignment.centerRight
                ? pw.TextAlign.right
                : pw.TextAlign.center);

        return pw.Container(
          padding: const pw.EdgeInsets.all(2),
          constraints: pw.BoxConstraints(minHeight: minHeight),
          alignment: alignment,
          child: pw.Text(
            values[index],
            style: pw.TextStyle(font: font, fontSize: fontSize),
            textAlign: textAlign,
          ),
        );
      }),
    );
  }

  /// Membangun keseluruhan tabel yang menggabungkan custom header dengan data rows (pw.Table).
  static pw.Widget buildDataTable({
    required pw.Widget headerWidget,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required List<pw.TableRow> dataRows,
    double borderWidth = 0.5,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Custom Header dengan manual colspan/rowspan
        headerWidget,
        // Data Body (pw.Table otomatis meratakan tinggi baris / intrinsic height constraint)
        pw.Table(
          border: pw.TableBorder.all(width: borderWidth),
          columnWidths: columnWidths,
          children: dataRows,
        ),
      ],
    );
  }
}
