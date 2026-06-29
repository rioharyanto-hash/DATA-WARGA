import '../../domain/entities/bangunan.dart';

class BangunanModel extends Bangunan {
  BangunanModel({
    required super.id,
    required super.kelompokDawis,
    required super.alamatLengkap,
    required super.rt,
    required super.rw,
    required super.statusHunian,
    required super.namaBangunan,
    super.nomorUrutBangunan,
    super.nopPbb,
    super.luasBangunan,
    super.luasTanah,
    super.kategoriBangunan,
    super.statusKepemilikan,
    super.sumberAirMinum,
    super.jumlahFasilitasBab,
    super.pemanfaatanPekarangan,
    super.isSehatLayakHuni,
    super.isTidakSehatLayakHuni,
    super.jumlahTempatSampah,
    super.jumlahSpal,
    super.jumlahJambanKeluarga,
    super.hasStikerP4k,
    super.isSynced = 0,
  });

  factory BangunanModel.fromJson(Map<String, dynamic> json) {
    return BangunanModel(
      id: json['id'] as String,
      kelompokDawis: json['kelompok_dawis'] as String,
      alamatLengkap: json['alamat_lengkap'] as String,
      rt: json['rt'] as String,
      rw: json['rw'] as String,
      statusHunian: json['status_hunian'] as String,
      namaBangunan: json['nama_bangunan'] as String,
      nomorUrutBangunan: json['nomor_urut_bangunan'] as String?,
      nopPbb: json['nop_pbb'] as String?,
      luasBangunan: json['luas_bangunan'] != null
          ? (json['luas_bangunan'] as num).toDouble()
          : null,
      luasTanah: json['luas_tanah'] != null
          ? (json['luas_tanah'] as num).toDouble()
          : null,
      kategoriBangunan: json['kategori_bangunan'] as int?,
      statusKepemilikan: json['status_kepemilikan'] as String?,
      sumberAirMinum: json['sumber_air_minum'] as String?,
      jumlahFasilitasBab: json['jumlah_fasilitas_bab'] as int?,
      pemanfaatanPekarangan: json['pemanfaatan_pekarangan'] as String?,
      isSehatLayakHuni: json['is_sehat_layak_huni'] as int? ?? 0,
      isTidakSehatLayakHuni: json['is_tidak_sehat_layak_huni'] as int? ?? 0,
      jumlahTempatSampah: json['jumlah_tempat_sampah'] as int? ?? 0,
      jumlahSpal: json['jumlah_spal'] as int? ?? 0,
      jumlahJambanKeluarga: json['jumlah_jamban_keluarga'] as int? ?? 0,
      hasStikerP4k: json['has_stiker_p4k'] as int? ?? 0,
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kelompok_dawis': kelompokDawis,
      'alamat_lengkap': alamatLengkap,
      'rt': rt,
      'rw': rw,
      'status_hunian': statusHunian,
      'nama_bangunan': namaBangunan,
      'nomor_urut_bangunan': nomorUrutBangunan,
      'nop_pbb': nopPbb,
      'luas_bangunan': luasBangunan,
      'luas_tanah': luasTanah,
      'kategori_bangunan': kategoriBangunan,
      'status_kepemilikan': statusKepemilikan,
      'sumber_air_minum': sumberAirMinum,
      'jumlah_fasilitas_bab': jumlahFasilitasBab,
      'pemanfaatan_pekarangan': pemanfaatanPekarangan,
      'is_sehat_layak_huni': isSehatLayakHuni,
      'is_tidak_sehat_layak_huni': isTidakSehatLayakHuni,
      'jumlah_tempat_sampah': jumlahTempatSampah,
      'jumlah_spal': jumlahSpal,
      'jumlah_jamban_keluarga': jumlahJambanKeluarga,
      'has_stiker_p4k': hasStikerP4k,
      'is_synced': isSynced,
    };
  }

  factory BangunanModel.fromEntity(Bangunan entity) {
    return BangunanModel(
      id: entity.id,
      kelompokDawis: entity.kelompokDawis,
      alamatLengkap: entity.alamatLengkap,
      rt: entity.rt,
      rw: entity.rw,
      statusHunian: entity.statusHunian,
      namaBangunan: entity.namaBangunan,
      nomorUrutBangunan: entity.nomorUrutBangunan,
      nopPbb: entity.nopPbb,
      luasBangunan: entity.luasBangunan,
      luasTanah: entity.luasTanah,
      kategoriBangunan: entity.kategoriBangunan,
      statusKepemilikan: entity.statusKepemilikan,
      sumberAirMinum: entity.sumberAirMinum,
      jumlahFasilitasBab: entity.jumlahFasilitasBab,
      pemanfaatanPekarangan: entity.pemanfaatanPekarangan,
      isSehatLayakHuni: entity.isSehatLayakHuni,
      isTidakSehatLayakHuni: entity.isTidakSehatLayakHuni,
      jumlahTempatSampah: entity.jumlahTempatSampah,
      jumlahSpal: entity.jumlahSpal,
      jumlahJambanKeluarga: entity.jumlahJambanKeluarga,
      hasStikerP4k: entity.hasStikerP4k,
      isSynced: entity.isSynced,
    );
  }
}
