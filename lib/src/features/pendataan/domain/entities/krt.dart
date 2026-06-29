class Krt {
  final String id;
  final String idBangunan;
  final String namaKrt;
  final String nikKrt;
  final String noKkKrt;
  final int isSynced;

  Krt({
    required this.id,
    required this.idBangunan,
    required this.namaKrt,
    required this.nikKrt,
    required this.noKkKrt,
    this.isSynced = 0,
  });
}
