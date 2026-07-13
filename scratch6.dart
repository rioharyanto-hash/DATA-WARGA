import 'package:dawis/core/database/local_db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  // Using LocalDbHelper to trigger migration
  final db = await LocalDbHelper.database;
  final res = await db.query('mutasi');
  print('Total Mutasi: \${res.length}');
  for (var r in res) {
    if (r['jenis_mutasi'] == 'Meninggal') {
      print("\${r['nama_orang']} - \${r['keterangan']} - \${r['sebab_kematian']}");
    }
  }
}
