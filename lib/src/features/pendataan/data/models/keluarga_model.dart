import '../../domain/entities/keluarga.dart';

class KeluargaModel extends Keluarga {
  KeluargaModel({
    required super.id,
    required super.idKrt,
    required super.noKk,
    required super.statusVisitasi,
    super.isSynced = 0,
  });

  factory KeluargaModel.fromJson(Map<String, dynamic> json) {
    return KeluargaModel(
      id: json['id'] as String,
      idKrt: json['id_krt'] as String,
      noKk: json['no_kk'] as String,
      statusVisitasi: json['status_visitasi'] as String,
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_krt': idKrt,
      'no_kk': noKk,
      'status_visitasi': statusVisitasi,
      'is_synced': isSynced,
    };
  }

  factory KeluargaModel.fromEntity(Keluarga entity) {
    return KeluargaModel(
      id: entity.id,
      idKrt: entity.idKrt,
      noKk: entity.noKk,
      statusVisitasi: entity.statusVisitasi,
      isSynced: entity.isSynced,
    );
  }
}
