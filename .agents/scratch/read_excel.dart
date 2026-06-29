import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

void main() {
  var file = "DATABASE DAWIS.xlsx";
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    debugPrint('=== SHEET: $table ===');
    var maxRows = excel.tables[table]!.maxRows;
    var maxCols = excel.tables[table]!.maxColumns;
    debugPrint('Max Rows: $maxRows');
    debugPrint('Max Cols: $maxCols');

    // Print first 5 rows
    for (int i = 0; i < (maxRows > 5 ? 5 : maxRows); i++) {
      var row = excel.tables[table]!.row(i);
      var rowData = row.map((e) => e?.value.toString()).toList();
      debugPrint('Row $i: $rowData');
    }
    debugPrint('');
  }
}
