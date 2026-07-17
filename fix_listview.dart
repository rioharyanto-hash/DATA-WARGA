import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/pendataan/presentation/screens/detail_keluarga_screen.dart',
  );
  String content = file.readAsStringSync();

  String target1 = '''
                          // Table Rows
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: individuItems.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            itemBuilder: (context, index) {
                              final individu = individuItems[index];''';

  String replacement1 = '''
                          // Table Rows
                          Column(
                            children: List.generate(individuItems.length, (index) {
                              final individu = individuItems[index];''';

  content = content.replaceAll(target1, replacement1);

  String target2 = '''
                            return InkWell(''';
  String replacement2 = '''
                            return Column(
                              children: [
                                InkWell(''';
  content = content.replaceAll(target2, replacement2);

  String target3 = '''
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],''';
  String replacement3 = '''
                                    ],
                                  ),
                                ),
                              ),
                              if (index < individuItems.length - 1)
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],''';

  content = content.replaceAll(target3, replacement3);

  file.writeAsStringSync(content);
  print('Done modifying');
}
