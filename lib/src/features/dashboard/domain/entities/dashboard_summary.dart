class DashboardSummary {
  final int jumlahBangunan;
  final int jumlahKk;
  final int jumlahMutasi;
  final int jumlahBalita;
  final int jumlahLansia;
  final int jumlahWus;
  final int jumlahPus;
  final int jumlahLakiLaki;
  final int jumlahPerempuan;
  final Map<String, int> pendidikanGrouping;
  final Map<String, int> pekerjaanGrouping;
  final Map<String, int> umurGrouping;

  DashboardSummary({
    required this.jumlahBangunan,
    required this.jumlahKk,
    required this.jumlahMutasi,
    required this.jumlahBalita,
    required this.jumlahLansia,
    required this.jumlahWus,
    required this.jumlahPus,
    required this.jumlahLakiLaki,
    required this.jumlahPerempuan,
    required this.pendidikanGrouping,
    required this.pekerjaanGrouping,
    required this.umurGrouping,
  });
}
