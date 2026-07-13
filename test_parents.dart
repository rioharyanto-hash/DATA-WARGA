import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final dbPath = await databaseFactory.getDatabasesPath();
  final path = join(dbPath, 'dasawisma.db');
  
  if (!File(path).existsSync()) {
    print('DB not found at $path');
    return;
  }
  
  final db = await databaseFactory.openDatabase(path);
  
  // Find M. ABDUL RIZAL
  final res = await db.query('individu', where: 'nama_lengkap LIKE ?', whereArgs: ['%RIZAL%']);
  if (res.isEmpty) {
    print('RIZAL not found');
    return;
  }
  
  final rizal = res.first;
  print('Rizal found: ${rizal['id_keluarga']}, hubungan: ${rizal['hubungan_keluarga']}');
  
  final idKeluarga = rizal['id_keluarga'];
  
  final ayahMaps = await db.query(
    'individu',
    where: 'id_keluarga = ? AND (hubungan_keluarga = ? OR hubungan_keluarga = ?) AND jenis_kelamin = ?',
    whereArgs: [idKeluarga, 'Kepala Keluarga', 'KK', 'Laki-laki'],
    limit: 1,
  );
  
  print('Ayah maps: $ayahMaps');
  
  final ibuMaps = await db.query(
    'individu',
    where: 'id_keluarga = ? AND (hubungan_keluarga = ? OR ((hubungan_keluarga = ? OR hubungan_keluarga = ?) AND jenis_kelamin = ?))',
    whereArgs: [idKeluarga, 'Istri', 'Kepala Keluarga', 'KK', 'Perempuan'],
    limit: 1,
  );
  
  print('Ibu maps: $ibuMaps');
  
  // Also check if status_dgn_krt is what they use?
  final krtMaps = await db.query(
    'individu',
    where: 'id_keluarga = ?',
    whereArgs: [idKeluarga],
  );
  print('All family members:');
  for (var m in krtMaps) {
    print(' - ${m['nama_lengkap']}, jk: ${m['jenis_kelamin']}, hub: ${m['hubungan_keluarga']}, krt: ${m['status_dgn_krt']}');
  }
}
