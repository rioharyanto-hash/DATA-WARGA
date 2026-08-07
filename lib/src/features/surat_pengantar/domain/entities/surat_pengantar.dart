class SuratPengantar {
  final String id;
  final String noSurat;
  final String tanggalSurat;
  final String namaPemohon;
  final String nik;
  final String alamat;
  final String keperluan;
  final String? rt;
  final String? rw;
  final DateTime? createdAt;

  SuratPengantar({
    required this.id,
    required this.noSurat,
    required this.tanggalSurat,
    required this.namaPemohon,
    required this.nik,
    required this.alamat,
    required this.keperluan,
    this.rt,
    this.rw,
    this.createdAt,
  });

  SuratPengantar copyWith({
    String? id,
    String? noSurat,
    String? tanggalSurat,
    String? namaPemohon,
    String? nik,
    String? alamat,
    String? keperluan,
    String? rt,
    String? rw,
    DateTime? createdAt,
  }) {
    return SuratPengantar(
      id: id ?? this.id,
      noSurat: noSurat ?? this.noSurat,
      tanggalSurat: tanggalSurat ?? this.tanggalSurat,
      namaPemohon: namaPemohon ?? this.namaPemohon,
      nik: nik ?? this.nik,
      alamat: alamat ?? this.alamat,
      keperluan: keperluan ?? this.keperluan,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
