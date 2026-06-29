import '../../domain/entities/krt.dart';

class KrtModel extends Krt {
  KrtModel({
    required super.id,
    required super.idBangunan,
    required super.namaKrt,
    required super.nikKrt,
    required super.noKkKrt,
    super.isSynced = 0,
  });

  factory KrtModel.fromJson(Map<String, dynamic> json) {
    return KrtModel(
      id: json['id'] as String,
      idBangunan: json['id_bangunan'] as String,
      namaKrt: json['nama_krt'] as String,
      nikKrt: json['nik_krt'] as String,
      noKkKrt: json['no_kk_krt'] as String,
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_bangunan': idBangunan,
      'nama_krt': namaKrt,
      'nik_krt': nikKrt,
      'no_kk_krt': noKkKrt,
      'is_synced': isSynced,
    };
  }

  factory KrtModel.fromEntity(Krt entity) {
    return KrtModel(
      id: entity.id,
      idBangunan: entity.idBangunan,
      namaKrt: entity.namaKrt,
      nikKrt: entity.nikKrt,
      noKkKrt: entity.noKkKrt,
      isSynced: entity.isSynced,
    );
  }
}
