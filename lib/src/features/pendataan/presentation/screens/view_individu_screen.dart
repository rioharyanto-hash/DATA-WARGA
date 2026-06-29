import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/individu_provider.dart';
import '../providers/mutasi_provider.dart';

class ViewIndividuScreen extends ConsumerWidget {
  final String individuId;

  const ViewIndividuScreen({super.key, required this.individuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final individuAsync = ref.watch(individuByIdProvider(individuId));
    final mutasiAsync = ref.watch(mutasiByIndividuProvider(individuId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil Warga'),

        actions: [
          individuAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (individu) {
              if (individu == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Data Warga',
                onPressed: () {
                  context
                      .push(
                        '/form-individu-edit/${individu.idKeluarga}/${individu.id}',
                      )
                      .then((_) {
                        ref.invalidate(individuByIdProvider(individuId));
                      });
                },
              );
            },
          ),
        ],
      ),
      body: individuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (individu) {
          if (individu == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final dataDasarCard = _buildSection(
                context,
                title: 'Data Dasar',
                icon: Icons.person_outline,
                color: Colors.blue,
                fields: {
                  'Nama Lengkap': individu.namaLengkap,
                  'NIK': individu.nik,
                  'No. Telepon': individu.noTlp?.isNotEmpty == true
                      ? individu.noTlp!
                      : '-',
                  'Tempat, Tanggal Lahir':
                      '${individu.tempatLahir}, ${individu.tanggalLahir}',
                  'Jenis Kelamin': individu.jenisKelamin,
                  'Agama': individu.agama ?? '-',
                  'Alamat KTP': individu.alamatKtp?.isNotEmpty == true
                      ? individu.alamatKtp!
                      : '-',
                  'Alamat Domisili': individu.alamatDomisili?.isNotEmpty == true
                      ? individu.alamatDomisili!
                      : '-',

                  'Status Perkawinan': individu.statusPerkawinan,
                  'Pendidikan Terakhir': individu.pendidikanTerakhir,
                  'Pekerjaan': individu.pekerjaan,
                  'Hubungan Keluarga': individu.hubunganKeluarga,
                  'Status Yatim/Piatu':
                      individu.statusYatimPiatu?.isNotEmpty == true
                      ? individu.statusYatimPiatu!
                      : 'Tidak',
                },
              );

              final catatanKeluargaCard = _buildSection(
                context,
                title: 'Catatan Keluarga',
                icon: Icons.people_outline,
                color: const Color(0xFF10B981),
                fields: {
                  'Berkebutuhan Khusus':
                      individu.kriteriaBerkebutuhanKhusus?.isNotEmpty == true
                      ? individu.kriteriaBerkebutuhanKhusus!
                      : 'Tidak',
                  'Makanan Pokok': individu.makananPokok?.isNotEmpty == true
                      ? individu.makananPokok!
                      : '-',
                  'Ikut Kerja Bakti': individu.ikutKerjaBakti == 1
                      ? 'Ya'
                      : 'Tidak',
                  'Ikut UP2K': individu.isIkutUp2k == 1 ? 'Ya' : 'Tidak',
                  'Buta Huruf': individu.isButaHuruf == 1 ? 'Ya' : 'Tidak',
                  'Buta Angka': individu.isButaAngka == 1 ? 'Ya' : 'Tidak',
                  'Buta Bahasa': individu.isButaBahasa == 1 ? 'Ya' : 'Tidak',
                },
              );

              final bantuanSosialCard = _buildSection(
                context,
                title: 'Bantuan Sosial',
                icon: Icons.volunteer_activism,
                color: const Color(0xFF8B5CF6),
                fields: {
                  'Jenis Bantuan': individu.jenisBantuan?.isNotEmpty == true
                      ? individu.jenisBantuan!
                      : 'Tidak ada',
                  if (individu.jenisBantuan?.isNotEmpty == true) ...{
                    'Tanggal Bantuan': individu.tglBantuan ?? '-',
                    'Lama Bantuan': individu.lamaBantuan ?? '-',
                    'Jumlah Bantuan': individu.jumlahBantuan ?? '-',
                  },
                },
              );

              final potensiWargaCard = _buildSection(
                context,
                title: 'Potensi Warga',
                icon: Icons.bar_chart,
                color: const Color(0xFFF59E0B),
                fields: {
                  'Akte Kelahiran': individu.punyaAkteKelahiran == 1
                      ? 'Ya (${individu.noAkteKelahiran})'
                      : 'Tidak',
                  'Kepesertaan JKN/BPJS': individu.punyaBpjs == 1
                      ? 'Ya (${individu.jenisBpjs})'
                      : 'Tidak',
                  'Ibu Menyusui': individu.isIbuMenyusui == 1 ? 'Ya' : 'Tidak',
                  'Aktif Posyandu': individu.aktifPosyandu == 1
                      ? 'Ya (${individu.frekuensiPosyandu})'
                      : 'Tidak',
                  'Metode KB': individu.metodeKb?.isNotEmpty == true
                      ? individu.metodeKb!
                      : 'Bukan PUS / Tidak KB (${individu.alasanBukanKb ?? "-"})',
                  'Industri Rumah Tangga': individu.isIndustriRumahTangga == 1
                      ? 'Ya'
                      : 'Tidak',
                },
              );

              return mutasiAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error mutasi: $err')),
                data: (mutasiList) {
                  Widget riwayatMutasiCard;
                  if (mutasiList.isEmpty) {
                    riwayatMutasiCard = _buildSection(
                      context,
                      title: 'Riwayat Mutasi & Ibu Hamil',
                      icon: Icons.pregnant_woman_rounded,
                      color: const Color(0xFFEC4899),
                      fields: {'Status': 'Belum ada data mutasi'},
                    );
                  } else {
                    final mutasi = mutasiList.first;
                    riwayatMutasiCard = _buildSection(
                      context,
                      title: 'Riwayat Mutasi & Ibu Hamil',
                      icon: Icons.pregnant_woman_rounded,
                      color: const Color(0xFFEC4899),
                      fields: {
                        'Jenis Mutasi': mutasi.jenisMutasi,
                        'Tanggal': mutasi.tanggalMutasi,
                        if (mutasi.jenisMutasi == 'Meninggal' &&
                            mutasi.sebabKematian != null)
                          'Sebab': mutasi.sebabKematian!,
                        if (mutasi.jenisMutasi == 'Lahir' &&
                            mutasi.namaIbu != null)
                          'Nama Ibu': mutasi.namaIbu!,
                        if (mutasi.jenisMutasi == 'Pindah' &&
                            mutasi.tujuan != null)
                          'Tujuan': mutasi.tujuan!,
                        if (mutasi.jenisMutasi == 'Datang' &&
                            mutasi.asal != null)
                          'Asal': mutasi.asal!,
                        if (mutasi.statusIbu != null &&
                            mutasi.statusIbu!.isNotEmpty)
                          'Status Ibu': mutasi.statusIbu!,
                      },
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: dataDasarCard),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  catatanKeluargaCard,
                                  const SizedBox(height: 16),
                                  bantuanSosialCard,
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            dataDasarCard,
                            const SizedBox(height: 16),
                            catatanKeluargaCard,
                            const SizedBox(height: 16),
                            bantuanSosialCard,
                          ],
                        ),
                      const SizedBox(height: 16),
                      potensiWargaCard,
                      const SizedBox(height: 16),
                      riwayatMutasiCard,
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, String> fields,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: fields.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          e.key,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Text(
                        ' :  ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        flex: 7,
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
