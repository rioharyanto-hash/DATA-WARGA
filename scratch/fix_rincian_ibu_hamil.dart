import 'dart:io';

void main() async {
  final file = File('lib/src/features/report/data/services/pdf_perincian_service.dart');
  String content = await file.readAsString();

  final targetBlock = """                    // Data Rows
                    ...mutasiList.asMap().entries.map((entry) {
                      final int i = entry.key + 1;
                      final row = entry.value;

                      final jenisMutasi = row['jenis_mutasi']?.toString() ?? '';""";

  final replacementBlock = """                    // Data Rows
                    ...List.generate(mutasiList.length < 12 ? 12 : mutasiList.length, (index) {
                      if (index >= mutasiList.length) {
                        return pw.Container(
                          height: 18,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 0.5)),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              buildCell('', flex: 1, fontSize: 7),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 4),
                              buildCell('', flex: 4),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 3),
                              buildCell('', flex: 3),
                              buildCell('', flex: 1),
                              buildCell('', flex: 1),
                              buildCell('', flex: 2),
                              buildCell('', flex: 2),
                              buildCell('', flex: 3, noRightBorder: true),
                            ],
                          ),
                        );
                      }
                      final int i = index + 1;
                      final row = mutasiList[index];

                      final jenisMutasi = row['jenis_mutasi']?.toString() ?? '';""";

  if (content.contains(targetBlock)) {
    content = content.replaceFirst(targetBlock, replacementBlock);
    print("Replaced loop start.");
  } else {
    print("Could not find loop start.");
  }

  // Next, replace the return pw.Container inside the loop to include height 18
  final returnTargetBlock = """                      return pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(""";
                        
  final returnReplacementBlock = """                      return pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 0.5)),
                        ),
                        child: pw.Row(""";

  if (content.contains(returnTargetBlock)) {
    // Only replace the first occurrence after the loop start (we know it's in this function)
    int idx = content.indexOf("final jenisMutasi = row['jenis_mutasi']");
    if (idx != -1) {
       int targetIdx = content.indexOf(returnTargetBlock, idx);
       if (targetIdx != -1) {
          content = content.replaceRange(targetIdx, targetIdx + returnTargetBlock.length, returnReplacementBlock);
          print("Replaced return container.");
       }
    }
  } else {
    print("Could not find return container.");
  }

  // Next, remove the if (mutasiList.isEmpty) block
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
    print("Could not find empty block.");
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
