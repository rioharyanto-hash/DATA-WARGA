import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/data_warga/presentation/screens/data_warga_screen.dart',
  );
  String content = file.readAsStringSync();

  final startIdx = content.indexOf('Widget _buildDetailPanel(');
  if (startIdx == -1) {
    print('Failed to find _buildDetailPanel');
    return;
  }

  // Find the end of the class (the last '}')
  final endIdx = content.lastIndexOf('}');

  final prefix = content.substring(0, startIdx);

  final newCode = '''
  Widget _buildDetailPanel(
    BuildContext context,
    WidgetRef ref,
    bool isDesktop,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final selectedBangunan = ref.watch(dataWargaSelectedBangunanProvider);

        if (selectedBangunan == null) {
          return const Center(
            child: Text(
              'Pilih bangunan dari daftar di sebelah kiri',
              style: TextStyle(color: _textMuted),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF), // Indigo 50
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: _primaryDark,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE0E7FF,
                                    ), // Indigo 100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    selectedBangunan.jenisBangunan,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: _textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        selectedBangunan.formattedAddress,
                                        style: const TextStyle(color: _textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    // Stats Grid (2x2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'TOTAL PENGHUNI',
                            '\${selectedBangunan.totalPenghuni} Orang',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'TOTAL KK',
                            '\${selectedBangunan.totalKk} Keluarga',
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'LAKI-LAKI',
                            '\${selectedBangunan.lakiLaki} Orang',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'PEREMPUAN',
                            '\${selectedBangunan.perempuan} Orang',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Data Penghuni Section
              const Text(
                'Data Penghuni (Kartu Keluarga)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _buildKeluargaList(selectedBangunan, isDesktop),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildKeluargaList(DataWargaBangunan selectedBangunan, bool isDesktop) {
    return Consumer(
      builder: (context, ref, _) {
        final keluargaAsync = ref.watch(dataWargaKeluargaListProvider);

        return keluargaAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada data Kartu Keluarga',
                  style: TextStyle(color: _textMuted),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'KEPALA KELUARGA / NO. KK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        if (isDesktop) ...[
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'JML. ANGGOTA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'STATUS HUNIAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'JML. ANGGOTA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                'STATUS HUNIAN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Table Body
                  Column(
                    children: List.generate(list.length, (index) {
                      final kk = list[index];
                      return Column(
                        children: [
                          if (index > 0)
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          _buildKeluargaRow(context, kk, selectedBangunan, isDesktop),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: \$err')),
        );
      },
    );
  }

  Widget _buildKeluargaRow(
    BuildContext context,
    DataWargaKeluarga kk,
    DataWargaBangunan bangunan,
    bool isDesktop,
  ) {
    // Generate initials for avatar
    final words = kk.namaKepalaKeluarga
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    String initials = '';
    if (words.isNotEmpty) {
      initials += words[0][0].toUpperCase();
      if (words.length > 1) {
        initials += words[1][0].toUpperCase();
      }
    }

    // Status color
    Color statusBgColor = const Color(0xFFE2E8F0);
    Color statusTextColor = const Color(0xFF475569);

    final status = kk.statusHunian.toUpperCase();
    if (status.contains('PEMILIK') || status == 'MILIK SENDIRI') {
      statusBgColor = const Color(0xFFD1FAE5); // Emerald 100
      statusTextColor = const Color(0xFF059669); // Emerald 600
    } else if (status.contains('SEWA') || status.contains('KONTRAK')) {
      statusBgColor = const Color(0xFFF1F5F9); // Slate 100
      statusTextColor = const Color(0xFF475569); // Slate 600
    } else if (status.contains('NUMPANG')) {
      statusBgColor = const Color(0xFFE2E8F0); // Slate 200
      statusTextColor = const Color(0xFF334155); // Slate 700
    }

    if (isDesktop) {
      return InkWell(
        onTap: () {
          context.push('/detail-keluarga/\${kk.id}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFDBEAFE), // Blue 100
                      foregroundColor: const Color(0xFF1E3A8A), // Blue 900
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kk.namaKepalaKeluarga,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bangunan.formattedAddress,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            kk.noKk,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF), // Purple 100
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_alt,
                        size: 14,
                        color: Color(0xFF7E22CE),
                      ), // Purple 700
                      const SizedBox(width: 4),
                      Text(
                        '\${kk.jumlahAnggota}',
                        style: const TextStyle(
                          color: Color(0xFF7E22CE),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    kk.statusHunian.toUpperCase(),
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        context.push('/detail-keluarga/\${kk.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFDBEAFE), // Blue 100
              foregroundColor: const Color(0xFF1E3A8A), // Blue 900
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kk.namaKepalaKeluarga,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bangunan.formattedAddress,
                    style: const TextStyle(
                      color: Color(0xFF475569), // Slate 600
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kk.noKk,
                    style: const TextStyle(
                      color: Color(0xFF64748B), // Slate 500
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF), // Purple 100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_alt,
                              size: 14,
                              color: Color(0xFF7E22CE),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '\${kk.jumlahAnggota}',
                              style: const TextStyle(
                                color: Color(0xFF7E22CE),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor, // Slate 200 equivalent default
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          kk.statusHunian.toUpperCase(),
                          style: TextStyle(
                            color: statusTextColor, // Slate 700 equivalent default
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''';

  final newContent = prefix + newCode;
  file.writeAsStringSync(newContent);
  print('Layout redesigned.');
}
