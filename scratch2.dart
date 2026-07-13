import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'lib/core/database/local_db_helper.dart';

void main() async {
  sqfliteFfiInit();
  final db = await LocalDbHelper.database;
  
  print('==== MUTASI WITH YULIANINGSIH ====');
  final res = await db.rawQuery('SELECT * FROM mutasi WHERE nama_orang LIKE "%YULIANINGSIH%"');
  for (var r in res) {
    print(r);
  }
}
