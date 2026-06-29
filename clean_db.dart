import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  var dbPath =
      'C:\\Users\\user\\AppData\\Local\\dawis\\dawis.db'; // We need the correct path, let's find out.
}
