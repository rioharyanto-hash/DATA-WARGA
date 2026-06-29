class Mutasi {
  final String id;
  final String idBangunan;
  final String? idIndividuAsal;
  final String jenisMutasi; // Lahir, Meninggal, Pindah, Datang
  final String namaOrang;
  final String? nik;
  final String tanggalMutasi;
  final String? asal;
  final String? tujuan;
  final String? sebabKematian;
  final String? namaIbu;
  final String? namaSuami;
  final String? statusIbu;
  final String? keterangan;
  final int isSynced;

  Mutasi({
    required this.id,
    required this.idBangunan,
    this.idIndividuAsal,
    required this.jenisMutasi,
    required this.namaOrang,
    this.nik,
    required this.tanggalMutasi,
    this.asal,
    this.tujuan,
    this.sebabKematian,
    this.namaIbu,
    this.namaSuami,
    this.statusIbu,
    this.keterangan,
    this.isSynced = 0,
  });

  Mutasi copyWith({
    String? id,
    String? idBangunan,
    String? idIndividuAsal,
    String? jenisMutasi,
    String? namaOrang,
    String? nik,
    String? tanggalMutasi,
    String? asal,
    String? tujuan,
    String? sebabKematian,
    String? namaIbu,
    String? namaSuami,
    String? statusIbu,
    String? keterangan,
    int? isSynced,
  }) {
    return Mutasi(
      id: id ?? this.id,
      idBangunan: idBangunan ?? this.idBangunan,
      idIndividuAsal: idIndividuAsal ?? this.idIndividuAsal,
      jenisMutasi: jenisMutasi ?? this.jenisMutasi,
      namaOrang: namaOrang ?? this.namaOrang,
      nik: nik ?? this.nik,
      tanggalMutasi: tanggalMutasi ?? this.tanggalMutasi,
      asal: asal ?? this.asal,
      tujuan: tujuan ?? this.tujuan,
      sebabKematian: sebabKematian ?? this.sebabKematian,
      namaIbu: namaIbu ?? this.namaIbu,
      namaSuami: namaSuami ?? this.namaSuami,
      statusIbu: statusIbu ?? this.statusIbu,
      keterangan: keterangan ?? this.keterangan,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
