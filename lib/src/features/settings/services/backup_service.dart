import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BackupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Daftar tabel sesuai urutan relasi (Parent -> Child)
  // Ini penting agar saat restore (upsert), tidak terjadi error Foreign Key constraint.
  final List<String> _tables = [
    'app_user',
    'bangunan',
    'krt',
    'keluarga',
    'individu',
    'mutasi',
    'surat_pengantar',
  ];

  /// Mengambil seluruh data dari tabel dengan mekanisme pagination
  Future<List<Map<String, dynamic>>> _fetchAllFromSupabase(String table) async {
    List<Map<String, dynamic>> allData = [];
    int offset = 0;
    const int limit = 1000;
    while (true) {
      final res = await _supabase
          .from(table)
          .select()
          .range(offset, offset + limit - 1);

      allData.addAll(res);
      if (res.length < limit) break;
      offset += limit;
    }
    return allData;
  }

  /// Mengekspor seluruh database ke format JSON terstruktur
  Future<String> exportDatabaseToJson() async {
    Map<String, dynamic> backupData = {};
    backupData['timestamp'] = DateTime.now().toIso8601String();
    backupData['version'] = '1.0';
    backupData['data'] = {};

    for (String table in _tables) {
      try {
        final tableData = await _fetchAllFromSupabase(table);
        backupData['data'][table] = tableData;
      } catch (e) {
        debugPrint('Error backing up table $table: $e');
        // Tetap lanjut ke tabel berikutnya
        backupData['data'][table] = [];
      }
    }

    return jsonEncode(backupData);
  }

  /// Memulihkan data dari JSON ke Supabase
  Future<void> importDatabaseFromJson(String jsonString) async {
    final Map<String, dynamic> backupData = jsonDecode(jsonString);
    final Map<String, dynamic>? data = backupData['data'];

    if (data == null) throw Exception('Format file backup tidak valid');

    // Proses import harus sesuai urutan list _tables untuk menjaga Foreign Key
    for (String table in _tables) {
      if (data.containsKey(table)) {
        final List<dynamic> tableData = data[table];
        if (tableData.isNotEmpty) {
          // Melakukan upsert dalam bentuk batch (chunking per 500 baris)
          // untuk mencegah error limit dari Supabase API
          final List<Map<String, dynamic>> typedData =
              List<Map<String, dynamic>>.from(tableData);
          await _upsertInChunks(table, typedData);
        }
      }
    }
  }

  Future<void> _upsertInChunks(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    const int chunkSize = 500;
    for (int i = 0; i < data.length; i += chunkSize) {
      final int end = (i + chunkSize < data.length)
          ? i + chunkSize
          : data.length;
      final chunk = data.sublist(i, end);
      try {
        await _supabase.from(table).upsert(chunk);
      } catch (e) {
        debugPrint('Error upserting chunk to $table: $e');
        throw Exception('Gagal memulihkan tabel $table: $e');
      }
    }
  }
}
