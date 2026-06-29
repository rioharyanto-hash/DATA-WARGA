import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bangunan_provider.dart';
import 'package:dawis/src/features/settings/presentation/providers/app_user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BangunanListScreen extends ConsumerWidget {
  const BangunanListScreen({super.key});

  // ── Design tokens ──────────────────────────────────────────────────
  static const _tealStart = Color(0xFF4338CA); // Indigo 700
  static const _tealEnd = Color(0xFF6366F1); // Indigo 500
  static const _bgColor = Color(0xFFF8FAFC); // Slate 50
  static const _charcoal = Color(0xFF0F172A); // Slate 900
  static const _subtitle = Color(0xFF64748B); // Slate 500
  static const _cardRadius = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangunanAsync = ref.watch(filteredDaftarBangunanProvider);

    // Derive count text
    String countText = '';
    bangunanAsync.whenData((list) {
      final len = (list as List).length;
      countText = '$len bangunan terdaftar';
    });

    final user = ref.watch(loggedInUserProvider);
    final selectedFilter = ref.watch(selectedKelompokDawisFilterProvider);
    final uniqueDawisAsync = ref.watch(uniqueKelompokDawisProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Bangunan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (countText.isNotEmpty)
              Text(
                countText,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (user?.role == 'ADMIN')
            uniqueDawisAsync.when(
              data: (dawisList) {
                if (dawisList.length <= 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedFilter ?? 'Semua',
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          color: Colors.white,
                        ),
                        style: const TextStyle(
                          color: _charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return dawisList.map((String item) {
                            return Center(
                              child: Text(
                                item == 'Semua'
                                    ? 'Semua Kader'
                                    : 'Dawis: $item',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: dawisList.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item == 'Semua' ? 'Semua Kader' : 'Dawis: $item',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          ref
                              .read(
                                selectedKelompokDawisFilterProvider.notifier,
                              )
                              .setFilter(val);
                        },
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: bangunanAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _tealStart)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _subtitle,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (bangunanList) {
          if (bangunanList.isEmpty) {
            return _buildEmptyState();
          }
          return _buildList(context, ref, bangunanList);
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _tealEnd.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_work_rounded,
                size: 56,
                color: _tealEnd.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada data bangunan.\nTekan tombol + untuk mulai mendata.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: _subtitle, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> bangunanList,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: bangunanList.length,
          itemBuilder: (context, index) {
            final b = bangunanList[index];
            return _buildCard(context, ref, b);
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_cardRadius),
          onTap: () => context.push('/detail-bangunan/${b.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Left accent icon ──
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_tealStart, _tealEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b.nomorUrutBangunan.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // ── Text content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.namaBangunan,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Builder(
                        builder: (context) {
                          final String? katName = const {
                            1: 'Rumah Tinggal',
                            2: 'Kontrakan',
                            3: 'Kos-kosan',
                            4: 'Asrama/Mess',
                            5: 'Rusun',
                            6: 'Rumah Dinas',
                            7: 'Apartemen',
                            8: 'Rukan/Ruko',
                            9: 'Kios/Toko/Warung',
                            10: 'Tempat Usaha Lainnya',
                            11: 'Sekolah',
                            12: 'Tempat Ibadah',
                            13: 'Panti',
                            14: 'Lainnya',
                          }[b.kategoriBangunan];
                          final katText = katName != null
                              ? '  •  $katName'
                              : '';
                          return Text(
                            '${b.alamatLengkap}\nDawis: ${b.kelompokDawis}  •  RT ${b.rt} / RW ${b.rw}\n${b.statusHunian}$katText',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _subtitle,
                              height: 1.5,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ── Menu ──
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: _subtitle),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/form-bangunan/${b.id}');
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Bangunan'),
                          content: const Text(
                            'Apakah Anda yakin ingin menghapus bangunan ini beserta seluruh data di dalamnya?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final repo = ref.read(bangunanRepositoryProvider);
                        await repo.deleteBangunan(b.id);
                        ref.invalidate(daftarBangunanProvider);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_tealStart, _tealEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _tealStart.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.push('/form-bangunan'),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack);
  }
}
