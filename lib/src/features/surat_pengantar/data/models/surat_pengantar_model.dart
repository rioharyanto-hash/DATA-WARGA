import '../../domain/entities/surat_pengantar.dart';

class SuratPengantarModel extends SuratPengantar {
  SuratPengantarModel({
    required super.id,
    required super.noSurat,
    required super.tanggalSurat,
    required super.namaPemohon,
    required super.nik,
    required super.alamat,
    required super.keperluan,
    super.rt,
    super.rw,
    super.createdAt,
  });

  factory SuratPengantarModel.fromJson(Map<String, dynamic> json) {
    return SuratPengantarModel(
      id: json['id']?.toString() ?? '',
      noSurat: json['no_surat']?.toString() ?? '',
      tanggalSurat: json['tanggal_surat']?.toString() ?? '',
      namaPemohon: json['nama_pemohon']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      keperluan: json['keperluan']?.toString() ?? '',
      rt: json['rt']?.toString(),
      rw: json['rw']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'no_surat': noSurat,
      'tanggal_surat': tanggalSurat,
      'nama_pemohon': namaPemohon,
      'nik': nik,
      'alamat': alamat,
      'keperluan': keperluan,
      if (rt != null) 'rt': rt,
      if (rw != null) 'rw': rw,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory SuratPengantarModel.fromEntity(SuratPengantar entity) {
    return SuratPengantarModel(
      id: entity.id,
      noSurat: entity.noSurat,
      tanggalSurat: entity.tanggalSurat,
      namaPemohon: entity.namaPemohon,
      nik: entity.nik,
      alamat: entity.alamat,
      keperluan: entity.keperluan,
      rt: entity.rt,
      rw: entity.rw,
      createdAt: entity.createdAt,
    );
  }
}
