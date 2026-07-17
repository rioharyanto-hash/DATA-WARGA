import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../navigation/presentation/widgets/shared_app_bar_title.dart';

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

        title: const SharedAppBarTitle(
          title: 'Dashboard',
          subtitle: 'Sistem Informasi Dasawisma',
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
                                            onTap: () => _showDemografiDetail(
                                              context,
                                              ref,
                                              'Detail Jumlah Bangunan',
                                              'Jumlah Bangunan',
                                              ['RW', 'RT', 'Kelompok Dawis'],
                                              (e) => [
                                                (e['rw'] ?? '').toString(),
                                                (e['rt'] ?? '').toString(),
                                                (e['kelompok_dawis'] ?? '')
                                                    .toString(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Jumlah KK',
                                            summary.jumlahKk.toString(),
                                            Icons.family_restroom_rounded,
                                            const Color(0xFF6366F1),
                                            onTap: () => _showDemografiDetail(
                                              context,
                                              ref,
                                              'Detail Jumlah KK',
                                              'Jumlah KK',
                                              [
                                                'No. KK',
                                                'Kepala Keluarga',
                                                'RT',
                                                'RW',
                                              ],
                                              (e) => [
                                                (e['no_kk'] ?? '').toString(),
                                                (e['nama_krt'] ?? '')
                                                    .toString(),
                                                (e['rt'] ?? '').toString(),
                                                (e['rw'] ?? '').toString(),
                                              ],
                                            ),
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
                                            onTap: () => _showDemografiDetail(
                                              context,
                                              ref,
                                              'Detail Total Penduduk',
                                              'Total Penduduk',
                                              [
                                                'Nama Lengkap',
                                                'NIK',
                                                'L/P',
                                                'Tgl Lahir',
                                                'RT',
                                                'RW',
                                              ],
                                              (e) => [
                                                (e['nama_lengkap'] ?? '')
                                                    .toString(),
                                                (e['nik'] ?? '').toString(),
                                                (e['jenis_kelamin'] ?? '')
                                                    .toString(),
                                                (e['tanggal_lahir'] ?? '')
                                                    .toString(),
                                                (e['rt'] ?? '').toString(),
                                                (e['rw'] ?? '').toString(),
                                              ],
                                            ),
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
                                            onTap: () => _showDemografiDetail(
                                              context,
                                              ref,
                                              'Detail Total Mutasi',
                                              'Total Mutasi',
                                              [
                                                'Jenis Mutasi',
                                                'Keterangan',
                                                'RT',
                                                'RW',
                                              ],
                                              (e) => [
                                                (e['jenis_mutasi'] ?? '')
                                                    .toString(),
                                                (e['keterangan_mutasi'] ?? '')
                                                    .toString(),
                                                (e['rt'] ?? '').toString(),
                                                (e['rw'] ?? '').toString(),
                                              ],
                                            ),
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
                                                onTap: () =>
                                                    _showDemografiDetail(
                                                      context,
                                                      ref,
                                                      'Detail Jumlah Bangunan',
                                                      'Jumlah Bangunan',
                                                      [
                                                        'RW',
                                                        'RT',
                                                        'Kelompok Dawis',
                                                      ],
                                                      (e) => [
                                                        (e['rw'] ?? '')
                                                            .toString(),
                                                        (e['rt'] ?? '')
                                                            .toString(),
                                                        (e['kelompok_dawis'] ??
                                                                '')
                                                            .toString(),
                                                      ],
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Jumlah KK',
                                                summary.jumlahKk.toString(),
                                                Icons.family_restroom_rounded,
                                                const Color(0xFF6366F1),
                                                onTap: () =>
                                                    _showDemografiDetail(
                                                      context,
                                                      ref,
                                                      'Detail Jumlah KK',
                                                      'Jumlah KK',
                                                      [
                                                        'No. KK',
                                                        'Kepala Keluarga',
                                                        'RT',
                                                        'RW',
                                                      ],
                                                      (e) => [
                                                        (e['no_kk'] ?? '')
                                                            .toString(),
                                                        (e['nama_krt'] ?? '')
                                                            .toString(),
                                                        (e['rt'] ?? '')
                                                            .toString(),
                                                        (e['rw'] ?? '')
                                                            .toString(),
                                                      ],
                                                    ),
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
                                                onTap: () =>
                                                    _showDemografiDetail(
                                                      context,
                                                      ref,
                                                      'Detail Total Penduduk',
                                                      'Total Penduduk',
                                                      [
                                                        'Nama Lengkap',
                                                        'NIK',
                                                        'L/P',
                                                        'Tgl Lahir',
                                                        'RT',
                                                        'RW',
                                                      ],
                                                      (e) => [
                                                        (e['nama_lengkap'] ??
                                                                '')
                                                            .toString(),
                                                        (e['nik'] ?? '')
                                                            .toString(),
                                                        (e['jenis_kelamin'] ??
                                                                '')
                                                            .toString(),
                                                        (e['tanggal_lahir'] ??
                                                                '')
                                                            .toString(),
                                                        (e['rt'] ?? '')
                                                            .toString(),
                                                        (e['rw'] ?? '')
                                                            .toString(),
                                                      ],
                                                    ),
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
                                                onTap: () => _showDemografiDetail(
                                                  context,
                                                  ref,
                                                  'Detail Total Mutasi',
                                                  'Total Mutasi',
                                                  [
                                                    'Jenis Mutasi',
                                                    'Keterangan',
                                                    'RT',
                                                    'RW',
                                                  ],
                                                  (e) => [
                                                    (e['jenis_mutasi'] ?? '')
                                                        .toString(),
                                                    (e['keterangan_mutasi'] ??
                                                            '')
                                                        .toString(),
                                                    (e['rt'] ?? '').toString(),
                                                    (e['rw'] ?? '').toString(),
                                                  ],
                                                ),
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
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Jumlah Bangunan',
                                          'Jumlah Bangunan',
                                          ['RW', 'RT', 'Kelompok Dawis'],
                                          (e) => [
                                            (e['rw'] ?? '').toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['kelompok_dawis'] ?? '')
                                                .toString(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Jumlah KK',
                                        summary.jumlahKk.toString(),
                                        Icons.family_restroom_rounded,
                                        const Color(0xFF6366F1),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Jumlah KK',
                                          'Jumlah KK',
                                          [
                                            'No. KK',
                                            'Kepala Keluarga',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['no_kk'] ?? '').toString(),
                                            (e['nama_krt'] ?? '').toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Total Penduduk',
                                        (summary.jumlahLakiLaki +
                                                summary.jumlahPerempuan)
                                            .toString(),
                                        Icons.people_alt_rounded,
                                        const Color(0xFF10B981),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Total Penduduk',
                                          'Total Penduduk',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatCard(
                                        'Total Mutasi',
                                        summary.jumlahMutasi.toString(),
                                        Icons.published_with_changes_rounded,
                                        const Color(0xFFF59E0B),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Total Mutasi',
                                          'Total Mutasi',
                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
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
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Balita',
                                          'Balita (0-4 thn)',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Anak (5-9 thn)',
                                        (summary.umurGrouping['Anak (5-9)'] ??
                                                0)
                                            .toString(),
                                        Icons.face_rounded,
                                        const Color(0xFF10B981),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Anak',
                                          'Anak (5-9 thn)',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Remaja (10-24 thn)',
                                        (summary.umurGrouping['Remaja (10-24)'] ??
                                                0)
                                            .toString(),
                                        Icons.directions_run_rounded,
                                        const Color(0xFF10B981),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Remaja',
                                          'Remaja (10-24 thn)',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Dewasa (25-59 thn)',
                                        (summary.umurGrouping['Dewasa (25-59)'] ??
                                                0)
                                            .toString(),
                                        Icons.person_rounded,
                                        const Color(0xFF10B981),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Dewasa',
                                          'Dewasa (25-59 thn)',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Lansia (>=60 thn)',
                                        summary.jumlahLansia.toString(),
                                        Icons.elderly_rounded,
                                        const Color(0xFFF59E0B),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Lansia',
                                          'Lansia (>=60 thn)',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),

                                      // Gender
                                      _buildMiniStatCard(
                                        'Laki-laki',
                                        summary.jumlahLakiLaki.toString(),
                                        Icons.man_rounded,
                                        const Color(0xFF3B82F6),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Laki-laki',
                                          'Laki-laki',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Perempuan',
                                        summary.jumlahPerempuan.toString(),
                                        Icons.woman_rounded,
                                        const Color(0xFFEC4899),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Perempuan',
                                          'Perempuan',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),

                                      // WUS / PUS
                                      _buildMiniStatCard(
                                        'WUS',
                                        summary.jumlahWus.toString(),
                                        Icons.female_rounded,
                                        const Color(0xFFEC4899),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail WUS',
                                          'WUS',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'PUS',
                                        summary.jumlahPus.toString(),
                                        Icons.favorite_rounded,
                                        const Color(0xFF8B5CF6),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail PUS',
                                          'PUS',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),

                                      // Disabilitas
                                      _buildMiniStatCard(
                                        'Disabilitas',
                                        summary.jumlahDisabilitas.toString(),
                                        Icons.accessible_rounded,
                                        const Color(0xFFEF4444),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Disabilitas',
                                          'Disabilitas',
                                          [
                                            'Nama Lengkap',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),

                                      // LAMPID
                                      _buildMiniStatCard(
                                        'Lahir',
                                        summary.jumlahLahir.toString(),
                                        Icons.child_friendly_rounded,
                                        const Color(0xFF06B6D4),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Lahir',
                                          'Lahir',
                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Meninggal',
                                        summary.jumlahMeninggal.toString(),
                                        Icons
                                            .sentiment_very_dissatisfied_rounded,
                                        const Color(0xFF64748B),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Meninggal',
                                          'Meninggal',
                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Pindah',
                                        summary.jumlahPindah.toString(),
                                        Icons.flight_takeoff_rounded,
                                        const Color(0xFFF59E0B),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Pindah',
                                          'Pindah',
                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
                                      ),
                                      _buildMiniStatCard(
                                        'Datang',
                                        summary.jumlahDatang.toString(),
                                        Icons.flight_land_rounded,
                                        const Color(0xFF10B981),
                                        onTap: () => _showDemografiDetail(
                                          context,
                                          ref,
                                          'Detail Datang',
                                          'Datang',
                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'RT',
                                            'RW',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['rt'] ?? '').toString(),
                                            (e['rw'] ?? '').toString(),
                                          ],
                                        ),
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
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
      ),
    );
  }

  void _showDemografiDetail(
    BuildContext context,
    WidgetRef ref,
    String title,
    String category,
    List<String> columns,
    List<String> Function(Map<String, dynamic>) mapData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Consumer(
              builder: (ctx, ref, _) {
                final asyncData = ref.watch(
                  dashboardDemografiDetailProvider(category),
                );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: asyncData.when(
                        data: (data) {
                          if (data.isEmpty) {
                            return const Center(child: Text('Tidak ada data.'));
                          }
                          return SingleChildScrollView(
                            controller: controller,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey.shade100,
                                ),
                                columns: columns
                                    .map(
                                      (e) => DataColumn(
                                        label: Text(
                                          e,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                rows: data.map((rowMap) {
                                  final row = mapData(rowMap);
                                  return DataRow(
                                    cells: row
                                        .map((cell) => DataCell(Text(cell)))
                                        .toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdowns(WidgetRef ref) {
    final filterOptionsAsync = ref.watch(dashboardFilterOptionsProvider);
    final selectedRw = ref.watch(dashboardRwFilterProvider);
    final selectedRt = ref.watch(dashboardRtFilterProvider);
    final selectedKader = ref.watch(dashboardKaderFilterProvider);
    final user = ref.watch(loggedInUserProvider);

    return filterOptionsAsync.when(
      data: (options) {
        return Row(
          children: [
            if (user?.role == 'ADMIN') ...[
              _buildDropdown(
                value: selectedRw,
                items: options['rw'] ?? [],
                hint: 'RW',
                onChanged: (val) =>
                    ref.read(dashboardRwFilterProvider.notifier).update(val),
              ),
              const SizedBox(width: 8),
            ],
            if (user?.role == 'ADMIN' || user?.role == 'RW') ...[
              _buildDropdown(
                value: selectedRt,
                items: options['rt'] ?? [],
                hint: 'RT',
                onChanged: (val) =>
                    ref.read(dashboardRtFilterProvider.notifier).update(val),
              ),
              const SizedBox(width: 8),
            ],
            if (user?.role != 'KADER') ...[
              _buildDropdown(
                value: selectedKader,
                items: options['kader'] ?? [],
                hint: 'Kader',
                onChanged: (val) =>
                    ref.read(dashboardKaderFilterProvider.notifier).update(val),
              ),
            ],
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
