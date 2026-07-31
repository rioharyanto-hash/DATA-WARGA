import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/local_db_helper.dart';

import '../../src/features/settings/data/models/app_user_model.dart';
import '../../src/features/pendataan/data/models/bangunan_model.dart';
import '../../src/features/pendataan/data/models/krt_model.dart';
import '../../src/features/pendataan/data/models/keluarga_model.dart';
import '../../src/features/pendataan/data/models/individu_model.dart';
import '../../src/features/pendataan/data/models/mutasi_model.dart';

class SyncService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> _fetchAll(String table) async {
    List<Map<String, dynamic>> allData = [];
    int offset = 0;
    const int limit = 1000;
    while (true) {
      final res = await _supabase
          .from(table)
          .select()
          .range(offset, offset + limit - 1);
      allData.addAll(List<Map<String, dynamic>>.from(res));
      if (res.length < limit) {
        break;
      }
      offset += limit;
    }
    return allData;
  }

  static Future<void> syncSupabaseToLocal() async {
    try {
      debugPrint('[SyncService] Starting sync from Supabase to Local DB...');
      final db = await LocalDbHelper.database;

      // Fetch all data from Supabase using pagination to bypass 1000 rows limit
      final usersRes = await _fetchAll('app_user');
      final bangunanRes = await _fetchAll('bangunan');
      final krtRes = await _fetchAll('krt');
      final keluargaRes = await _fetchAll('keluarga');
      final individuRes = await _fetchAll('individu');
      final mutasiRes = await _fetchAll('mutasi');

      // Convert to models and then to Json to ensure schema safety
      final users = usersRes
          .map((e) => AppUserModel.fromJson(e).toJson())
          .toList();
      final bangunan = bangunanRes
          .map((e) => BangunanModel.fromJson(e).toJson())
          .toList();
      final krt = krtRes.map((e) => KrtModel.fromJson(e).toJson()).toList();
      final keluarga = keluargaRes
          .map((e) => KeluargaModel.fromJson(e).toJson())
          .toList();
      final individu = individuRes
          .map((e) => IndividuModel.fromJson(e).toJson())
          .toList();
      final mutasi = mutasiRes
          .map((e) => MutasiModel.fromJson(e).toJson())
          .toList();

      await db.transaction((txn) async {
        // Clear existing tables in correct order to avoid FK constraint errors
        await txn.delete('mutasi');
        await txn.delete('individu');
        await txn.delete('keluarga');
        await txn.delete('krt');
        await txn.delete('bangunan');
        await txn.delete('app_user');

        // Insert app_user
        for (var row in users) {
          await txn.insert(
            'app_user',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Insert bangunan
        for (var row in bangunan) {
          await txn.insert(
            'bangunan',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Insert krt
        for (var row in krt) {
          await txn.insert(
            'krt',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Insert keluarga
        for (var row in keluarga) {
          await txn.insert(
            'keluarga',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Insert individu
        for (var row in individu) {
          await txn.insert(
            'individu',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Insert mutasi
        for (var row in mutasi) {
          await txn.insert(
            'mutasi',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      debugPrint('[SyncService] Sync completed successfully.');
    } catch (e) {
      debugPrint('[SyncService] Error during sync: $e');
    }
  }

  static Future<void> syncLocalUnsyncedToSupabase() async {
    try {
      debugPrint('[SyncService] Starting push of unsynced data to Supabase...');
      final db = await LocalDbHelper.database;

      final tables = ['bangunan', 'krt', 'keluarga', 'individu', 'mutasi'];

      for (final table in tables) {
        final unsyncedRows = await db.query(
          table,
          where: 'is_synced = ?',
          whereArgs: [0],
        );
        for (var row in unsyncedRows) {
          try {
            final payload = Map<String, dynamic>.from(row);
            payload.remove('is_synced');
            await _supabase.from(table).upsert(payload);
            await db.update(
              table,
              {'is_synced': 1},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          } catch (e) {
            debugPrint(
              '[SyncService] Failed to push row ${row['id']} from $table: $e',
            );
          }
        }
      }

      debugPrint('[SyncService] Push completed successfully.');
    } catch (e) {
      debugPrint('[SyncService] Error during push: $e');
    }
  }
}
