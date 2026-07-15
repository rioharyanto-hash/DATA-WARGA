import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../providers/app_user_provider.dart';
import 'package:dawis/src/features/laporan/services/data_transfer_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

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
          context.push('/form-pengurus');
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
        trailing: Chip(
          label: Text(
            user.role,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: chipColor,
          padding: EdgeInsets.zero,
        ),
        onTap: () {
          context.push('/form-pengurus/${user.id}');
        },
      ),
    );
  }
}
