import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/data_warga/presentation/screens/data_warga_screen.dart',
  );
  String content = file.readAsStringSync();

  // 1. Fix "Kembali" back button
  final kembaliTarget = '''
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref
                          .read(selectedBangunanIdProvider.notifier)
                          .select(null);
                    },
                  ),
                  const Text(
                    'Kembali',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
''';

  final kembaliReplacement = '''
            InkWell(
              onTap: () {
                ref.read(selectedBangunanIdProvider.notifier).select(null);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Kembali',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
''';

  if (content.contains(kembaliTarget.trim())) {
    content = content.replaceFirst(
      kembaliTarget.trim(),
      kembaliReplacement.trim(),
    );
    print("Kembali button fixed.");
  } else {
    print("Kembali target not found!");
  }

  // 2. Fix Category label
  final titleTarget = '''
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      selectedBangunan.namaBangunan,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
''';
  final titleReplacement = '''
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedBangunan.namaBangunan,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
''';

  if (content.contains(titleTarget.trim())) {
    content = content.replaceFirst(titleTarget.trim(), titleReplacement.trim());
    print("Title category fixed.");
  } else {
    print("Title category target not found!");
  }

  // 3. Fix ListView.separated
  final listViewTarget = '''
                  // Table Body
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final kk = list[index];
                      return _buildKeluargaRow(context, kk, selectedBangunan);
                    },
                  ),
''';
  final listViewReplacement = '''
                  // Table Body
                  Column(
                    children: List.generate(list.length, (index) {
                      final kk = list[index];
                      return Column(
                        children: [
                          if (index > 0)
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _buildKeluargaRow(context, kk, selectedBangunan),
                        ],
                      );
                    }),
                  ),
''';

  if (content.contains(listViewTarget.trim())) {
    content = content.replaceFirst(
      listViewTarget.trim(),
      listViewReplacement.trim(),
    );
    print("ListView fixed.");
  } else {
    print("ListView target not found!");
  }

  file.writeAsStringSync(content);
}
