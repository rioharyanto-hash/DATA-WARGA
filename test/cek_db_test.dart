import 'package:flutter_test/flutter_test.dart';
import 'package:dawis/src/core/db/local_db_helper.dart';

void main() {
  test('Check database', () async {
    final db = await LocalDbHelper.database;
    final res = await db.query('app_user', where: "kelompok_dawis LIKE '%BUAH GOWOK 010.001%'");
    for(var r in res) {
      print('USER: ${r['kelompok_dawis']}');
    }
  });
}
