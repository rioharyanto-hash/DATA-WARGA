import '../../domain/entities/mutasi.dart';

class MutasiModel extends Mutasi {
  MutasiModel({
    required super.id,
    required super.idBangunan,
    super.idIndividuAsal,
    required super.jenisMutasi,
    required super.namaOrang,
    super.nik,
    required super.tanggalMutasi,
    super.asal,
    super.tujuan,
    super.sebabKematian,
    super.namaIbu,
    super.namaSuami,
    super.statusIbu,
    super.keterangan,
    super.isSynced,
  });

  factory MutasiModel.fromJson(Map<String, dynamic> json) {
    return MutasiModel(
      id: json['id'],
      idBangunan: json['id_bangunan'],
      idIndividuAsal: json['id_individu_asal'],
      jenisMutasi: json['jenis_mutasi'],
      namaOrang: json['nama_orang'],
      nik: json['nik'],
      tanggalMutasi: json['tanggal_mutasi'],
      asal: json['asal'],
      tujuan: json['tujuan'] as String?,
      sebabKematian: json['sebab_kematian'] as String?,
      namaIbu: json['nama_ibu'] as String?,
      namaSuami: json['nama_suami'] as String?,
      statusIbu: json['status_ibu'] as String?,
      keterangan: json['keterangan'] as String?,
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_bangunan': idBangunan,
      'id_individu_asal': idIndividuAsal,
      'jenis_mutasi': jenisMutasi,
      'nama_orang': namaOrang,
      'nik': nik,
      'tanggal_mutasi': tanggalMutasi,
      'asal': asal,
      'tujuan': tujuan,
      'sebab_kematian': sebabKematian,
      'nama_ibu': namaIbu,
      'nama_suami': namaSuami,
      'status_ibu': statusIbu,
      'keterangan': keterangan,
      'is_synced': isSynced,
    };
  }

  factory MutasiModel.fromEntity(Mutasi entity) {
    return MutasiModel(
      id: entity.id,
      idBangunan: entity.idBangunan,
      idIndividuAsal: entity.idIndividuAsal,
      jenisMutasi: entity.jenisMutasi,
      namaOrang: entity.namaOrang,
      nik: entity.nik,
      tanggalMutasi: entity.tanggalMutasi,
      asal: entity.asal,
      tujuan: entity.tujuan,
      keterangan: entity.keterangan,
      isSynced: entity.isSynced,
    );
  }
}
