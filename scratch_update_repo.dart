import 'dart:io';

void main() {
  final file = File(
    'e:\\Project\\DAWIS\\lib\\src\\features\\dashboard\\data\\repositories\\dashboard_repository_impl.dart',
  );
  var content = file.readAsStringSync();

  String target = '''    if (category == 'Jumlah KK') {
      final list = filteredKeluarga.map((k) {
        final krt = krtMap[k['id_krt']];
        final b = krt != null ? bMap[krt['id_bangunan']] : null;
        return {
          'no_kk': k['no_kk'] ?? '-',
          'nama_krt': krt != null ? krt['nama_krt'] : '-',
          'rt': b != null ? b['rt'] : '-',
          'rw': b != null ? b['rw'] : '-',
          'alamat': b != null
              ? '\${b['alamat_lengkap'] ?? ''} RT \${b['rt'] ?? '-'}/\${b['rw'] ?? '-'}'
              : '-',
        };
      }).toList();''';

  String replacement = '''    if (category == 'Jumlah KK') {
      final allIndividu = await _supabase.from('individu').select('id_keluarga, nama_lengkap, hubungan_keluarga, status_dgn_krt');
      final filteredIndividu = allIndividu
          .where((i) => kelIds.contains(i['id_keluarga']))
          .toList();

      final list = filteredKeluarga.map((k) {
        final krt = krtMap[k['id_krt']];
        final b = krt != null ? bMap[krt['id_bangunan']] : null;
        
        var namaKk = krt != null ? krt['nama_krt'] : '-';
        try {
          final ind = filteredIndividu.firstWhere((i) {
            if (i['id_keluarga'] != k['id']) return false;
            final hub = i['hubungan_keluarga']?.toString().toUpperCase() ?? '';
            final stat = i['status_dgn_krt']?.toString().toUpperCase() ?? '';
            return hub == 'KK' || hub == 'KEPALA KELUARGA' || hub == 'KEPALA RUMAH TANGGA' ||
                   stat == 'KK' || stat == 'KEPALA KELUARGA' || stat == 'KEPALA RUMAH TANGGA';
          });
          if (ind['nama_lengkap'] != null && ind['nama_lengkap'].toString().isNotEmpty) {
            namaKk = ind['nama_lengkap'];
          }
        } catch (_) {}

        return {
          'no_kk': k['no_kk'] ?? '-',
          'nama_krt': krt != null ? krt['nama_krt'] : '-',
          'nama_kk': namaKk,
          'rt': b != null ? b['rt'] : '-',
          'rw': b != null ? b['rw'] : '-',
          'nomor_urut_bangunan': b != null ? b['nomor_urut_bangunan'] : '-',
          'alamat': b != null
              ? '\${b['alamat_lengkap'] ?? ''} RT \${b['rt'] ?? '-'}/\${b['rw'] ?? '-'}'
              : '-',
        };
      }).toList();''';

  content = content.replaceAll(target, replacement);
  file.writeAsStringSync(content);
  print('Repository updated!');
}
