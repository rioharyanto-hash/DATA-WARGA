import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_perincian_service.dart');
  String content = await file.readAsString();

  final emptyBlock = """                    if (mutasiList.isEmpty)
                      pw.Container(
                        height: 16,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Tidak ada data mutasi',
                            style: pw.TextStyle(font: regularFont, fontSize: 8),
                          ),
                        ),
                      ),""";

  if (content.contains(emptyBlock)) {
    content = content.replaceFirst(emptyBlock, "");
    print("Removed empty block.");
  } else {
    print("Could not find empty block. Trying regex.");
    final regex = RegExp(r"if \(\s*mutasiList\.isEmpty\s*\)\s*pw\.Container\(\s*height:\s*16,\s*decoration:\s*const pw\.BoxDecoration\(\s*border:\s*pw\.Border\(top:\s*pw\.BorderSide\(width:\s*0\.5\)\),\s*\),\s*child:\s*pw\.Center\(\s*child:\s*pw\.Text\(\s*'Tidak ada data mutasi',\s*style:\s*pw\.TextStyle\(font:\s*regularFont,\s*fontSize:\s*8\),\s*\),\s*\),\s*\),");
    if (regex.hasMatch(content)) {
        content = content.replaceFirst(regex, "");
        print("Removed empty block via regex.");
    } else {
        print("Regex also failed to find it.");
    }
  }
  
  // also change JUMLAH Row height to 18
  final jumlahBlock = """                    // JUMLAH Row
                    pw.Container(
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),""";
  final jumlahReplace = """                    // JUMLAH Row
                    pw.Container(
                      height: 18,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1.0)),
                      ),""";
  
  if (content.contains(jumlahBlock)) {
      content = content.replaceFirst(jumlahBlock, jumlahReplace);
      print("Replaced JUMLAH height.");
  }

  await file.writeAsString(content);
}
