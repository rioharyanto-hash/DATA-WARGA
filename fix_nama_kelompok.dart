import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_user_screen.dart',
  );
  String content = file.readAsStringSync();

  // Find the exact block starting with "if (_selectedRole == 'KADER') ...["
  // and ending just before "TextFormField(" for "Nama Lengkap"
  final startIdx = content.indexOf("if (_selectedRole == 'KADER') ...[");
  if (startIdx != -1) {
    // Find where the next field starts (Nama Lengkap)
    final endIdx = content.indexOf(
      "TextFormField(\n                                          controller: _namaController",
      startIdx,
    );

    if (endIdx != -1) {
      final newBlock = '''if (_selectedRole == 'KADER') ...[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: TextFormField(
                                                  initialValue: 'BUAH GOWOK 010.',
                                                  readOnly: true,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Nama Kelompok',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    fillColor: Color(0xFFF1F3F5),
                                                    filled: true,
                                                  ),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 3,
                                                child: DropdownButtonFormField<String>(
                                                  value: _dawisRt ?? '001',
                                                  decoration: const InputDecoration(
                                                    labelText: 'RT',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  items: List.generate(20, (index) {
                                                    final val = (index + 1).toString().padLeft(3, '0');
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val, style: const TextStyle(fontSize: 13)),
                                                    );
                                                  }),
                                                  onChanged: (val) => setState(() => _dawisRt = val),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 3,
                                                child: DropdownButtonFormField<String>(
                                                  value: _dawisNoUrut ?? '001',
                                                  decoration: const InputDecoration(
                                                    labelText: 'No Urut',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  items: List.generate(5, (index) {
                                                    final val = (index + 1).toString().padLeft(3, '0');
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val, style: const TextStyle(fontSize: 13)),
                                                    );
                                                  }),
                                                  onChanged: (val) => setState(() => _dawisNoUrut = val),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        ''';

      content = content.replaceRange(startIdx, endIdx, newBlock);
      file.writeAsStringSync(content);
      print("Updated Nama Kelompok layout successfully!");
    } else {
      print("Could not find end index");
    }
  } else {
    print("Could not find start index");
  }
}
