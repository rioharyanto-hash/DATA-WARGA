import 'dart:io'; 
import 'package:sqflite/sqflite.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; 

void main() async { 
  sqfliteFfiInit(); 
  databaseFactory = databaseFactoryFfi; 
  final db = await openDatabase('app_database.db'); 
  print(await db.rawQuery('SELECT rt, rw, kelompok_dawis FROM bangunan LIMIT 5')); 
  print(await db.rawQuery('SELECT rt, rw, kelompok_dawis FROM app_users WHERE role="KADER" LIMIT 5')); 
  exit(0); 
}
