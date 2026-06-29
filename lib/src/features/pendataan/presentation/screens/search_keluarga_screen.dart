import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/keluarga_provider.dart';
import '../providers/bangunan_provider.dart';

class SearchKeluargaScreen extends ConsumerStatefulWidget {
  final String mode;
  const SearchKeluargaScreen({super.key, this.mode = 'master'});

  @override
  ConsumerState<SearchKeluargaScreen> createState() =>
      _SearchKeluargaScreenState();
}

class _SearchKeluargaScreenState extends ConsumerState<SearchKeluargaScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keluargaAsync = ref.watch(searchKeluargaProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Pilih Keluarga'), elevation: 0),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue.shade700,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Ketik Nama Kepala Keluarga / No KK...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF4338CA),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final kelompokDawisAsync = ref.watch(
                      uniqueKelompokDawisProvider,
                    );
                    final selectedFilter = ref.watch(
                      selectedKelompokDawisFilterProvider,
                    );

                    return kelompokDawisAsync.when(
                      loading: () =>
                          const LinearProgressIndicator(color: Colors.white54),
                      error: (err, stack) => const SizedBox(),
                      data: (list) {
                        if (list.isEmpty) return const SizedBox();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value:
                                  (selectedFilter == null ||
                                      !list.contains(selectedFilter))
                                  ? 'Semua'
                                  : selectedFilter,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF4338CA),
                              ),
                              items: list.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e == 'Semua'
                                        ? 'Semua Kelompok Dawis'
                                        : 'Dawis $e',
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                ref
                                    .read(
                                      selectedKelompokDawisFilterProvider
                                          .notifier,
                                    )
                                    .setFilter(val);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: keluargaAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF4338CA)),
              ),
              error: (err, stack) =>
                  Center(child: Text('Terjadi kesalahan: $err')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Belum ada data keluarga.'
                          : 'Tidak ditemukan keluarga dengan kata kunci "$_searchQuery"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final keluargaId = item['keluarga_id'] as String;
                    final namaKrt = item['nama_krt'] as String? ?? 'Tanpa Nama';
                    final noKk = item['no_kk'] as String? ?? '-';

                    return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFF4338CA,
                              ).withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.family_restroom,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                            title: Text(
                              namaKrt,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: Text(
                              'No. KK: $noKk',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF4338CA),
                            ),
                            onTap: () {
                              context.push(
                                '/detail-keluarga/$keluargaId?mode=${widget.mode}',
                              );
                            },
                          ),
                        )
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
