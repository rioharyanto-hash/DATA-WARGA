import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_user_screen.dart',
  );
  String content = file.readAsStringSync();

  // 1. Update Pendidikan options
  final oldPendidikan = '''
  final List<String> _pendidikanList = [
    'SD',
    'SMP',
    'SMA',
    'D3',
    'S1',
    'S2',
    'S3',
    'Lainnya',
  ];
''';
  final newPendidikan = '''
  final List<String> _pendidikanList = [
    'Tidak/Belum Sekolah',
    'SD/MI',
    'SMP/MTs',
    'SMA/SMK/MA',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];
''';
  content = content.replaceFirst(oldPendidikan, newPendidikan);

  // 2. Reduce horizontal padding of the main scroll view
  content = content.replaceFirst(
    'padding: const EdgeInsets.symmetric(\n                          horizontal: 24,\n                          vertical: 8,\n                        ),',
    'padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),',
  );

  // 3. Replace Nama Kelompok UI
  final oldNamaKelompok = '''
                                        if (_selectedRole == 'KADER') ...[
                                          InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Nama Kelompok',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                            ),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'BUAH GOWOK 010.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isDense: true,
                                                    value: _dawisRt,
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 16,
                                                    ),
                                                    items: List.generate(20, (
                                                      index,
                                                    ) {
                                                      final val = (index + 1)
                                                          .toString()
                                                          .padLeft(3, '0');
                                                      return DropdownMenuItem(
                                                        value: val,
                                                        child: Text(
                                                          val,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      );
                                                    }),
                                                    onChanged: (val) =>
                                                        setState(
                                                          () => _dawisRt = val,
                                                        ),
                                                  ),
                                                ),
                                                const Text(
                                                  '.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isDense: true,
                                                    value: _dawisNoUrut,
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 16,
                                                    ),
                                                    items: List.generate(5, (
                                                      index,
                                                    ) {
                                                      final val = (index + 1)
                                                          .toString()
                                                          .padLeft(3, '0');
                                                      return DropdownMenuItem(
                                                        value: val,
                                                        child: Text(
                                                          val,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      );
                                                    }),
                                                    onChanged: (val) =>
                                                        setState(
                                                          () => _dawisNoUrut =
                                                              val,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
''';

  final newNamaKelompok = '''
                                        if (_selectedRole == 'KADER') ...[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: TextFormField(
                                                  initialValue: 'BUAH GOWOK 010',
                                                  readOnly: true,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Kelompok',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: DropdownButtonFormField<String>(
                                                  value: _dawisRt,
                                                  decoration: const InputDecoration(
                                                    labelText: 'RT',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  ),
                                                  style: const TextStyle(fontSize: 13, color: Colors.black),
                                                  items: List.generate(20, (index) {
                                                    final val = (index + 1).toString().padLeft(3, '0');
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val),
                                                    );
                                                  }),
                                                  onChanged: (val) => setState(() => _dawisRt = val),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: DropdownButtonFormField<String>(
                                                  value: _dawisNoUrut,
                                                  decoration: const InputDecoration(
                                                    labelText: 'No Urut',
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  ),
                                                  style: const TextStyle(fontSize: 13, color: Colors.black),
                                                  items: List.generate(5, (index) {
                                                    final val = (index + 1).toString().padLeft(3, '0');
                                                    return DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val),
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

  content = content.replaceFirst(oldNamaKelompok, newNamaKelompok);

  // 4. Update Alamat & Kontak layout (Move RT and RW to their own row)
  final alamatStartIndex = content.indexOf(
    'Row(\n                                      children: [\n                                        Expanded(\n                                          flex: 6,\n                                          child: TextFormField(\n                                            controller: _alamatController,',
  );
  if (alamatStartIndex != -1) {
    // Find the end of this Row
    final alamatEndIndex = content.indexOf(
      'const SizedBox(height: 16),\n                                    Row(\n                                      children: [\n                                        Expanded(\n                                          child: TextFormField(\n                                            controller: _kelurahanController,',
      alamatStartIndex,
    );

    if (alamatEndIndex != -1) {
      final oldAlamatRow = content.substring(alamatStartIndex, alamatEndIndex);

      final newAlamatLayout = '''
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
                                              if (_rtController.text.isNotEmpty && !List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')).contains(_rtController.text))
                                                _rtController.text,
                                            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                _rtController.text = val;
                                              }
                                            },
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
                                              if (_rwController.text.isNotEmpty && !List.generate(20, (i) => (i + 1).toString().padLeft(2, '0')).contains(_rwController.text))
                                                _rwController.text,
                                            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                _rwController.text = val;
                                              }
                                            },
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
                                    ''';
      content = content.replaceFirst(oldAlamatRow, newAlamatLayout);
    }
  }

  file.writeAsStringSync(content);
  print('Updated form_user_screen.dart successfully.');
}
