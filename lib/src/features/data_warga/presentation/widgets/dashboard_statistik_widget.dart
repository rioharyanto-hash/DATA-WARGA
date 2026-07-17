import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class DashboardStatistikWidget extends ConsumerWidget {
  const DashboardStatistikWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgregatSection(context, ref),
          const SizedBox(height: 24),
          _buildDetailTabSection(),
        ],
      ),
    );
  }

  Widget _buildAgregatSection(BuildContext context, WidgetRef ref) {
    final agregatAsync = ref.watch(dashboardAgregatProvider);

    return agregatAsync.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rangkuman Demografi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  'Total KK',
                  data['totalKk'].toString(),
                  Icons.family_restroom,
                  Colors.blue,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Kepala Keluarga',
                    detailKkProvider,
                    ['No. KK', 'Nama Kepala Keluarga', 'RT', 'RW'],
                    (e) => [
                      (e['no_kk'] ?? '').toString(),
                      (e['nama_krt'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Total Warga',
                  data['totalWarga'].toString(),
                  Icons.people,
                  Colors.green,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Total Warga',
                    detailWargaProvider,
                    [
                      'Nama Lengkap',
                      'NIK',
                      'Jenis Kelamin',
                      'Tgl Lahir',
                      'RT',
                      'RW',
                    ],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['jenis_kelamin'] ?? '').toString(),
                      (e['tanggal_lahir'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Laki-laki',
                  data['totalLaki'].toString(),
                  Icons.male,
                  Colors.lightBlue,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Warga Laki-laki',
                    detailLakiProvider,
                    ['Nama Lengkap', 'NIK', 'Tgl Lahir', 'RT', 'RW'],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['tanggal_lahir'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Perempuan',
                  data['totalPerempuan'].toString(),
                  Icons.female,
                  Colors.pink,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Warga Perempuan',
                    detailPerempuanProvider,
                    ['Nama Lengkap', 'NIK', 'Tgl Lahir', 'RT', 'RW'],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['tanggal_lahir'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Total Bansos',
                  data['totalBansos'].toString(),
                  Icons.volunteer_activism,
                  Colors.orange,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Penerima Bansos',
                    detailBansosProvider,
                    [
                      'Nama Lengkap',
                      'NIK',
                      'Jenis Bantuan',
                      'Jumlah',
                      'RT',
                      'RW',
                    ],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['jenis_bantuan'] ?? '').toString(),
                      DashboardStatistikWidget.formatCurrency(
                        (e['jumlah_bantuan'] ?? '').toString(),
                      ),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Total Yatim/Piatu',
                  data['totalYatim'].toString(),
                  Icons.child_care,
                  Colors.purple,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Data Yatim/Piatu',
                    detailYatimProvider,
                    ['Nama Lengkap', 'NIK', 'Status', 'Tgl Lahir', 'RT', 'RW'],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['status_yatim_piatu'] ?? '').toString(),
                      (e['tanggal_lahir'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
                _buildStatCard(
                  'Disabilitas',
                  data['totalDifabel'].toString(),
                  Icons.accessible,
                  Colors.teal,
                  onTap: () => _showDemografiDetail(
                    context,
                    'Detail Data Disabilitas',
                    detailDisabilitasProvider,
                    ['Nama Lengkap', 'NIK', 'Kriteria Khusus', 'RT', 'RW'],
                    (e) => [
                      (e['nama_lengkap'] ?? '').toString(),
                      (e['nik'] ?? '').toString(),
                      (e['kriteria_berkebutuhan_khusus'] ?? '').toString(),
                      (e['rt'] ?? '').toString(),
                      (e['rw'] ?? '').toString(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  static String formatCurrency(String? amount) {
    if (amount == null || amount.isEmpty) return '-';
    // Remove non-digit characters if any (e.g. if already formatted)
    final cleanString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    final numValue = int.tryParse(cleanString);
    if (numValue == null) return amount;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(numValue);
  }

  void _showDemografiDetail(
    BuildContext context,
    String title,
    dynamic provider,
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
                final asyncData = ref.watch(provider);
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

  Widget _buildDetailTabSection() {
    return const DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Detail Warga',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            isScrollable: true,
            tabs: [
              Tab(text: 'Penerima Bansos'),
              Tab(text: 'Data Yatim/Piatu'),
              Tab(text: 'Data Disabilitas'),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _TabBansosView(),
                _TabYatimView(),
                _TabDisabilitasView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBansosView extends ConsumerWidget {
  const _TabBansosView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(detailBansosProvider);
    return asyncData.when(
      data: (data) => _buildTable(
        ['Nama Lengkap', 'NIK', 'Jenis Bantuan', 'Jumlah', 'RT', 'RW'],
        data
            .map(
              (e) => <String>[
                (e['nama_lengkap'] ?? '').toString(),
                (e['nik'] ?? '').toString(),
                (e['jenis_bantuan'] ?? '').toString(),
                DashboardStatistikWidget.formatCurrency(
                  (e['jumlah_bantuan'] ?? '').toString(),
                ),
                (e['rt'] ?? '').toString(),
                (e['rw'] ?? '').toString(),
              ],
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class _TabYatimView extends ConsumerWidget {
  const _TabYatimView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(detailYatimProvider);
    return asyncData.when(
      data: (data) => _buildTable(
        ['Nama Lengkap', 'NIK', 'Status', 'Tgl Lahir', 'RT', 'RW'],
        data
            .map(
              (e) => <String>[
                (e['nama_lengkap'] ?? '').toString(),
                (e['nik'] ?? '').toString(),
                (e['status_yatim_piatu'] ?? '').toString(),
                (e['tanggal_lahir'] ?? '').toString(),
                (e['rt'] ?? '').toString(),
                (e['rw'] ?? '').toString(),
              ],
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class _TabDisabilitasView extends ConsumerWidget {
  const _TabDisabilitasView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(detailDisabilitasProvider);
    return asyncData.when(
      data: (data) => _buildTable(
        ['Nama Lengkap', 'NIK', 'Kriteria Khusus', 'RT', 'RW'],
        data
            .map(
              (e) => <String>[
                (e['nama_lengkap'] ?? '').toString(),
                (e['nik'] ?? '').toString(),
                (e['kriteria_berkebutuhan_khusus'] ?? '').toString(),
                (e['rt'] ?? '').toString(),
                (e['rw'] ?? '').toString(),
              ],
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

Widget _buildTable(List<String> columns, List<List<String>> rows) {
  if (rows.isEmpty) {
    return const Center(child: Text('Tidak ada data.'));
  }
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
        columns: columns
            .map(
              (e) => DataColumn(
                label: Text(
                  e,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
            .toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: row.map((cell) => DataCell(Text(cell))).toList(),
          );
        }).toList(),
      ),
    ),
  );
}
