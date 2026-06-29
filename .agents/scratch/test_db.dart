import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:path/path.dart";

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  String dbPath = await getDatabasesPath();
  String path = join(dbPath, "dasawisma.db");
  print("DB Path: $path");

  var db = await databaseFactory.openDatabase(path);

  var res = await db.rawQuery("PRAGMA table_info(bangunan)");
  print("SCHEMA BANGUNAN:");
  for (var r in res) {
    print(r);
  }

  var res2 = await db.query("bangunan");
  print("DATA BANGUNAN:");
  for (var r in res2) {
    print(r);
  }
}
