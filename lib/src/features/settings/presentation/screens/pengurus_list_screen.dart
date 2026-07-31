import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../providers/app_user_provider.dart';
import 'package:dawis/src/features/laporan/services/data_transfer_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class PengurusListScreen extends ConsumerStatefulWidget {
  const PengurusListScreen({super.key});

  @override
  ConsumerState<PengurusListScreen> createState() => _PengurusListScreenState();
}

class _PengurusListScreenState extends ConsumerState<PengurusListScreen> {
  bool _isImporting = false;

  Future<void> _importExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() => _isImporting = true);

      try {
        final service = DataTransferService();
        await service.importDataPengurus(
          filePath: kIsWeb ? null : file.path,
          bytes: file.bytes,
        );

        ref.invalidate(allUsersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import Excel berhasil!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal import Excel: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isImporting = false);
        }
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final service = DataTransferService();
      final bytes = await service.generateImportTemplatePengurus();

      if (kIsWeb) {
        final base64data = base64Encode(bytes);
        html.AnchorElement(
            href:
                'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64data',
          )
          ..setAttribute('download', 'Template_Import_Pengurus.xlsx')
          ..click();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template berhasil diunduh.')),
          );
        }
      } else {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final filePath =
              '${downloadsDir.path}\\Template_Import_Pengurus.xlsx';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Template berhasil disimpan di $filePath'),
              ),
            );
          }
        } else {
          throw Exception('Katalog Downloads tidak ditemukan');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan template: $e')));
      }
    }
  }

  Future<void> _confirmDelete(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengurus'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final repository = ref.read(appUserRepositoryProvider);
      await repository.deleteUser(user.id);
      ref.invalidate(allUsersProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengurus berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus pengurus: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final currentUser = ref.watch(loggedInUserProvider);
    final isAdmin = currentUser?.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pengurus',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Download Template Pengurus',
            icon: const Icon(Icons.download),
            onPressed: _isImporting ? null : _downloadTemplate,
          ),
          IconButton(
            tooltip: 'Import Excel RT/RW',
            icon: const Icon(Icons.upload_file),
            onPressed: _isImporting ? null : _importExcel,
          ),
        ],
      ),
      body: Stack(
        children: [
          usersAsync.when(
            data: (users) {
              final pengurusList = users
                  .where(
                    (u) =>
                        u.role == 'ADMIN' || u.role == 'RW' || u.role == 'RT',
                  )
                  .toList();

              pengurusList.sort((a, b) {
                int priority(String? role) {
                  if (role == 'ADMIN') return 0;
                  if (role == 'RW') return 1;
                  return 2;
                }

                final pA = priority(a.role);
                final pB = priority(b.role);
                if (pA != pB) return pA.compareTo(pB);

                final rtA = (a.rt ?? '').padLeft(3, '0');
                final rtB = (b.rt ?? '').padLeft(3, '0');
                return rtA.compareTo(rtB);
              });

              if (pengurusList.isEmpty) {
                return const Center(child: Text('Belum ada pengurus.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pengurusList.length,
                itemBuilder: (context, index) {
                  final user = pengurusList[index];
                  return _buildUserCard(context, user, index + 1, isAdmin);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          if (_isImporting)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Sedang Mengimpor Data...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/form-pengurus');
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AppUser user,
    int index,
    bool isAdmin,
  ) {
    Color chipColor;
    switch (user.role) {
      case 'ADMIN':
        chipColor = Colors.red;
        break;
      case 'RW':
        chipColor = Colors.orange;
        break;
      case 'RT':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    String territory = '';
    if (user.role == 'RW') {
      territory = 'RW ${user.rw ?? '-'}';
    } else if (user.role == 'RT') {
      territory = 'RT ${user.rt ?? '-'}/RW ${user.rw ?? '-'}';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue.shade100,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID/Username: ${user.idKader}'),
            if (territory.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(territory, style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                user.role,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: chipColor,
              padding: EdgeInsets.zero,
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(user),
              ),
          ],
        ),
        onTap: () {
          context.push('/form-pengurus/${user.id}');
        },
      ),
    );
  }
}
