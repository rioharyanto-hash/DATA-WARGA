import 'dart:io';

void main() {
  final file = File('lib/src/features/report/presentation/screens/report_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Add jenisLaporanField before kelompokDropdown
  final jenisLaporanCode = '''
    final jenisLaporanField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<bool>(
          value: _isRingkasan,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(
                value: false,
                child: Text('1. Laporan Rincian (Per Kelompok Kader)')),
            DropdownMenuItem(
                value: true,
                child: Text('2. Laporan Ringkasan (Rekap Seluruh Kelompok)')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _isRingkasan = val;
              });
            }
          },
        ),
      ],
    );

    final kelompokDropdown = Column(
''';
  content = content.replaceFirst('    final kelompokDropdown = Column(\n', jenisLaporanCode);
  
  // 2. Change the layout in the Container (Desktop)
  final desktopLayoutOld = '''              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: kelompokDropdown),
                        const SizedBox(width: 16),
                        Expanded(child: bulanField),
                        const SizedBox(width: 16),
                        Expanded(child: rtField),
                        const SizedBox(width: 16),
                        Expanded(child: rwField),
                      ],
                    )''';
  final desktopLayoutNew = '''              child: isDesktop
                  ? Column(
                      children: [
                        jenisLaporanField,
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isRingkasan) ...[
                              Expanded(flex: 2, child: kelompokDropdown),
                              const SizedBox(width: 16),
                            ],
                            Expanded(child: bulanField),
                            const SizedBox(width: 16),
                            Expanded(child: rtField),
                            const SizedBox(width: 16),
                            Expanded(child: rwField),
                          ],
                        ),
                      ],
                    )''';
  content = content.replaceFirst(desktopLayoutOld, desktopLayoutNew);
  
  // 3. Change the layout in the Container (Mobile)
  final mobileLayoutOld = '''                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        kelompokDropdown,
                        const SizedBox(height: 16),
                        bulanField,
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: rtField),
                            const SizedBox(width: 16),
                            Expanded(child: rwField),
                          ],
                        ),
                      ],
                    ),''';
  final mobileLayoutNew = '''                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        jenisLaporanField,
                        const SizedBox(height: 16),
                        if (!_isRingkasan) ...[
                          kelompokDropdown,
                          const SizedBox(height: 16),
                        ],
                        bulanField,
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: rtField),
                            const SizedBox(width: 16),
                            Expanded(child: rwField),
                          ],
                        ),
                      ],
                    ),''';
  content = content.replaceFirst(mobileLayoutOld, mobileLayoutNew);
  
  // 4. Remove the Checkbox Row
  final checkboxRowOld = '''            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aksi Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _isRingkasan,
                      onChanged: (val) {
                        setState(() {
                          _isRingkasan = val ?? false;
                        });
                      },
                    ),
                    const Text(
                      'Cetak sebagai Laporan Ringkasan (Rekap per Kader)',
                    ),
                  ],
                ),
              ],
            ),''';
  final checkboxRowNew = '''            const Text(
              'Aksi Laporan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),''';
  content = content.replaceFirst(checkboxRowOld, checkboxRowNew);

  file.writeAsStringSync(content);
  print('Patched layout!');
}
