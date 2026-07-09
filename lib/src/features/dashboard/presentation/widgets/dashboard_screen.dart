import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _primaryDark = Color(0xFF4338CA); // Indigo 700
  static const _primaryLight = Color(0xFF6366F1); // Indigo 500
  static const _bgColor = Color(0xFFF8FAFC); // Slate 50
  static const _textDark = Color(0xFF0F172A); // Slate 900
  static const _textMuted = Color(0xFF64748B); // Slate 500

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
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
        actions: [
          _buildFilterDropdowns(ref),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.dashboard_rounded, color: Colors.white),
          ),
        ],
      ),
      body: dashboardSummaryAsync.when(
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(dashboardSummaryProvider);
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),

                // ── Content ──
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Summary Cards Row ──
                          LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth >= 800) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'Jumlah Bangunan',
                                            summary.jumlahBangunan.toString(),
                                            Icons.apartment_rounded,
                                            const Color(0xFF3B82F6),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Jumlah KK',
                                            summary.jumlahKk.toString(),
                                            Icons.family_restroom_rounded,
                                            const Color(0xFF6366F1),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Total Penduduk',
                                            (summary.jumlahLakiLaki +
                                                    summary.jumlahPerempuan)
                                                .toString(),
                                            Icons.people_alt_rounded,
                                            const Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Total Mutasi',
                                            summary.jumlahMutasi.toString(),
                                            Icons
                                                .published_with_changes_rounded,
                                            const Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (constraints.maxWidth >= 500) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Jumlah Bangunan',
                                                summary.jumlahBangunan
                                                    .toString(),
                                                Icons.apartment_rounded,
                                                const Color(0xFF3B82F6),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Jumlah KK',
                                                summary.jumlahKk.toString(),
                                                Icons.family_restroom_rounded,
                                                const Color(0xFF6366F1),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Total Penduduk',
                                                (summary.jumlahLakiLaki +
                                                        summary.jumlahPerempuan)
                                                    .toString(),
                                                Icons.people_alt_rounded,
                                                const Color(0xFF10B981),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Total Mutasi',
                                                summary.jumlahMutasi.toString(),
                                                Icons
                                                    .published_with_changes_rounded,
                                                const Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      _buildStatCard(
                                        'Jumlah Bangunan',
                                        summary.jumlahBangunan.toString(),
                                        Icons.apartment_rounded,
                                        const Color(0xFF3B82F6),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Jumlah KK',
                                        summary.jumlahKk.toString(),
                                        Icons.family_restroom_rounded,
                                        const Color(0xFF6366F1),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Total Penduduk',
                                        (summary.jumlahLakiLaki +
                                                summary.jumlahPerempuan)
                                            .toString(),
                                        Icons.people_alt_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Total Mutasi',
                                        summary.jumlahMutasi.toString(),
                                        Icons.published_with_changes_rounded,
                                        const Color(0xFFF59E0B),
                                      ),
                                    ],
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 28),

                          // ── Demografi Section Header ──
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [_primaryDark, _primaryLight],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Demografi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ── Demografi Grid ──
                          LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 2;
                                  if (constraints.maxWidth >= 800) {
                                    crossAxisCount = 4;
                                  } else if (constraints.maxWidth >= 600) {
                                    crossAxisCount = 3;
                                  }

                                  return GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 2.2,
                                    children: [
                                      // Kelompok Umur
                                      _buildMiniStatCard(
                                        'Balita (0-4 thn)',
                                        (summary.umurGrouping['Balita (0-4)'] ??
                                                0)
                                            .toString(),
                                        Icons.child_care_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      _buildMiniStatCard(
                                        'Anak (5-9 thn)',
                                        (summary.umurGrouping['Anak (5-9)'] ??
                                                0)
                                            .toString(),
                                        Icons.face_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      _buildMiniStatCard(
                                        'Remaja (10-24 thn)',
                                        (summary.umurGrouping['Remaja (10-24)'] ??
                                                0)
                                            .toString(),
                                        Icons.directions_run_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      _buildMiniStatCard(
                                        'Dewasa (25-59 thn)',
                                        (summary.umurGrouping['Dewasa (25-59)'] ??
                                                0)
                                            .toString(),
                                        Icons.person_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      _buildMiniStatCard(
                                        'Lansia (>=60 thn)',
                                        summary.jumlahLansia.toString(),
                                        Icons.elderly_rounded,
                                        const Color(0xFFF59E0B),
                                      ),

                                      // Gender
                                      _buildMiniStatCard(
                                        'Laki-laki',
                                        summary.jumlahLakiLaki.toString(),
                                        Icons.man_rounded,
                                        const Color(0xFF3B82F6),
                                      ),
                                      _buildMiniStatCard(
                                        'Perempuan',
                                        summary.jumlahPerempuan.toString(),
                                        Icons.woman_rounded,
                                        const Color(0xFFEC4899),
                                      ),

                                      // WUS / PUS
                                      _buildMiniStatCard(
                                        'WUS',
                                        summary.jumlahWus.toString(),
                                        Icons.female_rounded,
                                        const Color(0xFFEC4899),
                                      ),
                                      _buildMiniStatCard(
                                        'PUS',
                                        summary.jumlahPus.toString(),
                                        Icons.favorite_rounded,
                                        const Color(0xFF8B5CF6),
                                      ),

                                      // Disabilitas
                                      _buildMiniStatCard(
                                        'Disabilitas',
                                        summary.jumlahDisabilitas.toString(),
                                        Icons.accessible_rounded,
                                        const Color(0xFFEF4444),
                                      ),

                                      // LAMPID
                                      _buildMiniStatCard(
                                        'Lahir',
                                        summary.jumlahLahir.toString(),
                                        Icons.child_friendly_rounded,
                                        const Color(0xFF06B6D4),
                                      ),
                                      _buildMiniStatCard(
                                        'Meninggal',
                                        summary.jumlahMeninggal.toString(),
                                        Icons
                                            .sentiment_very_dissatisfied_rounded,
                                        const Color(0xFF64748B),
                                      ),
                                      _buildMiniStatCard(
                                        'Pindah',
                                        summary.jumlahPindah.toString(),
                                        Icons.flight_takeoff_rounded,
                                        const Color(0xFFF59E0B),
                                      ),
                                      _buildMiniStatCard(
                                        'Datang',
                                        summary.jumlahDatang.toString(),
                                        Icons.flight_land_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                    ],
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primaryDark)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan',
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
                  style: const TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdowns(WidgetRef ref) {
    final filterOptionsAsync = ref.watch(dashboardFilterOptionsProvider);
    final selectedRw = ref.watch(dashboardRwFilterProvider);
    final selectedRt = ref.watch(dashboardRtFilterProvider);
    final selectedKader = ref.watch(dashboardKaderFilterProvider);

    return filterOptionsAsync.when(
      data: (options) {
        return Row(
          children: [
            _buildDropdown(
              value: selectedRw,
              items: options['rw'] ?? [],
              hint: 'RW',
              onChanged: (val) =>
                  ref.read(dashboardRwFilterProvider.notifier).update(val),
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              value: selectedRt,
              items: options['rt'] ?? [],
              hint: 'RT',
              onChanged: (val) =>
                  ref.read(dashboardRtFilterProvider.notifier).update(val),
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              value: selectedKader,
              items: options['kader'] ?? [],
              hint: 'Kader',
              onChanged: (val) =>
                  ref.read(dashboardKaderFilterProvider.notifier).update(val),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    // Check if the current value exists in the options
    final effectiveValue = value != null && items.contains(value)
        ? value
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: effectiveValue,
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        dropdownColor: _primaryDark,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        underline: const SizedBox(),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Semua',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          ...items.map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
