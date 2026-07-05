import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/app_user_provider.dart';
import '../providers/region_provider.dart';
import '../../services/csv_transfer_service.dart';
import '../../../pendataan/presentation/providers/bangunan_provider.dart';
import '../../../../../core/database/local_db_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _csvService = CsvTransferService();

  void _showImportResult(String title, ImportSummary summary) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Baris Data: ${summary.totalRows}'),
            Text(
              'Berhasil Diimpor: ${summary.acceptedRows}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Gagal/Ditolak: ${summary.rejectedRows}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (summary.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Detail Kesalahan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(
                    summary.errors.join('\n'),
                    style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    bool dialogShown = false;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;

      final csvData = await _csvService.exportAllDataToCsv();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        dialogShown = false;
      }

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Simpan Export Data CSV',
        fileName: 'export_dawis_data.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil diekspor ke: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengekspor data: $e')));
      }
    }
  }

  Future<void> _importData() async {
    bool dialogShown = false;
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );
        dialogShown = true;

        final summary = await _csvService.importBulkCsv(
          result.files.single.path!,
        );

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
          dialogShown = false;
          ref.invalidate(daftarBangunanProvider);
          _showImportResult('Hasil Impor Data Keseluruhan', summary);
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengimpor data: $e')));
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final csvData = await _csvService.generateTemplateCsv();

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Simpan Template CSV',
        fileName: 'template_import.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Template disimpan di: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal download template: $e')));
      }
    }
  }

  Future<void> _exportBangunan() async {
    bool dialogShown = false;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      dialogShown = true;

      final csvData = await _csvService.exportBangunanToCsv();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        dialogShown = false;
      }

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Simpan Export Data Bangunan CSV',
        fileName: 'export_bangunan.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data Bangunan berhasil diekspor ke: $outputFile'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengekspor data: $e')));
      }
    }
  }

  Future<void> _importBangunan() async {
    bool dialogShown = false;
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );
        dialogShown = true;

        final summary = await _csvService.importBangunanCsv(
          result.files.single.path!,
        );

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
          dialogShown = false;
          _showImportResult('Hasil Impor Data Bangunan', summary);
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengimpor data: $e')));
      }
    }
  }

  Future<void> _downloadTemplateBangunan() async {
    try {
      final csvData = await _csvService.generateTemplateBangunanCsv();

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Simpan Template Bangunan CSV',
        fileName: 'template_bangunan.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Template disimpan di: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal download template: $e')));
      }
    }
  }

  Future<void> _showRegionSettingsDialog() async {
    final region = ref.read(regionProvider);
    final kotaController = TextEditingController(text: region.kotaKab);
    final kecController = TextEditingController(text: region.kecamatan);
    final kelController = TextEditingController(text: region.kelurahan);

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan Wilayah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kotaController,
              decoration: const InputDecoration(labelText: 'Kota / Kabupaten'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: kecController,
              decoration: const InputDecoration(labelText: 'Kecamatan'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: kelController,
              decoration: const InputDecoration(labelText: 'Kelurahan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(regionProvider.notifier)
                  .saveRegion(
                    kotaKab: kotaController.text.trim(),
                    kecamatan: kecController.text.trim(),
                    kelurahan: kelController.text.trim(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan Wilayah Berhasil Disimpan'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,

        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              'Kelola preferensi dan manajemen data sistem DAWIS.',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white38, height: 1),
        ),
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(user),
                  const SizedBox(height: 32),
                  _buildMasterDataSection(user),
                  const SizedBox(height: 32),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: _buildTransferMentahSection()),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 1,
                          child: _buildTransferBangunanSection(),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTransferMentahSection(),
                        const SizedBox(height: 32),
                        _buildTransferBangunanSection(),
                      ],
                    ),
                  const SizedBox(height: 32),
                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF4EE6E6),
            child: const Icon(
              Icons.person_outline,
              size: 30,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Role: ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      user.role,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('|', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 16),
                    Text(
                      'ID: ${user.idKader}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.push('/profil'),
            icon: Icon(Icons.edit, size: 16, color: Colors.blue.shade900),
            label: Text(
              'Edit Profil',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterDataSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('MANAJEMEN DATA MASTER'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              if (user.role == 'ADMIN') ...[
                _buildListTile(
                  icon: Icons.people_alt,
                  iconColor: Colors.blue.shade700,
                  iconBg: Colors.blue.shade50,
                  title: 'Daftar Kader Dawis',
                  subtitle: 'Kelola data seluruh kader',
                  onTap: () => context.push('/user-list'),
                  showArrow: true,
                ),
                _buildDivider(),
              ],
              _buildListTile(
                icon: Icons.map_outlined,
                iconColor: Colors.teal.shade700,
                iconBg: Colors.teal.shade50,
                title: 'Pengaturan Wilayah',
                subtitle: 'Atur Kota/Kab, Kecamatan, dan Kelurahan',
                onTap: _showRegionSettingsDialog,
                showArrow: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferMentahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('TRANSFER DATA MENTAH'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildListTile(
                icon: Icons.download_rounded,
                iconColor: Colors.teal.shade600,
                iconBg: Colors.transparent,
                title: 'Download Template CSV',
                onTap: _downloadTemplate,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.upload_file_rounded,
                iconColor: Colors.blue.shade700,
                iconBg: Colors.transparent,
                title: 'Import Data Mentah (CSV)',
                subtitle: 'Masukkan data masal dari CSV',
                onTap: _importData,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.download_rounded,
                iconColor: Colors.red.shade700,
                iconBg: Colors.transparent,
                title: 'Export Seluruh Data (CSV)',
                subtitle: 'Unduh data dari database lokal',
                onTap: _exportData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferBangunanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('TRANSFER DATA BANGUNAN'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildListTile(
                icon: Icons.download_rounded,
                iconColor: Colors.teal.shade600,
                iconBg: Colors.transparent,
                title: 'Download Template Bangunan',
                onTap: _downloadTemplateBangunan,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.upload_file_rounded,
                iconColor: Colors.blue.shade700,
                iconBg: Colors.transparent,
                title: 'Import Bangunan (CSV)',
                subtitle: 'Masukkan data bangunan saja',
                onTap: _importBangunan,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.download_rounded,
                iconColor: Colors.red.shade700,
                iconBg: Colors.transparent,
                title: 'Export Data Bangunan (CSV)',
                subtitle: 'Unduh data bangunan dari lokal',
                onTap: _exportBangunan,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.delete_forever,
            iconColor: Colors.red.shade700,
            iconBg: Colors.red.shade50,
            title: 'Kosongkan Semua Data',
            titleColor: Colors.red.shade700,
            subtitle:
                'Hapus seluruh data bangunan & warga. Tindakan ini tidak dapat dibatalkan.',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Hapus Data'),
                  content: const Text(
                    'Apakah Anda yakin ingin MENGHAPUS SEMUA DATA di aplikasi ini? Tindakan ini tidak dapat dibatalkan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx2) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final db = await LocalDbHelper.database;
                          await db.delete('bangunan');
                          await db.delete('krt');
                          await db.delete('keluarga');
                          await db.delete('individu');
                          await db.delete('mutasi');
                          if (!mounted) return;
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(); // close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua data berhasil dihapus!'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(); // close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal hapus data: $e')),
                          );
                        }
                      },
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(color: Colors.red.shade100, height: 1),
          _buildListTile(
            icon: Icons.logout,
            iconColor: Colors.black87,
            iconBg: Colors.grey.shade200,
            title: 'Keluar / Logout',
            titleColor: Colors.black87,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        ref.read(loggedInUserProvider.notifier).clearUser();
                        context.go('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}
