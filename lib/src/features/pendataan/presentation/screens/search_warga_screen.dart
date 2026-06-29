import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/individu_provider.dart';

class SearchWargaScreen extends ConsumerStatefulWidget {
  final String nextRoute;
  const SearchWargaScreen({super.key, required this.nextRoute});

  @override
  ConsumerState<SearchWargaScreen> createState() => _SearchWargaScreenState();
}

class _SearchWargaScreenState extends ConsumerState<SearchWargaScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final individuAsync = ref.watch(searchIndividuProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Cari Warga'), elevation: 0),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue.shade700,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Ketik nama warga...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4338CA)),
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
          ),

          // Results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptySearch()
                : individuAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4338CA),
                      ),
                    ),
                    error: (err, stack) =>
                        Center(child: Text('Terjadi kesalahan: $err')),
                    data: (list) {
                      if (list.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ditemukan warga bernama "$_searchQuery"',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final individu = list[index];
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
                                      Icons.person,
                                      color: Color(0xFF4338CA),
                                    ),
                                  ),
                                  title: Text(
                                    individu.namaLengkap,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'NIK: ${individu.nik.isEmpty ? '-' : individu.nik}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF4338CA),
                                  ),
                                  onTap: () {
                                    // Navigate to the specified next route, appending the individu ID
                                    // e.g. /form-mutasi/123-abc
                                    context.push(
                                      '${widget.nextRoute}/${individu.id}',
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

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Ketik nama warga untuk mencari',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
