import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class LocalDbHelper {
  static Database? _database;
  static Future<Database>? _initDbFuture;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (_initDbFuture != null) {
      await _initDbFuture;
      return _database!;
    }
    
    _initDbFuture = _initDB('dasawisma.db');
    _database = await _initDbFuture;
    _initDbFuture = null;
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Menggunakan sqflite_common_ffi_web untuk platform web
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 21,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      // Menggunakan path standar
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 21,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }
  }

  static Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 17) {
      await db.execute('DROP TABLE IF EXISTS mutasi');
      await db.execute('DROP TABLE IF EXISTS individu');
      await db.execute('DROP TABLE IF EXISTS keluarga');
      await db.execute('DROP TABLE IF EXISTS krt');
      await db.execute('DROP TABLE IF EXISTS bangunan');
      await db.execute('DROP TABLE IF EXISTS app_user');
      await _createDB(db, newVersion);
      return;
    }

    if (oldVersion == 17) {
      final newCols = [
        'nik',
        'tempat_lahir',
        'tanggal_lahir',
        'pendidikan_terakhir',
        'alamat',
        'kelurahan',
        'kecamatan',
        'propinsi',
        'kode_pos',
        'alamat_ktp',
        'no_hp',
        'email',
        'no_rekening_bank',
        'npwp',
      ];
      for (var col in newCols) {
        try {
          await db.execute('ALTER TABLE app_user ADD COLUMN $col TEXT');
        } catch (e) {
          // ignore duplicate columns
        }
      }
    }

    if (oldVersion < 19) {
      try {
        await db.execute('ALTER TABLE bangunan ADD COLUMN nop_pbb TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE bangunan ADD COLUMN luas_bangunan REAL');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE bangunan ADD COLUMN luas_tanah REAL');
      } catch (_) {}
    }

    if (oldVersion < 20) {
      try {
        await db.execute(
          'ALTER TABLE individu ADD COLUMN status_yatim_piatu TEXT',
        );
      } catch (_) {}
    }

    if (oldVersion < 21) {
      try {
        final mutasiList = await db.query('mutasi', where: 'id_bangunan = ?', whereArgs: ['']);
        for (final m in mutasiList) {
          final idIndividu = m['id_individu_asal'] as String?;
          if (idIndividu != null && idIndividu.isNotEmpty) {
            final res = await db.rawQuery('''
              SELECT krt.id_bangunan 
              FROM individu 
              JOIN keluarga ON individu.id_keluarga = keluarga.id 
              JOIN krt ON keluarga.id_krt = krt.id 
              WHERE individu.id = ?
            ''', [idIndividu]);
            if (res.isNotEmpty) {
              final idB = res.first['id_bangunan'] as String;
              await db.update('mutasi', {'id_bangunan': idB}, where: 'id = ?', whereArgs: [m['id']]);
            }
            
            final jenis = (m['jenis_mutasi'] as String?)?.toUpperCase() ?? '';
            if (jenis == 'MENINGGAL' || jenis == 'PINDAH') {
              await db.delete('individu', where: 'id = ?', whereArgs: [idIndividu]);
            }
          }
        }
      } catch (_) {}
    }
  }

  static Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';
    const realNullable = 'REAL';
    const intNullable = 'INTEGER';

    await db.execute('''
      CREATE TABLE bangunan (
        id $idType,
        nomor_urut_bangunan $textNullable,
        nama_bangunan $textType,
        kelompok_dawis $textType,
        alamat_lengkap $textType,
        rt $textType,
        rw $textType,
        status_hunian $textType,
        nop_pbb $textNullable,
        luas_bangunan $realNullable,
        luas_tanah $realNullable,
        kategori_bangunan $intNullable,
        status_kepemilikan $textNullable,
        sumber_air_minum $textNullable,
        jumlah_fasilitas_bab $intNullable,
        pemanfaatan_pekarangan $textNullable,
        is_sehat_layak_huni $intNullable DEFAULT 0,
        is_tidak_sehat_layak_huni $intNullable DEFAULT 0,
        jumlah_tempat_sampah $intNullable DEFAULT 0,
        jumlah_spal $intNullable DEFAULT 0,
        jumlah_jamban_keluarga $intNullable DEFAULT 0,
        has_stiker_p4k $intNullable DEFAULT 0,
        is_synced $intType DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE krt (
        id $idType,
        id_bangunan $textType,
        nama_krt $textType,
        nik_krt $textType,
        no_kk_krt $textType,
        is_synced $intType DEFAULT 0,
        FOREIGN KEY (id_bangunan) REFERENCES bangunan (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE keluarga (
        id $idType,
        id_krt $textType,
        no_kk $textType,
        status_visitasi $textType,
        is_synced $intType DEFAULT 0,
        FOREIGN KEY (id_krt) REFERENCES krt (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE individu (
        id $idType,
        id_keluarga $textType,
        nama_lengkap $textType,
        nik $textType,
        hubungan_keluarga $textType,
        status_dgn_krt $textNullable,
        jenis_kelamin $textType,
        tempat_lahir $textType,
        tanggal_lahir $textType,
        status_perkawinan $textType,
        pendidikan_terakhir $textType,
        pekerjaan $textType,
        no_tlp $textNullable,
        alamat_ktp $textNullable,
        alamat_domisili $textNullable,
        jenis_bantuan $textNullable,
        tgl_bantuan $textNullable,
        lama_bantuan $textNullable,
        jumlah_bantuan $textNullable,
        metode_kb $textNullable,
        alasan_bukan_kb $textNullable,
        is_buta_huruf $intNullable DEFAULT 0,
        is_buta_angka $intNullable DEFAULT 0,
        is_buta_bahasa $intNullable DEFAULT 0,
        kriteria_berkebutuhan_khusus $textNullable,
        makanan_pokok $textNullable,
        agama $textNullable,
        punya_akte_kelahiran $intNullable DEFAULT 0,
        no_akte_kelahiran $textNullable,
        punya_bpjs $intNullable DEFAULT 0,
        jenis_bpjs $textNullable,
        aktif_posyandu $intNullable DEFAULT 0,
        frekuensi_posyandu $textNullable,
        ikut_kerja_bakti $intNullable DEFAULT 0,
        is_ibu_menyusui $intNullable DEFAULT 0,
        is_ikut_up2k $intNullable DEFAULT 0,
        is_industri_rumah_tangga $intNullable DEFAULT 0,
        status_yatim_piatu $textNullable,
        is_synced $intType DEFAULT 0,
        FOREIGN KEY (id_keluarga) REFERENCES keluarga (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE mutasi (
        id $idType,
        id_bangunan $textType,
        id_individu_asal $textNullable,
        jenis_mutasi $textType,
        nama_orang $textType,
        nik $textNullable,
        tanggal_mutasi $textType,
        asal $textNullable,
        tujuan $textNullable,
        sebab_kematian $textNullable,
        nama_ibu $textNullable,
        nama_suami $textNullable,
        status_ibu $textNullable,
        keterangan $textNullable,
        is_synced $intType DEFAULT 0,
        FOREIGN KEY (id_bangunan) REFERENCES bangunan (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_user (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kader TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'KADER',
        rw TEXT,
        rt TEXT,
        kelompok_dawis TEXT,
        nik TEXT,
        tempat_lahir TEXT,
        tanggal_lahir TEXT,
        pendidikan_terakhir TEXT,
        alamat TEXT,
        kelurahan TEXT,
        kecamatan TEXT,
        propinsi TEXT,
        kode_pos TEXT,
        alamat_ktp TEXT,
        no_hp TEXT,
        email TEXT,
        no_rekening_bank TEXT,
        npwp TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Insert default admin user (password is SHA-256 hash of 'admin')
    await db.execute('''
      INSERT OR IGNORE INTO app_user (id, nama, id_kader, password, role, is_active)
      VALUES ('admin', 'Administrator', 'admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'ADMIN', 1)
    ''');
  }
}
