import 'dart:io';

void main() {
  final file = File(
    'e:\\Project\\DAWIS\\lib\\src\\features\\dashboard\\data\\repositories\\dashboard_repository_impl.dart',
  );
  var content = file.readAsStringSync();

  // 1. Update SELECT query for bangunan
  content = content.replaceAll(
    "from('bangunan')\\n        .select('id, rw, rt, kelompok_dawis, nama_bangunan, alamat_lengkap');",
    "from('bangunan')\\n        .select('id, rw, rt, kelompok_dawis, nama_bangunan, alamat_lengkap, nomor_urut_bangunan');",
  );

  // 2. Add properties to Jumlah Bangunan mapping
  content = content.replaceAll(
    "'rw': b['rw'] ?? '-',\\n              'rt': b['rt'] ?? '-',",
    "'rw': b['rw'] ?? '-',\\n              'rt': b['rt'] ?? '-',\\n              'nomor_urut_bangunan': b['nomor_urut_bangunan'] ?? '-',\\n              'nama_krt': '-',\\n              'no_kk': '-',",
  );

  // 3. Add properties to Jumlah KK mapping
  content = content.replaceAll(
    "'rt': b != null ? b['rt'] : '-',\\n          'rw': b != null ? b['rw'] : '-',",
    "'rt': b != null ? b['rt'] : '-',\\n          'rw': b != null ? b['rw'] : '-',\\n          'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',",
  );

  // 4. Add properties to Mutasi mapping
  content = content.replaceAll(
    "'rt': b != null ? b['rt'] : '-',\\n              'rw': b != null ? b['rw'] : '-',",
    "'rt': b != null ? b['rt'] : '-',\\n              'rw': b != null ? b['rw'] : '-',\\n              'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',\\n              'nama_krt': '-',\\n              'no_kk': '-',",
  );

  // 5. Add properties to Individu mapping
  content = content.replaceAll(
    "'rt': b != null ? b['rt'] : '-',\\n            'rw': b != null ? b['rw'] : '-',",
    "'rt': b != null ? b['rt'] : '-',\\n            'rw': b != null ? b['rw'] : '-',\\n            'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',\\n            'nama_krt': krt != null ? krt['nama_krt'] : '-',\\n            'no_kk': k != null ? k['no_kk'] : '-',",
  );

  // 6. Common Sorting function
  String sortFunction = '''
      final noA = int.tryParse(a['nomor_urut_bangunan']?.toString() ?? '') ?? 99999;
      final noB = int.tryParse(b['nomor_urut_bangunan']?.toString() ?? '') ?? 99999;
      final noCompare = noA.compareTo(noB);
      if (noCompare != 0) return noCompare;

      final krtA = a['nama_krt']?.toString().toLowerCase() ?? '';
      final krtB = b['nama_krt']?.toString().toLowerCase() ?? '';
      final krtCompare = krtA.compareTo(krtB);
      if (krtCompare != 0) return krtCompare;

      final kkA = a['no_kk']?.toString().toLowerCase() ?? '';
      final kkB = b['no_kk']?.toString().toLowerCase() ?? '';
      final kkCompare = kkA.compareTo(kkB);
      if (kkCompare != 0) return kkCompare;
''';

  // Jumlah Bangunan Sort
  content = content.replaceAll(
    '''
      list.sort((a, b) {
        final rtA = int.tryParse(a['rt']?.toString() ?? '') ?? 999;
        final rtB = int.tryParse(b['rt']?.toString() ?? '') ?? 999;
        final rtCompare = rtA.compareTo(rtB);
        if (rtCompare != 0) return rtCompare;

        final nameA = a['nama_bangunan']?.toString().toLowerCase() ?? '';
        final nameB = b['nama_bangunan']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });
''',
    '''
      list.sort((a, b) {
$sortFunction
        final nameA = a['nama_bangunan']?.toString().toLowerCase() ?? '';
        final nameB = b['nama_bangunan']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });
''',
  );

  // Jumlah KK Sort
  content = content.replaceAll(
    '''
      list.sort((a, b) {
        final rtA = int.tryParse(a['rt']?.toString() ?? '') ?? 999;
        final rtB = int.tryParse(b['rt']?.toString() ?? '') ?? 999;
        final rtCompare = rtA.compareTo(rtB);
        if (rtCompare != 0) return rtCompare;

        final kkA = a['no_kk']?.toString() ?? '';
        final kkB = b['no_kk']?.toString() ?? '';
        final kkCompare = kkA.compareTo(kkB);
        if (kkCompare != 0) return kkCompare;

        final nameA = a['nama_krt']?.toString().toLowerCase() ?? '';
        final nameB = b['nama_krt']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });
''',
    '''
      list.sort((a, b) {
$sortFunction
        return 0;
      });
''',
  );

  // Mutasi Sort (doesn't have explicit sort now, we can leave it as is or add sort)
  // Wait, mutasi is not sorted explicitly. It just uses DB order.

  // Individu Sort
  content = content.replaceAll(
    '''
    result.sort((a, b) {
      final rtA = int.tryParse(a['rt']?.toString() ?? '') ?? 999;
      final rtB = int.tryParse(b['rt']?.toString() ?? '') ?? 999;
      final rtCompare = rtA.compareTo(rtB);
      if (rtCompare != 0) return rtCompare;

      final nameA = a['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nameB = b['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nameCompare = nameA.compareTo(nameB);
      if (nameCompare != 0) return nameCompare;
''',
    '''
    result.sort((a, b) {
$sortFunction
      final nameA = a['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nameB = b['nama_lengkap']?.toString().toLowerCase() ?? '';
      final nameCompare = nameA.compareTo(nameB);
      if (nameCompare != 0) return nameCompare;
''',
  );

  file.writeAsStringSync(content);
  print('Done applying sorting fixes!');
}
