import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/individu_provider.dart';
import '../providers/keluarga_provider.dart';

class DetailKeluargaScreen extends ConsumerWidget {
  final String keluargaId;
  final String mode;

  const DetailKeluargaScreen({
    super.key,
    required this.keluargaId,
    this.mode = 'master',
  });

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    if (s == 'KK' || s == 'KEPALA KELUARGA' || s == 'KEPALA RUMAH TANGGA') {
      return const Color(0xFF2563EB); // Blue
    }
    if (s == 'ISTRI') return const Color(0xFFDC2626); // Red
    if (s == 'ANAK') return const Color(0xFF059669); // Green
    return const Color(0xFF475569); // Grey
  }

  Color _getStatusBgColor(String status) {
    final s = status.toUpperCase();
    if (s == 'KK' || s == 'KEPALA KELUARGA' || s == 'KEPALA RUMAH TANGGA') {
      return const Color(0xFFDBEAFE); // Blue 100
    }
    if (s == 'ISTRI') return const Color(0xFFFEE2E2); // Red 100
    if (s == 'ANAK') return const Color(0xFFD1FAE5); // Green 100
    return const Color(0xFFF1F5F9); // Grey 100
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuList = ref.watch(individuByKeluargaProvider(keluargaId));
    final keluargaData = ref.watch(keluargaByIdProvider(keluargaId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Keluarga'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // ── Info Keluarga ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      size: 28,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KARTU KELUARGA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        keluargaData.when(
                          loading: () => const Text('Memuat...'),
                          error: (err, stack) => const Text('Error'),
                          data: (keluarga) {
                            final noKk = keluarga?.noKk ?? 'Data tidak ditemukan';
                            return Text(
                              'NO. KK: $noKk',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Header Daftar Individu ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'DAFTAR ANGGOTA KELUARGA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                individuList.when(
                  data: (items) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length} Anggota',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Daftar Individu Table ──
          Expanded(
            child: individuList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Gagal memuat data individu: $error')),
              data: (individuItems) {
                if (individuItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data anggota keluarga.\nTekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('NAMA', style: _headerStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('NIK', style: _headerStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('STATUS KELUARGA', style: _headerStyle),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('USIA', style: _headerStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('TELEPON', style: _headerStyle),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text('AKSI', style: _headerStyle, textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: individuItems.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          itemBuilder: (context, index) {
                            final individu = individuItems[index];

                            // Hitung Usia
                            String ageText = '-';
                            if (individu.tanggalLahir.isNotEmpty) {
                              try {
                                final tglLahir = DateTime.parse(individu.tanggalLahir);
                                final today = DateTime.now();
                                int age = today.year - tglLahir.year;
                                if (today.month < tglLahir.month ||
                                    (today.month == tglLahir.month && today.day < tglLahir.day)) {
                                  age--;
                                }
                                ageText = '$age Tahun';
                              } catch (e) {
                                ageText = '-';
                              }
                            }

                            final status = individu.hubunganKeluarga;
                            final statusColor = _getStatusColor(status);
                            final statusBgColor = _getStatusBgColor(status);
                            final isLaki = individu.jenisKelamin == 'Laki-laki';

                            Widget trailingIcon;
                            if (mode == 'master') {
                              trailingIcon = const Icon(Icons.chevron_right, color: Color(0xFF94A3B8));
                            } else {
                              trailingIcon = Icon(
                                mode == 'catatan'
                                    ? Icons.edit_document
                                    : (mode == 'potensi'
                                        ? Icons.analytics_rounded
                                        : Icons.pregnant_woman_rounded),
                                color: const Color(0xFF4338CA),
                                size: 20,
                              );
                            }

                            return InkWell(
                              onTap: () async {
                                if (mode == 'master') {
                                  context.push('/view-individu/${individu.id}');
                                } else if (mode == 'catatan') {
                                  context.push('/form-catatan-keluarga/${individu.id}').then((_) {
                                    ref.invalidate(individuByKeluargaProvider(keluargaId));
                                  });
                                } else if (mode == 'potensi') {
                                  context.push('/form-potensi-warga/${individu.id}').then((_) {
                                    ref.invalidate(individuByKeluargaProvider(keluargaId));
                                  });
                                } else if (mode == 'mutasi') {
                                  final idBangunan = await ref.read(
                                    idBangunanByKeluargaProvider(keluargaId).future,
                                  );
                                  if (idBangunan != null && context.mounted) {
                                    context
                                        .push(
                                      Uri(
                                        path: '/form-mutasi/$idBangunan',
                                        queryParameters: {
                                          'idIndividuAsal': individu.id,
                                          'defaultNama': individu.namaLengkap,
                                          'defaultNik': individu.nik,
                                        },
                                      ).toString(),
                                    )
                                        .then((_) {
                                      ref.invalidate(individuByKeluargaProvider(keluargaId));
                                    });
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Gagal menemukan data Bangunan.')),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: statusBgColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isLaki ? Icons.person : Icons.person_2,
                                              size: 16,
                                              color: statusColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              individu.namaLengkap,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        individu.nik,
                                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        status.isNotEmpty ? status : '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        ageText,
                                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        individu.noTlp?.isNotEmpty == true ? individu.noTlp! : '-',
                                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: Center(child: trailingIcon),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/form-individu/$keluargaId'),
        backgroundColor: const Color(0xFFBFDBFE), // Blue 200
        foregroundColor: const Color(0xFF1D4ED8), // Blue 700
        elevation: 2,
        tooltip: 'Tambah Anggota',
        child: const Icon(Icons.add),
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.bold,
  color: Color(0xFF64748B),
  letterSpacing: 0.5,
);
