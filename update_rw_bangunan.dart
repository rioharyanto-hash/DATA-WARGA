// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

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
  print('Memeriksa koneksi dan mencari data bangunan dengan RW "10"...');

  final client = HttpClient();

  try {
    // 1. Cek data sebelum update
    final checkUrl = Uri.parse(
      '$url/rest/v1/bangunan?rw=eq.10&select=id,nama_bangunan,rt,rw,kelompok_dawis',
    );
    final checkReq = await client.getUrl(checkUrl);
    checkReq.headers.add('apikey', key);
    checkReq.headers.add('Authorization', 'Bearer $key');

    final checkRes = await checkReq.close();
    final checkBody = await checkRes.transform(utf8.decoder).join();

    if (checkRes.statusCode < 200 || checkRes.statusCode >= 300) {
      print(
        'Error saat mengambil data (Status ${checkRes.statusCode}): $checkBody',
      );
      return;
    }

    final List<dynamic> existingData = jsonDecode(checkBody);
    print('Ditemukan ${existingData.length} bangunan dengan RW "10".');

    if (existingData.isEmpty) {
      print('Tidak ada data yang perlu diubah.');
      return;
    }

    for (var b in existingData) {
      print(
        ' - [${b['id']}] ${b['nama_bangunan']} (Kelompok: ${b['kelompok_dawis']}, RT: ${b['rt']}, RW: ${b['rw']})',
      );
    }

    print('\nMemulai proses update RW dari "10" menjadi "010"...');

    // 2. Lakukan update (PATCH)
    final updateUrl = Uri.parse('$url/rest/v1/bangunan?rw=eq.10');
    final updateReq = await client.patchUrl(updateUrl);
    updateReq.headers.add('apikey', key);
    updateReq.headers.add('Authorization', 'Bearer $key');
    updateReq.headers.add('Content-Type', 'application/json');
    updateReq.headers.add('Prefer', 'return=representation');

    final bodyJson = jsonEncode({'rw': '010'});
    updateReq.write(bodyJson);

    final updateRes = await updateReq.close();
    final updateBody = await updateRes.transform(utf8.decoder).join();

    if (updateRes.statusCode >= 200 && updateRes.statusCode < 300) {
      final List<dynamic> updatedData = jsonDecode(updateBody);
      print(
        'Berhasil! ${updatedData.length} data bangunan telah diubah menjadi RW "010".',
      );
    } else {
      print(
        'Gagal melakukan update (Status ${updateRes.statusCode}): $updateBody',
      );
    }
  } catch (e) {
    print('Terjadi kesalahan: $e');
  } finally {
    client.close();
  }
}
