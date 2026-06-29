import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionData {
  final String kotaKab;
  final String kecamatan;
  final String kelurahan;

  RegionData({
    required this.kotaKab,
    required this.kecamatan,
    required this.kelurahan,
  });

  RegionData copyWith({String? kotaKab, String? kecamatan, String? kelurahan}) {
    return RegionData(
      kotaKab: kotaKab ?? this.kotaKab,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
    );
  }
}

class RegionNotifier extends Notifier<RegionData> {
  static const _kotaKabKey = 'region_kota_kab';
  static const _kecamatanKey = 'region_kecamatan';
  static const _kelurahanKey = 'region_kelurahan';

  @override
  RegionData build() {
    _loadFromPrefs();
    return RegionData(
      kotaKab: 'JAKARTA TIMUR', // Default value based on user request
      kecamatan: 'MATRAMAN',
      kelurahan: 'UTAN KAYU UTARA',
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final kotaKab = prefs.getString(_kotaKabKey) ?? 'JAKARTA TIMUR';
    final kecamatan = prefs.getString(_kecamatanKey) ?? 'MATRAMAN';
    final kelurahan = prefs.getString(_kelurahanKey) ?? 'UTAN KAYU UTARA';

    state = RegionData(
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
    );
  }

  Future<void> saveRegion({
    required String kotaKab,
    required String kecamatan,
    required String kelurahan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kotaKabKey, kotaKab);
    await prefs.setString(_kecamatanKey, kecamatan);
    await prefs.setString(_kelurahanKey, kelurahan);

    state = RegionData(
      kotaKab: kotaKab,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
    );
  }
}

final regionProvider = NotifierProvider<RegionNotifier, RegionData>(
  RegionNotifier.new,
);
