import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/database/local_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  var db = await LocalDbHelper.database;

  try {
    var b = await db.query('bangunan');
    debugPrint('Bangunan count: ${b.length}');
  } catch (e) {
    debugPrint('Error: $e');
  }
}
