import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionData {
  final String provinsi;
  final String kotaKab;
  final String kecamatan;
  final String kelurahan;

  RegionData({
    required this.provinsi,
    required this.kotaKab,
    required this.kecamatan,
    required this.kelurahan,
  });

  RegionData copyWith({
    String? provinsi,
    String? kotaKab,
    String? kecamatan,
    String? kelurahan,
  }) {
    return RegionData(
      provinsi: provinsi ?? this.provinsi,
      kotaKab: kotaKab ?? this.kotaKab,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
    );
  }
}

class RegionNotifier extends Notifier<RegionData> {
  static const _provinsiKey = 'region_provinsi';
  static const _kotaKabKey = 'region_kota_kab';
  static const _kecamatanKey = 'region_kecamatan';
  static const _kelurahanKey = 'region_kelurahan';

  @override
  RegionData build() {
    _loadFromPrefs();
    return RegionData(
      provinsi: 'DKI JAKARTA',
      kotaKab: 'JAKARTA TIMUR', // Default value based on user request
      kecamatan: 'MATRAMAN',
      kelurahan: 'UTAN KAYU UTARA',
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final provinsi = prefs.getString(_provinsiKey) ?? 'DKI JAKARTA';
    final kotaKab = prefs.getString(_kotaKabKey) ?? 'JAKARTA TIMUR';
    final kecamatan = prefs.getString(_kecamatanKey) ?? 'MATRAMAN';
    final kelurahan = prefs.getString(_kelurahanKey) ?? 'UTAN KAYU UTARA';

    state = RegionData(
      provinsi: provinsi,
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
    );
  }

  Future<void> saveRegion({
    required String provinsi,
    required String kotaKab,
    required String kecamatan,
    required String kelurahan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_provinsiKey, provinsi);
    await prefs.setString(_kotaKabKey, kotaKab);
    await prefs.setString(_kecamatanKey, kecamatan);
    await prefs.setString(_kelurahanKey, kelurahan);

    state = RegionData(
      provinsi: provinsi,
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
    );
  }
}

final regionProvider = NotifierProvider<RegionNotifier, RegionData>(
  RegionNotifier.new,
);
