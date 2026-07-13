import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final path = r'C:\Users\user\Documents\dasawisma.db';
  print('Path: \$path');
  
  final db = await databaseFactory.openDatabase(path);
  final res = await db.query('mutasi');
  print('Total Mutasi: \${res.length}');
  for (var r in res) {
    print("\${r['nama_orang']} - \${r['jenis_mutasi']} - \${r['tanggal_mutasi']} - \${r['keterangan']} - \${r['sebab_kematian']} - \${r['id_bangunan']}");
  }
}
