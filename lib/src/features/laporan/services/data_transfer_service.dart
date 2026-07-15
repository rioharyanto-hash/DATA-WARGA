import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> importDataWarga({
    String? filePath,
    Uint8List? bytes,
    required String idKeluarga,
  }) async {
    Uint8List data;
    if (kIsWeb) {
      if (bytes == null) throw Exception('File bytes cannot be null on Web');
      data = bytes;
    } else {
      if (bytes != null) {
        data = bytes;
      } else if (filePath != null) {
        data = await File(filePath).readAsBytes();
      } else {
        throw Exception('Either filePath or bytes must be provided');
      }
    }
    final excel = Excel.decodeBytes(data);
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

  Future<void> importDataKader({String? filePath, Uint8List? bytes}) async {
    Uint8List data;
    if (kIsWeb) {
      if (bytes == null) throw Exception('File bytes cannot be null on Web');
      data = bytes;
    } else {
      if (bytes != null) {
        data = bytes;
      } else if (filePath != null) {
        data = await File(filePath).readAsBytes();
      } else {
        throw Exception('Either filePath or bytes must be provided');
      }
    }
    final excel = Excel.decodeBytes(data);
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

        if (row.isEmpty) continue;

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

        final existing = await Supabase.instance.client
            .from('app_user')
            .select()
            .eq('id_kader', idKader);

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
          await Supabase.instance.client
              .from('app_user')
              .update(mapData)
              .eq('id', existing.first['id']);
        } else {
          mapData['id'] = uuid.v4();
          mapData['id_kader'] = idKader;
          mapData['password'] =
              '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; // SHA256 for '123456'
          await Supabase.instance.client.from('app_user').insert(mapData);
        }
      }
    }
  }

  Future<void> importDataPengurus({String? filePath, Uint8List? bytes}) async {
    Uint8List data;
    if (kIsWeb) {
      if (bytes == null) throw Exception('File bytes cannot be null on Web');
      data = bytes;
    } else {
      if (bytes != null) {
        data = bytes;
      } else if (filePath != null) {
        data = await File(filePath).readAsBytes();
      } else {
        throw Exception('Either filePath or bytes must be provided');
      }
    }
    final excel = Excel.decodeBytes(data);
    const uuid = Uuid();
    final defaultPasswordHash = sha256
        .convert(utf8.encode('dawis010'))
        .toString();

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      int i = 0;
      for (final row in sheet.rows) {
        if (i < 6) {
          i++;
          continue;
        }

        if (row.isEmpty) {
          i++;
          continue;
        }

        String getString(int index) {
          if (index >= row.length) return '';
          return row[index]?.value?.toString().trim() ?? '';
        }

        final noStr = getString(0);
        if (noStr.isEmpty) {
          i++;
          continue; // Skip if no number
        }

        final rwStr = getString(
          1,
        ).replaceAll('RW.', '').replaceAll('RW', '').trim();
        final rtStr = getString(
          2,
        ).replaceAll('RT.', '').replaceAll('RT', '').trim();
        final nama = getString(3);
        final nik = getString(4);
        final tempatLahir = getString(5);

        String tanggalLahir = getString(6);
        if (tanggalLahir.isNotEmpty && tanggalLahir.contains('T')) {
          tanggalLahir = tanggalLahir.split('T')[0];
        } else if (tanggalLahir.isNotEmpty && tanggalLahir.contains(' ')) {
          tanggalLahir = tanggalLahir.split(' ')[0];
        }

        final alamat = getString(7);
        final noHp = getString(8);
        final email = getString(11);
        final noRekeningBank = getString(12);

        String role = '';
        String idKader = '';
        String? rtParam;
        String? rwParam = rwStr;

        // RT column might contain RW value if it's the RW leader
        final rtRaw = getString(2).toUpperCase();
        if (rtRaw.contains('RW')) {
          role = 'RW';
          idKader = 'RW$rwStr';
        } else {
          role = 'RT';
          idKader = 'RT${rtStr}_RW$rwStr';
          rtParam = rtStr;
        }

        final existing = await Supabase.instance.client
            .from('app_user')
            .select()
            .eq('id_kader', idKader);

        final mapData = <String, dynamic>{
          'nama': nama,
          'kelompok_dawis': null,
          'role': role,
          'rt': rtParam,
          'rw': rwParam,
          'nik': nik,
          'tempat_lahir': tempatLahir,
          'tanggal_lahir': tanggalLahir,
          'alamat': alamat,
          'no_hp': noHp,
          'email': email,
          'no_rekening_bank': noRekeningBank,
        };

        if (existing.isNotEmpty) {
          await Supabase.instance.client
              .from('app_user')
              .update(mapData)
              .eq('id', existing.first['id']);
        } else {
          mapData['id'] = uuid.v4();
          mapData['id_kader'] = idKader;
          mapData['password'] = defaultPasswordHash;
          mapData['is_active'] = 1;
          await Supabase.instance.client.from('app_user').insert(mapData);
        }

        i++;
      }
    }
  }
}
