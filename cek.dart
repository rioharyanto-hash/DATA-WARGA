import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  sqfliteFfiInit();
  var dbFactory = databaseFactoryFfi;
  var dbPath = await dbFactory.getDatabasesPath();
  var path = join(dbPath, 'dasawisma.db');
  print('DB Path: $path');
  var db = await dbFactory.openDatabase(path);
  
  var res = await db.rawQuery("SELECT DISTINCT kelompok_dawis FROM data_kader WHERE kelompok_dawis LIKE '%BUAH GOWOK 010.001%'");
  print("Data Kelompok in data_kader:");
  for (var r in res) {
    print(r);
  }
  
  var res2 = await db.rawQuery("SELECT DISTINCT kelompok_dawis FROM data_keluarga WHERE kelompok_dawis LIKE '%BUAH GOWOK 010.001%'");
  print("Data Kelompok in data_keluarga:");
  for (var r in res2) {
    print(r);
  }
  
  await db.close();
}
