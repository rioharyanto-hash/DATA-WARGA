import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:path/path.dart";

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  String dbPath = await getDatabasesPath();
  String path = join(dbPath, "dasawisma.db");
  var db = await databaseFactory.openDatabase(path);

  int count = await db.update(
    'bangunan',
    {'nop_pbb': 'TEST_NOP', 'luas_bangunan': 100.0, 'luas_tanah': 200.0},
    where: 'nama_bangunan LIKE ?',
    whereArgs: ['%DEDE%'],
  );
  print("Updated $count rows.");

  var res = await db.query(
    'bangunan',
    where: 'nama_bangunan LIKE ?',
    whereArgs: ['%DEDE%'],
  );
  for (var r in res) {
    print(r);
  }
}
