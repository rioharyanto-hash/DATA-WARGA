import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/settings/presentation/screens/form_user_screen.dart',
  );
  String content = file.readAsStringSync();

  // 1. Replace all InputDecoration( to include floatingLabelBehavior
  // But wait, there might be 'const InputDecoration(' or 'InputDecoration('
  content = content.replaceAll(
    'InputDecoration(',
    'InputDecoration(floatingLabelBehavior: FloatingLabelBehavior.always, ',
  );

  // 2. Fix the Nama Kelompok custom container
  final target = '''
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Nama Kelompok',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      'BUAH GOWOK 010.',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(''';

  final replacement = '''
                                          InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Nama Kelompok',
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
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
                                                  child: DropdownButton<String>(''';

  if (content.contains(target)) {
    content = content.replaceAll(target, replacement);

    // We also need to remove the closing brackets for the Column that we removed.
    // The old Column ended at:
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                           const SizedBox(height: 16),
    final targetEnd = '''
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),''';
    final replacementEnd = '''
                                                    ),
                                                  ],
                                                ),
                                          ),
                                          const SizedBox(height: 16),''';
    content = content.replaceAll(targetEnd, replacementEnd);
    print("Nama Kelompok replaced successfully!");
  } else {
    print("Could not find Nama Kelompok block.");
  }

  file.writeAsStringSync(content);
  print('Done.');
}
