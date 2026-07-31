class Keluarga {
  final String id;
  final String idKrt;
  final String noKk;
  final String statusVisitasi;
  final int isSynced;
  final String? namaKepalaKeluarga;
  final String? idKepalaKeluarga;

  Keluarga({
    required this.id,
    required this.idKrt,
    required this.noKk,
    required this.statusVisitasi,
    this.isSynced = 0,
    this.namaKepalaKeluarga,
    this.idKepalaKeluarga,
  });
}
