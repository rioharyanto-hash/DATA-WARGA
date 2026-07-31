import 'dart:io';

void main() {
  final file = File(
    'lib/src/features/dashboard/presentation/widgets/dashboard_screen.dart',
  );
  var content = file.readAsStringSync();

  // 1. Total Penduduk
  content = content.replaceFirst(
    '''      ['Alamat', 'Nama Lengkap', 'Umur', 'NIK', 'L/P', 'Tgl Lahir'],
      (e) => [
        (e['alamat'] ?? '').toString(),
        (e['nama_lengkap'] ?? '').toString(),
        (e['umur'] ?? '').toString(),
        (e['nik'] ?? '').toString(),
        (e['jenis_kelamin'] ?? '').toString(),
        (e['tanggal_lahir'] ?? '').toString(),
      ],''',
    '''      ['Nama Lengkap', 'Alamat', 'Umur', 'NIK', 'L/P', 'Tgl Lahir'],
      (e) => [
        (e['nama_lengkap'] ?? '').toString(),
        (e['alamat'] ?? '').toString(),
        (e['umur'] ?? '').toString(),
        (e['nik'] ?? '').toString(),
        (e['jenis_kelamin'] ?? '').toString(),
        (e['tanggal_lahir'] ?? '').toString(),
      ],''',
  );

  // 2. PUS
  content = content.replaceFirst(
    '''                                          [
                                            'Nama Lengkap',
                                            'Umur',
                                            'NIK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'Alamat',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['umur'] ?? '').toString(),
                                            (e['nik'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['alamat'] ?? '').toString(),
                                          ],''',
    '''                                          [
                                            'Nama Lengkap',
                                            'Umur',
                                            'Nomor KK',
                                            'L/P',
                                            'Tgl Lahir',
                                            'Alamat',
                                          ],
                                          (e) => [
                                            (e['nama_lengkap'] ?? '')
                                                .toString(),
                                            (e['umur'] ?? '').toString(),
                                            (e['no_kk'] ?? '').toString(),
                                            (e['jenis_kelamin'] ?? '')
                                                .toString(),
                                            (e['tanggal_lahir'] ?? '')
                                                .toString(),
                                            (e['alamat'] ?? '').toString(),
                                          ],''',
  );

  // 3. Replace all Mutasi occurences
  content = content.replaceAll(
    '''                                              [
                                                'Jenis Mutasi',
                                                'Keterangan',
                                                'Alamat',
                                              ],
                                              (e) => [
                                                (e['jenis_mutasi'] ?? '')
                                                    .toString(),
                                                (e['keterangan_mutasi'] ?? '')
                                                    .toString(),
                                                (e['alamat'] ?? '').toString(),
                                              ],''',
    '''                                              [
                                                'Nama Lengkap',
                                                'Jenis Mutasi',
                                                'Keterangan',
                                                'Alamat',
                                              ],
                                              (e) => [
                                                (e['nama_orang'] ?? '')
                                                    .toString(),
                                                (e['jenis_mutasi'] ?? '')
                                                    .toString(),
                                                (e['keterangan_mutasi'] ?? '')
                                                    .toString(),
                                                (e['alamat'] ?? '').toString(),
                                              ],''',
  );

  // also matching the ones with different indentation if any:
  content = content.replaceAll(
    '''                                          [
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'Alamat',
                                          ],
                                          (e) => [
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['alamat'] ?? '').toString(),
                                          ],''',
    '''                                          [
                                            'Nama Lengkap',
                                            'Jenis Mutasi',
                                            'Keterangan',
                                            'Alamat',
                                          ],
                                          (e) => [
                                            (e['nama_orang'] ?? '')
                                                .toString(),
                                            (e['jenis_mutasi'] ?? '')
                                                .toString(),
                                            (e['keterangan_mutasi'] ?? '')
                                                .toString(),
                                            (e['alamat'] ?? '').toString(),
                                          ],''',
  );

  content = content.replaceAll(
    '''                                                    [
                                                      'Jenis Mutasi',
                                                      'Keterangan',
                                                      'Alamat',
                                                    ],
                                                    (e) => [
                                                      (e['jenis_mutasi'] ?? '')
                                                          .toString(),
                                                      (e['keterangan_mutasi'] ??
                                                              '')
                                                          .toString(),
                                                      (e['alamat'] ?? '')
                                                          .toString(),
                                                    ],''',
    '''                                                    [
                                                      'Nama Lengkap',
                                                      'Jenis Mutasi',
                                                      'Keterangan',
                                                      'Alamat',
                                                    ],
                                                    (e) => [
                                                      (e['nama_orang'] ?? '')
                                                          .toString(),
                                                      (e['jenis_mutasi'] ?? '')
                                                          .toString(),
                                                      (e['keterangan_mutasi'] ??
                                                              '')
                                                          .toString(),
                                                      (e['alamat'] ?? '')
                                                          .toString(),
                                                    ],''',
  );

  file.writeAsStringSync(content);
  print('Updated dashboard_screen.dart');
}
