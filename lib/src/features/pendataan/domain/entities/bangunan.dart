class Bangunan {
  final String id;
  final String kelompokDawis;
  final String alamatLengkap;
  final String rt;
  final String rw;
  final String statusHunian;
  final String namaBangunan;
  final String? nomorUrutBangunan;

  // Data Tambahan Standar Carik
  final String? nopPbb;
  final double? luasBangunan;
  final double? luasTanah;
  final int? kategoriBangunan;
  final String? statusKepemilikan;
  final String? sumberAirMinum;
  final int? jumlahFasilitasBab;
  final String? pemanfaatanPekarangan;

  // Kriteria Rumah
  final int? isSehatLayakHuni;
  final int? isTidakSehatLayakHuni;
  final int? jumlahTempatSampah;
  final int? jumlahSpal;
  final int? jumlahJambanKeluarga;
  final int? hasStikerP4k;

  final int isSynced;

  Bangunan({
    required this.id,
    required this.kelompokDawis,
    required this.alamatLengkap,
    required this.rt,
    required this.rw,
    required this.statusHunian,
    required this.namaBangunan,
    this.nomorUrutBangunan,
    this.nopPbb,
    this.luasBangunan,
    this.luasTanah,
    this.kategoriBangunan,
    this.statusKepemilikan,
    this.sumberAirMinum,
    this.jumlahFasilitasBab,
    this.pemanfaatanPekarangan,
    this.isSehatLayakHuni = 0,
    this.isTidakSehatLayakHuni = 0,
    this.jumlahTempatSampah = 0,
    this.jumlahSpal = 0,
    this.jumlahJambanKeluarga = 0,
    this.hasStikerP4k = 0,
    this.isSynced = 0,
  });
}
