import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionData {
  final String provinsi;
  final String kotaKab;
  final String kecamatan;
  final String kelurahan;
  final String rw;

  RegionData({
    required this.provinsi,
    required this.kotaKab,
    required this.kecamatan,
    required this.kelurahan,
    this.rw = '010',
  });

  RegionData copyWith({
    String? provinsi,
    String? kotaKab,
    String? kecamatan,
    String? kelurahan,
    String? rw,
  }) {
    return RegionData(
      provinsi: provinsi ?? this.provinsi,
      kotaKab: kotaKab ?? this.kotaKab,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      rw: rw ?? this.rw,
    );
  }
}

class RegionNotifier extends Notifier<RegionData> {
  static const _provinsiKey = 'region_provinsi';
  static const _kotaKabKey = 'region_kota_kab';
  static const _kecamatanKey = 'region_kecamatan';
  static const _kelurahanKey = 'region_kelurahan';
  static const _rwKey = 'region_rw';

  @override
  RegionData build() {
    _loadFromPrefs();
    return RegionData(
      provinsi: 'DKI JAKARTA',
      kotaKab: 'JAKARTA TIMUR', // Default value based on user request
      kecamatan: 'MATRAMAN',
      kelurahan: 'UTAN KAYU UTARA',
      rw: '010',
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final provinsi = prefs.getString(_provinsiKey) ?? 'DKI JAKARTA';
    final kotaKab = prefs.getString(_kotaKabKey) ?? 'JAKARTA TIMUR';
    final kecamatan = prefs.getString(_kecamatanKey) ?? 'MATRAMAN';
    final kelurahan = prefs.getString(_kelurahanKey) ?? 'UTAN KAYU UTARA';
    final rw = prefs.getString(_rwKey) ?? '010';

    state = RegionData(
      provinsi: provinsi,
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      rw: rw,
    );
  }

  Future<void> saveRegion({
    required String provinsi,
    required String kotaKab,
    required String kecamatan,
    required String kelurahan,
    required String rw,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_provinsiKey, provinsi);
    await prefs.setString(_kotaKabKey, kotaKab);
    await prefs.setString(_kecamatanKey, kecamatan);
    await prefs.setString(_kelurahanKey, kelurahan);
    await prefs.setString(_rwKey, rw);

    state = RegionData(
      provinsi: provinsi,
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      rw: rw,
    );
  }
}

final regionProvider = NotifierProvider<RegionNotifier, RegionData>(
  RegionNotifier.new,
);
