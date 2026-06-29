import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

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
        actions: const [
          Padding(
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
                                  final grid = GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 2.2,
                                    children: [
                                      _buildMiniStatCard(
                                        'Balita (0-5 thn)',
                                        summary.jumlahBalita.toString(),
                                        Icons.child_care_rounded,
                                        const Color(0xFF10B981),
                                      ),
                                      _buildMiniStatCard(
                                        'Lansia (>60 thn)',
                                        summary.jumlahLansia.toString(),
                                        Icons.elderly_rounded,
                                        const Color(0xFFF59E0B),
                                      ),
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
                                    ],
                                  );

                                  final chart = _buildUmurBarChart(
                                    summary.umurGrouping,
                                  );

                                  if (constraints.maxWidth >= 800) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: grid),
                                        const SizedBox(width: 24),
                                        Expanded(child: chart),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      grid,
                                      const SizedBox(height: 28),
                                      chart,
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

  Widget _buildUmurBarChart(Map<String, int> umurGrouping) {
    if (umurGrouping.isEmpty) return const SizedBox.shrink();

    final maxVal = umurGrouping.values.isEmpty
        ? 0
        : umurGrouping.values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const SizedBox.shrink();

    final labels = umurGrouping.keys.toList();
    final values = umurGrouping.values.toList();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelompok Umur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal * 1.3).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => _primaryDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${labels[group.x.toInt()]}\n${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[index]
                                .split(' ')
                                .first, // Just the name, e.g. "Balita"
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 5 ? (maxVal / 5).toDouble() : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  labels.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: _primaryLight,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
