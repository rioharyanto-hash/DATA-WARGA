import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/data_warga_provider.dart';
import '../../domain/entities/data_warga_keluarga.dart';
import '../../domain/entities/data_warga_bangunan.dart';

class DataWargaScreen extends ConsumerWidget {
  const DataWargaScreen({super.key});

  static const _primaryDark = Color(0xFF4338CA); // Indigo 700
  static const _bgBody = Color(0xFFF8FAFC); // Slate 50
  static const _textMuted = Color(0xFF64748B); // Slate 500

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bgBody,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATA WARGA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Sistem Informasi Dasawisma',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.people, color: Colors.white),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Bangunan List
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Daftar Bangunan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final rtListAsync = ref.watch(dataWargaRtListProvider);
                    final rtFilter = ref.watch(dataWargaRtFilterProvider);

                    return rtListAsync.when(
                      data: (rtList) {
                        if (rtList.length <= 1) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: rtFilter,
                                hint: const Text(
                                  'Semua RT',
                                  style: TextStyle(fontSize: 14),
                                ),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: _textMuted,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'Semua RT',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  ...rtList.map(
                                    (rt) => DropdownMenuItem(
                                      value: rt,
                                      child: Text(
                                        'RT $rt',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  ref
                                      .read(dataWargaRtFilterProvider.notifier)
                                      .setFilter(val);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (val) {
                      ref
                          .read(dataWargaSearchQueryProvider.notifier)
                          .updateQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari bangunan atau nama warga...',
                      hintStyle: const TextStyle(
                        color: _textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: _textMuted,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _primaryDark),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final listAsync = ref.watch(
                        dataWargaBangunanListProvider,
                      );
                      final selectedId = ref.watch(selectedBangunanIdProvider);

                      return listAsync.when(
                        data: (list) {
                          if (list.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada data bangunan'),
                            );
                          }

                          // Auto-select first if none selected
                          if (selectedId == null && list.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref
                                  .read(selectedBangunanIdProvider.notifier)
                                  .select(list.first.id);
                            });
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final isSelected = item.id == selectedId;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(
                                          selectedBangunanIdProvider.notifier,
                                        )
                                        .select(item.id);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFDBEAFE)
                                          : Colors.white, // Blue 100
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF93C5FD)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.namaBangunan,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected
                                                          ? const Color(0xFF1E3A8A)
                                                          : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    item.jenisBangunan,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: isSelected ? const Color(0xFF1E40AF) : _textMuted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.formattedAddress,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? const Color(0xFF1E40AF)
                                                    : _textMuted,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.family_restroom,
                                                  size: 14,
                                                  color: isSelected
                                                      ? const Color(0xFF1E40AF)
                                                      : _textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${item.totalKk} KK',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF1E40AF,
                                                          )
                                                        : _textMuted,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.person,
                                                  size: 14,
                                                  color: isSelected
                                                      ? const Color(0xFF1E40AF)
                                                      : _textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${item.totalPenghuni} Warga',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF1E40AF,
                                                          )
                                                        : _textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Error: $err')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Panel: Detail
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final selectedBangunan = ref.watch(
                  dataWargaSelectedBangunanProvider,
                );

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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF), // Indigo 50
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: _primaryDark,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E7FF), // Indigo 100
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
                                        ],
                                      ),
                                      const SizedBox(height: 4),
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
                                              style: const TextStyle(
                                                color: _textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(
                                color: Color(0xFFF1F5F9),
                                height: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'TOTAL PENGHUNI',
                                  '${selectedBangunan.totalPenghuni} Orang',
                                ),
                                _buildStatDivider(),
                                _buildStatItem(
                                  'TOTAL KK',
                                  '${selectedBangunan.totalKk} Keluarga',
                                ),
                                _buildStatDivider(),
                                _buildStatItem(
                                  'LAKI-LAKI',
                                  '${selectedBangunan.lakiLaki} Orang',
                                ),
                                _buildStatDivider(),
                                _buildStatItem(
                                  'PEREMPUAN',
                                  '${selectedBangunan.perempuan} Orang',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Data Penghuni Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Data Penghuni (Kartu Keluarga)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildKeluargaList(selectedBangunan),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _textMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFF1F5F9), // Slate 100
    );
  }

  Widget _buildKeluargaList(DataWargaBangunan selectedBangunan) {
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
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
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'KEPALA KELUARGA / NO. KK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'JML. ANGGOTA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'STATUS HUNIAN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        );
      },
    );
  }

  Widget _buildKeluargaRow(BuildContext context, DataWargaKeluarga kk, DataWargaBangunan bangunan) {
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

    return InkWell(
      onTap: () {
        context.push('/detail-keluarga/${kk.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      '${kk.jumlahAnggota}',
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
}
