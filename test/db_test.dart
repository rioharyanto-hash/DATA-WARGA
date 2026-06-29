import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dawis/src/features/report/data/repositories/report_repository.dart';

void main() {
  test('Check getFormDataManual', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final repo = ReportRepository();
    final data = await repo.getFormDataManual(
      'BUAH GOWOK 010.001.001',
      '001',
      '010',
    );
    print('Total rows returned: ${(data['rows'] as List).length}');
  });
}
