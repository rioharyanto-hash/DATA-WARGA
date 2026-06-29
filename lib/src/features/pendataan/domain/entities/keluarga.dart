class Keluarga {
  final String id;
  final String idKrt;
  final String noKk;
  final String statusVisitasi;
  final int isSynced;

  Keluarga({
    required this.id,
    required this.idKrt,
    required this.noKk,
    required this.statusVisitasi,
    this.isSynced = 0,
  });
}
