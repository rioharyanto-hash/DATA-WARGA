import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/data_warga/presentation/screens/data_warga_screen.dart',
  );
  String content = file.readAsStringSync();

  // 1. Fix "Kembali" back button
  final kembaliPattern = RegExp(
    r"Container\(\s*padding:\s*const\s*EdgeInsets\.symmetric\(horizontal:\s*8,\s*vertical:\s*8\),\s*color:\s*Colors\.white,\s*child:\s*Row\(\s*children:\s*\[\s*IconButton\(\s*icon:\s*const\s*Icon\(Icons\.arrow_back\),\s*onPressed:\s*\(\)\s*\{\s*ref\s*\.read\(selectedBangunanIdProvider\.notifier\)\s*\.select\(null\);\s*\},\s*\),\s*const\s*Text\(\s*'Kembali',\s*style:\s*TextStyle\(fontWeight:\s*FontWeight\.bold,\s*fontSize:\s*16\),\s*\),\s*\],\s*\),\s*\),",
  );

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
            ),''';

  content = content.replaceFirst(kembaliPattern, kembaliReplacement);

  // 2. Fix Category label
  final titlePattern = RegExp(
    r"Row\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.center,\s*children:\s*\[\s*Flexible\(\s*child:\s*Text\(\s*selectedBangunan\.namaBangunan,\s*style:\s*const\s*TextStyle\(\s*fontSize:\s*20,\s*fontWeight:\s*FontWeight\.bold,\s*\),\s*maxLines:\s*1,\s*overflow:\s*TextOverflow\.ellipsis,\s*\),\s*\),\s*const\s*SizedBox\(width:\s*12\),\s*Container\(",
  );
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
                                  Container(''';

  content = content.replaceFirst(titlePattern, titleReplacement);

  // 3. Fix ListView.separated
  final listViewPattern = RegExp(
    r"ListView\.separated\(\s*shrinkWrap:\s*true,\s*physics:\s*const\s*NeverScrollableScrollPhysics\(\),\s*itemCount:\s*list\.length,\s*separatorBuilder:\s*\(context,\s*index\)\s*=>\s*const\s*Divider\(height:\s*1,\s*color:\s*Color\(0xFFF1F5F9\)\),\s*itemBuilder:\s*\(context,\s*index\)\s*\{\s*final\s*kk\s*=\s*list\[index\];\s*return\s*_buildKeluargaRow\(context,\s*kk,\s*selectedBangunan\);\s*\},\s*\),",
  );

  final listViewReplacement = '''
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
                  ),''';

  content = content.replaceFirst(listViewPattern, listViewReplacement);

  file.writeAsStringSync(content);
  print('Regex script executed.');
}
