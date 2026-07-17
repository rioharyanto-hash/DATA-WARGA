import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_user_screen.dart',
  );
  String content = file.readAsStringSync();

  // 1. Update PendidikanList
  final oldListRegex = RegExp(
    r"final List<String> _pendidikanList = \[[^\]]+\];",
  );
  final newList = '''final List<String> _pendidikanList = [
    'Tidak/Belum Sekolah',
    'SD/MI',
    'SMP/MTs',
    'SMA/SMK/MA',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];''';
  content = content.replaceFirst(oldListRegex, newList);

  // 2. Fix the Alamat Row.
  // We need to match the Row containing _alamatController, _rtController, _rwController
  // Since it's huge, let's locate the 'Alamat & Kontak' header, and replace the Row right after it.
  final startIdx = content.indexOf("'Alamat & Kontak'");
  if (startIdx != -1) {
    final rowStart = content.indexOf("Row(", startIdx);
    if (rowStart != -1) {
      // Find the end of the Row by counting brackets
      int bracketCount = 0;
      int rowEnd = -1;
      for (int i = rowStart; i < content.length; i++) {
        if (content[i] == '(') bracketCount++;
        if (content[i] == ')') {
          bracketCount--;
          if (bracketCount == 0) {
            rowEnd = i + 1;
            break;
          }
        }
      }

      if (rowEnd != -1) {
        final newRowContent = '''Column(
                                      children: [
                                        TextFormField(
                                          controller: _alamatController,
                                          decoration: const InputDecoration(
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            labelText: 'Alamat',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                initialValue: _rtController.text.isEmpty ? null : _rtController.text,
                                                items: [
                                                  ...List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')),
                                                  if (_rtController.text.isNotEmpty && !List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')).contains(_rtController.text)) _rtController.text,
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onChanged: (val) { if (val != null) _rtController.text = val; },
                                                decoration: const InputDecoration(
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  labelText: 'RT',
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                initialValue: _rwController.text.isEmpty ? null : _rwController.text,
                                                items: [
                                                  ...List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')),
                                                  if (_rwController.text.isNotEmpty && !List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')).contains(_rwController.text)) _rwController.text,
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onChanged: (val) { if (val != null) _rwController.text = val; },
                                                decoration: const InputDecoration(
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  labelText: 'RW',
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]
                                    )''';
        content = content.replaceRange(rowStart, rowEnd, newRowContent);
        print("Updated Alamat layout successfully!");
      }
    }
  }

  file.writeAsStringSync(content);
}
