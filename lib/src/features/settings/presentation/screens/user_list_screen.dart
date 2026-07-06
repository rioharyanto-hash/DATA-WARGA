import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/app_user.dart';
import '../providers/app_user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dawis/src/features/laporan/services/data_transfer_service.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  bool _isImporting = false;

  Future<void> _importExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() => _isImporting = true);

      try {
        final service = DataTransferService();
        await service.importDataKader(path);

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
      final bytes = await service.generateImportTemplateKader();

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final filePath = '${downloadsDir.path}\\Template_Import_Kader.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Template berhasil disimpan di $filePath')),
          );
        }
      } else {
        throw Exception('Katalog Downloads tidak ditemukan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan template: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Kader Dawis',
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
            tooltip: 'Download Template Kader',
            icon: const Icon(Icons.download),
            onPressed: _isImporting ? null : _downloadTemplate,
          ),
          IconButton(
            tooltip: 'Import Excel Kader',
            icon: const Icon(Icons.upload_file),
            onPressed: _isImporting ? null : _importExcel,
          ),
        ],
      ),
      body: Stack(
        children: [
          usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Center(child: Text('Belum ada pengguna.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(context, user);
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
          context.push('/form-user');
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user) {
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
      case 'KADER':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    String territory = '';
    if (user.role == 'RW') {
      territory = 'RW ${user.rw ?? '-'}';
    } else if (user.role == 'RT') {
      territory = 'RT ${user.rt ?? '-'}/RW ${user.rw ?? '-'}';
    } else if (user.role == 'KADER') {
      territory =
          'Dawis ${user.kelompokDawis ?? '-'}, RT ${user.rt ?? '-'}/RW ${user.rw ?? '-'}';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          user.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${user.idKader}'),
            if (territory.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(territory, style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            user.role,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: chipColor,
          padding: EdgeInsets.zero,
        ),
        onTap: () {
          context.push('/form-user/${user.id}');
        },
      ),
    );
  }
}
