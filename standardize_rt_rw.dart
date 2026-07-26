// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

String format3(String? val) {
  final s = (val ?? '').trim();
  if (s.isEmpty) return '';
  final n = int.tryParse(s);
  if (n != null) return n.toString().padLeft(3, '0');
  return s.padLeft(3, '0');
}

String normalizeDawisName(String? input) {
  if (input == null || input.trim().isEmpty) return '';
  final trimmed = input.trim();
  final regex = RegExp(
    r'^(.+?)\s*(\d{1,3})\s*[.,-]\s*(\d{1,3})\s*[.,-]\s*(\d{1,3})\s*$',
  );
  final match = regex.firstMatch(trimmed);
  if (match != null) {
    final name = match.group(1)?.trim() ?? '';
    final rw = match.group(2)?.padLeft(3, '0') ?? '';
    final rt = match.group(3)?.padLeft(3, '0') ?? '';
    final urut = match.group(4)?.padLeft(3, '0') ?? '';
    return '$name $rw.$rt.$urut';
  }
  return trimmed;
}

void main() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: File .env tidak ditemukan!');
    return;
  }

  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  for (var line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('SUPABASE_URL=')) {
      url = trimmed.split('=').sublist(1).join('=').trim();
    }
    if (trimmed.startsWith('SUPABASE_ANON_KEY=')) {
      key = trimmed.split('=').sublist(1).join('=').trim();
    }
  }

  if (url.isEmpty || key.isEmpty) {
    print(
      'Error: SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env!',
    );
    return;
  }

  print('Menggunakan Supabase URL: $url');
  print('=== MEMULAI STANDARISASI RT & RW (3 DIGIT) DI SUPABASE ===\n');

  final client = HttpClient();

  try {
    // 1. STANDARISASI TABEL BANGUNAN
    print('--- 1. Memeriksa tabel [bangunan] ---');
    final bangUrl = Uri.parse(
      '$url/rest/v1/bangunan?select=id,nama_bangunan,rt,rw,kelompok_dawis',
    );
    final bangReq = await client.getUrl(bangUrl);
    bangReq.headers.add('apikey', key);
    bangReq.headers.add('Authorization', 'Bearer $key');

    final bangRes = await bangReq.close();
    final bangBody = await bangRes.transform(utf8.decoder).join();

    if (bangRes.statusCode < 200 || bangRes.statusCode >= 300) {
      print(
        'Error saat mengambil data bangunan (Status ${bangRes.statusCode}): $bangBody',
      );
    } else {
      final List<dynamic> bangList = jsonDecode(bangBody);
      print('Total data bangunan di Supabase: ${bangList.length}');
      int bangUpdatedCount = 0;

      for (var b in bangList) {
        final id = b['id']?.toString() ?? '';
        final oldRt = b['rt']?.toString() ?? '';
        final oldRw = b['rw']?.toString() ?? '';
        final oldKd = b['kelompok_dawis']?.toString() ?? '';

        final newRt = format3(oldRt);
        final newRw = format3(oldRw);
        final newKd = normalizeDawisName(oldKd);

        if (oldRt != newRt || oldRw != newRw || oldKd != newKd) {
          print(' [Bangunan ID: $id] Perubahan terdeteksi:');
          if (oldRt != newRt) print('   - RT: "$oldRt" -> "$newRt"');
          if (oldRw != newRw) print('   - RW: "$oldRw" -> "$newRw"');
          if (oldKd != newKd) {
            print('   - Kelompok Dawis: "$oldKd" -> "$newKd"');
          }

          final updateUrl = Uri.parse('$url/rest/v1/bangunan?id=eq.$id');
          final updateReq = await client.patchUrl(updateUrl);
          updateReq.headers.add('apikey', key);
          updateReq.headers.add('Authorization', 'Bearer $key');
          updateReq.headers.add('Content-Type', 'application/json');
          updateReq.headers.add('Prefer', 'return=representation');

          final bodyMap = <String, dynamic>{};
          if (oldRt != newRt) bodyMap['rt'] = newRt;
          if (oldRw != newRw) bodyMap['rw'] = newRw;
          if (oldKd != newKd) bodyMap['kelompok_dawis'] = newKd;

          updateReq.write(jsonEncode(bodyMap));
          final updateRes = await updateReq.close();
          final updateBody = await updateRes.transform(utf8.decoder).join();

          if (updateRes.statusCode >= 200 && updateRes.statusCode < 300) {
            bangUpdatedCount++;
          } else {
            print(
              '   [!] Gagal update bangunan ID $id (Status ${updateRes.statusCode}): $updateBody',
            );
          }
        }
      }
      print(
        '=> Selesai! $bangUpdatedCount data bangunan berhasil distandarisasi.\n',
      );
    }

    // 2. STANDARISASI TABEL APP_USER (AKUN PENGGUNA)
    print('--- 2. Memeriksa tabel [app_user] ---');
    final userUrl = Uri.parse(
      '$url/rest/v1/app_user?select=id,nama,rt,rw,role,kelompok_dawis',
    );
    final userReq = await client.getUrl(userUrl);
    userReq.headers.add('apikey', key);
    userReq.headers.add('Authorization', 'Bearer $key');

    final userRes = await userReq.close();
    final userBody = await userRes.transform(utf8.decoder).join();

    if (userRes.statusCode < 200 || userRes.statusCode >= 300) {
      print(
        'Error saat mengambil data app_user (Status ${userRes.statusCode}): $userBody',
      );
    } else {
      final List<dynamic> userList = jsonDecode(userBody);
      print('Total data app_user di Supabase: ${userList.length}');
      int userUpdatedCount = 0;

      for (var u in userList) {
        final id = u['id']?.toString() ?? '';
        final nama = u['nama']?.toString() ?? '';
        final oldRt = u['rt']?.toString() ?? '';
        final oldRw = u['rw']?.toString() ?? '';
        final oldKd = u['kelompok_dawis']?.toString() ?? '';

        final newRt = format3(oldRt);
        final newRw = format3(oldRw);
        final newKd = normalizeDawisName(oldKd);

        if (oldRt != newRt || oldRw != newRw || oldKd != newKd) {
          print(' [User ID: $id - $nama] Perubahan terdeteksi:');
          if (oldRt != newRt) print('   - RT: "$oldRt" -> "$newRt"');
          if (oldRw != newRw) print('   - RW: "$oldRw" -> "$newRw"');
          if (oldKd != newKd) {
            print('   - Kelompok Dawis: "$oldKd" -> "$newKd"');
          }

          final updateUrl = Uri.parse('$url/rest/v1/app_user?id=eq.$id');
          final updateReq = await client.patchUrl(updateUrl);
          updateReq.headers.add('apikey', key);
          updateReq.headers.add('Authorization', 'Bearer $key');
          updateReq.headers.add('Content-Type', 'application/json');
          updateReq.headers.add('Prefer', 'return=representation');

          final bodyMap = <String, dynamic>{};
          if (oldRt != newRt) bodyMap['rt'] = newRt;
          if (oldRw != newRw) bodyMap['rw'] = newRw;
          if (oldKd != newKd) bodyMap['kelompok_dawis'] = newKd;

          updateReq.write(jsonEncode(bodyMap));
          final updateRes = await updateReq.close();
          final updateBody = await updateRes.transform(utf8.decoder).join();

          if (updateRes.statusCode >= 200 && updateRes.statusCode < 300) {
            userUpdatedCount++;
          } else {
            print(
              '   [!] Gagal update app_user ID $id (Status ${updateRes.statusCode}): $updateBody',
            );
          }
        }
      }
      print(
        '=> Selesai! $userUpdatedCount data app_user berhasil distandarisasi.\n',
      );
    }

    print('=== STANDARISASI SELESAI DENGAN SUKSES ===');
  } catch (e) {
    print('Terjadi kesalahan: $e');
  } finally {
    client.close();
  }
}
