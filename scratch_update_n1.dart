import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/report/data/repositories/report_repository.dart',
  );
  var content = file.readAsStringSync();

  final helperMethod = '''
  Future<Map<String, dynamic>> _fetchInMemoryData(Database db, Set<String> bangunanIds) async {
    final Map<String, List<Map<String, dynamic>>> krtByBangunan = {};
    final Map<String, List<Map<String, dynamic>>> kkByKrt = {};
    final Map<String, List<Map<String, dynamic>>> individuByKeluarga = {};

    if (bangunanIds.isEmpty) return {'krt': krtByBangunan, 'kk': kkByKrt, 'individu': individuByKeluarga};

    final idList = bangunanIds.map((e) => "'\$e'").join(',');

    final allKrt = await db.rawQuery('SELECT * FROM krt WHERE id_bangunan IN (\$idList)');
    final krtIds = <String>{};
    for (var krt in allKrt) {
      final idB = krt['id_bangunan'].toString();
      krtByBangunan.putIfAbsent(idB, () => []).add(krt);
      krtIds.add(krt['id'].toString());
    }

    if (krtIds.isEmpty) return {'krt': krtByBangunan, 'kk': kkByKrt, 'individu': individuByKeluarga};
    
    final kkIdList = krtIds.map((e) => "'\$e'").join(',');
    final allKk = await db.rawQuery('SELECT * FROM keluarga WHERE id_krt IN (\$kkIdList)');
    final kelIds = <String>{};
    for (var kk in allKk) {
      final idK = kk['id_krt'].toString();
      kkByKrt.putIfAbsent(idK, () => []).add(kk);
      kelIds.add(kk['id'].toString());
    }

    if (kelIds.isEmpty) return {'krt': krtByBangunan, 'kk': kkByKrt, 'individu': individuByKeluarga};

    final indIdList = kelIds.map((e) => "'\$e'").join(',');
    final allInd = await db.rawQuery(\'''
      SELECT * FROM individu 
      WHERE id_keluarga IN (\$indIdList) 
      AND id NOT IN (
        SELECT id_individu_asal FROM mutasi 
        WHERE id_individu_asal IS NOT NULL 
        AND jenis_mutasi IN ('Meninggal', 'Pindah')
      )
    \''');

    for (var ind in allInd) {
      final idKel = ind['id_keluarga'].toString();
      individuByKeluarga.putIfAbsent(idKel, () => []).add(ind);
    }
    
    return {
      'krt': krtByBangunan,
      'kk': kkByKrt,
      'individu': individuByKeluarga,
    };
  }
''';

  if (!content.contains('_fetchInMemoryData')) {
    content = content.replaceFirst(
      'Future<List<Map<String, dynamic>>> _getIndividuAktif(',
      '$helperMethod\n  Future<List<Map<String, dynamic>>> _getIndividuAktif(',
    );
  }

  // Find all loops starting with `for (var b in `
  final regexOuter = RegExp(
    r'for\s*\(\s*var\s+b\s+in\s+([a-zA-Z0-9_]+)\s*\)\s*\{',
  );

  // Actually, replacing loops perfectly in AST using regex is hard.
  // I will write a simpler replacement targeting the exact code.

  content = content.replaceAll(
    '''    for (var b in bangunanListForKelompok) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );''',
    '''    
    final bIds = bangunanListForKelompok.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk = memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bangunanListForKelompok) {
      final krtList = krtByB[b['id'].toString()] ?? [];''',
  );

  content = content.replaceAll(
    '''    for (var b in bList) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );''',
    '''    
    final bIds = bList.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk = memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bList) {
      final krtList = krtByB[b['id'].toString()] ?? [];''',
  );

  content = content.replaceAll(
    '''    for (var b in bangunanList) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );''',
    '''    
    final bIds = bangunanList.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk = memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bangunanList) {
      final krtList = krtByB[b['id'].toString()] ?? [];''',
  );

  content = content.replaceAll(
    '''    for (var b in bangunanListForRt) {
      final krtList = await db.query(
        'krt',
        where: 'id_bangunan = ?',
        whereArgs: [b['id']],
      );''',
    '''    
    final bIds = bangunanListForRt.map((e) => e['id'].toString()).toSet();
    final memoData = await _fetchInMemoryData(db, bIds);
    final krtByB = memoData['krt'] as Map<String, List<Map<String, dynamic>>>;
    final kkByKrt = memoData['kk'] as Map<String, List<Map<String, dynamic>>>;
    final indByKk = memoData['individu'] as Map<String, List<Map<String, dynamic>>>;

    for (var b in bangunanListForRt) {
      final krtList = krtByB[b['id'].toString()] ?? [];''',
  );

  // Replace kkList queries
  content = content.replaceAll(
    '''        final kkList = await db.query(
          'keluarga',
          where: 'id_krt = ?',
          whereArgs: [krt['id']],
        );''',
    '''        final kkList = kkByKrt[krt['id'].toString()] ?? [];''',
  );

  // Replace individuList queries
  content = content.replaceAll(
    '''          final individuList = await _getIndividuAktif(db, kk['id']);''',
    '''          final individuList = indByKk[kk['id'].toString()] ?? [];''',
  );

  file.writeAsStringSync(content);
  print('Updated report_repository.dart');
}
