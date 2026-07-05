import 'dart:io';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import 'package:dawis/core/database/local_db_helper.dart';

class DataTransferService {
  Future<List<int>> generateImportTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Template Import Warga'];

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Template Import Warga') {
      excel.delete(defaultSheet);
    }

    sheet.appendRow([
      TextCellValue('NIK'),
      TextCellValue('Nama Lengkap'),
      TextCellValue('Hubungan Keluarga'),
      TextCellValue('Jenis Kelamin (L/P)'),
      TextCellValue('Tempat Lahir'),
      TextCellValue('Tanggal Lahir (YYYY-MM-DD)'),
      TextCellValue('Status Perkawinan'),
      TextCellValue('Pendidikan Terakhir'),
      TextCellValue('Pekerjaan'),
    ]);

    // Sample data row
    sheet.appendRow([
      TextCellValue('330101...'),
      TextCellValue('Fulan'),
      TextCellValue('KEPALA KELUARGA'),
      TextCellValue('L'),
      TextCellValue('Jakarta'),
      TextCellValue('1990-01-01'),
      TextCellValue('KAWIN'),
      TextCellValue('SMA'),
      TextCellValue('WIRASWASTA'),
    ]);

    return excel.encode() ?? [];
  }

  Future<void> importDataWarga(String filePath, String idKeluarga) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final db = await LocalDbHelper.database;
    const uuid = Uuid();

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      bool isHeader = true;
      for (final row in sheet.rows) {
        if (isHeader) {
          isHeader = false;
          continue;
        }

        if (row.isEmpty || row[0] == null) continue;

        final nik = row[0]?.value?.toString() ?? '';
        final namaLengkap = row[1]?.value?.toString() ?? '';
        final hubunganKeluarga =
            row[2]?.value?.toString() ?? 'ANGGOTA KELUARGA';
        final jenisKelamin = row[3]?.value?.toString() ?? 'L';
        final tempatLahir = row[4]?.value?.toString() ?? '';
        final tanggalLahir = row[5]?.value?.toString() ?? '';
        final statusPerkawinan = row[6]?.value?.toString() ?? '';
        final pendidikanTerakhir = row[7]?.value?.toString() ?? '';
        final pekerjaan = row[8]?.value?.toString() ?? '';

        await db.insert('individu', {
          'id': uuid.v4(),
          'id_keluarga': idKeluarga,
          'nama_lengkap': namaLengkap,
          'nik': nik,
          'hubungan_keluarga': hubunganKeluarga,
          'jenis_kelamin': jenisKelamin,
          'tempat_lahir': tempatLahir,
          'tanggal_lahir': tanggalLahir,
          'status_perkawinan': statusPerkawinan,
          'pendidikan_terakhir': pendidikanTerakhir,
          'pekerjaan': pekerjaan,
          'is_synced': 0,
        });
      }
    }
  }

  Future<List<int>> generateImportTemplateKader() async {
    final excel = Excel.createExcel();
    final sheet = excel['Template Import Kader'];

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Template Import Kader') {
      excel.delete(defaultSheet);
    }

    sheet.appendRow([
      TextCellValue('No'), // 0
      TextCellValue('Kelompok Dawis'), // 1
      TextCellValue('Nama Lengkap'), // 2
      TextCellValue('ID Kader'), // 3
      TextCellValue('Password (default: 123456)'), // 4
      TextCellValue('NIK'), // 5
      TextCellValue('Tempat Lahir'), // 6
      TextCellValue('Tanggal Lahir (YYYY-MM-DD)'), // 7
      TextCellValue('Pendidikan Terakhir'), // 8
      TextCellValue('Alamat'), // 9
      TextCellValue('RT'), // 10
      TextCellValue('RW'), // 11
      TextCellValue('Kelurahan/Desa'), // 12
      TextCellValue('Kecamatan'), // 13
      TextCellValue('Propinsi'), // 14
      TextCellValue('Kode Pos'), // 15
      TextCellValue('Alamat Sesuai KTP?'), // 16
      TextCellValue('Alamat KTP'), // 17
      TextCellValue('No HP'), // 18
      TextCellValue('Email'), // 19
      TextCellValue('No Rekening Bank'), // 20
      TextCellValue('NPWP'), // 21
    ]);

    // Sample data row
    sheet.appendRow([
      TextCellValue('1'),
      TextCellValue('MELATI'),
      TextCellValue('Siti Aminah'),
      TextCellValue('KDR-001'),
      TextCellValue('123456'),
      TextCellValue('330101...'),
      TextCellValue('Jakarta'),
      TextCellValue('1990-01-01'),
      TextCellValue('SMA'),
      TextCellValue('Jl. Merdeka No 1'),
      TextCellValue('01'),
      TextCellValue('02'),
      TextCellValue('Suka Maju'),
      TextCellValue('Cilacap'),
      TextCellValue('Jawa Tengah'),
      TextCellValue('53211'),
      TextCellValue('Ya'),
      TextCellValue('Jl. Merdeka No 1'),
      TextCellValue('081234567890'),
      TextCellValue('siti@email.com'),
      TextCellValue('123456789 (BRI)'),
      TextCellValue('12.345.678.9-000.000'),
    ]);

    return excel.encode() ?? [];
  }

  Future<void> importDataKader(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final db = await LocalDbHelper.database;
    const uuid = Uuid();

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      bool isHeader = true;
      for (final row in sheet.rows) {
        if (isHeader) {
          isHeader = false;
          continue;
        }

        if (row.isEmpty || row.length <= 1 || row[1] == null) continue;

        String getString(int index) {
          if (index >= row.length) return '';
          return row[index]?.value?.toString().trim() ?? '';
        }

        final kelompokDawis = getString(1);
        final nama = getString(2);
        final idKader = getString(3);

        if (idKader.isEmpty) continue; // Skip if no ID Kader

        final nik = getString(5);
        final tempatLahir = getString(6);

        String tanggalLahir = getString(7);
        if (tanggalLahir.isNotEmpty && tanggalLahir.contains('T')) {
          tanggalLahir = tanggalLahir.split('T')[0];
        } else if (tanggalLahir.isNotEmpty && tanggalLahir.contains(' ')) {
          tanggalLahir = tanggalLahir.split(' ')[0];
        }

        final pendidikanTerakhir = getString(8);
        final alamat = getString(9);
        final rt = getString(10);
        final rw = getString(11);
        final kelurahan = getString(12);
        final kecamatan = getString(13);
        final propinsi = getString(14);
        final kodePos = getString(15);
        final alamatKtp = getString(17);
        final noHp = getString(18);
        final email = getString(19);
        final noRekeningBank = getString(20);
        final npwp = getString(21);

        final existing = await db.query(
          'app_user',
          where: 'id_kader = ?',
          whereArgs: [idKader],
        );

        final mapData = {
          'nama': nama,
          'kelompok_dawis': kelompokDawis,
          'role': 'KADER',
          'rt': rt,
          'rw': rw,
          'nik': nik,
          'tempat_lahir': tempatLahir,
          'tanggal_lahir': tanggalLahir,
          'pendidikan_terakhir': pendidikanTerakhir,
          'alamat': alamat,
          'kelurahan': kelurahan,
          'kecamatan': kecamatan,
          'propinsi': propinsi,
          'kode_pos': kodePos,
          'alamat_ktp': alamatKtp,
          'no_hp': noHp,
          'email': email,
          'no_rekening_bank': noRekeningBank,
          'npwp': npwp,
        };

        if (existing.isNotEmpty) {
          await db.update(
            'app_user',
            mapData,
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
        } else {
          mapData['id'] = uuid.v4();
          mapData['id_kader'] = idKader;
          mapData['password'] =
              '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; // SHA256 for '123456'
          await db.insert('app_user', mapData);
        }
      }
    }
  }
}
