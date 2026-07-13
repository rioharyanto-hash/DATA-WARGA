import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final dbPath = await databaseFactory.getDatabasesPath();
  final path = join(dbPath, 'dasawisma.db');
  final db = await databaseFactory.openDatabase(path);
  
  final idKeluarga = '9d235876-a29c-4984-9280-70e85b5b77e5';
  
  final ayahMaps = await db.query(
    'individu',
    where: "id_keluarga = ? AND UPPER(REPLACE(hubungan_keluarga, '.', '')) IN ('KK', 'KEPALA KELUARGA') AND UPPER(jenis_kelamin) = 'LAKI-LAKI'",
    whereArgs: [idKeluarga],
    limit: 1,
  );
  
  print('Ayah maps: $ayahMaps');
  
  final ibuMaps = await db.query(
    'individu',
    where: "id_keluarga = ? AND (UPPER(REPLACE(hubungan_keluarga, '.', '')) = 'ISTRI' OR (UPPER(REPLACE(hubungan_keluarga, '.', '')) IN ('KK', 'KEPALA KELUARGA') AND UPPER(jenis_kelamin) = 'PEREMPUAN'))",
    whereArgs: [idKeluarga],
    limit: 1,
  );
  
  print('Ibu maps: $ibuMaps');
}
