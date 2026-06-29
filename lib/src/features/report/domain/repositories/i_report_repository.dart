abstract class IReportRepository {
  /// Mendapatkan Data Rekapitulasi PKK tingkat Kelompok Dasawisma
  /// Mengembalikan Map berisi key metrik dan value integer hasil aggregasi.
  Future<Map<String, dynamic>> getRekapPKK(String kelompokName);

  /// Mendapatkan data Mutasi (LAMPID: Lahir, Mati, Pindah, Datang)
  Future<List<Map<String, dynamic>>> getLampidData(String kelompokName);

  /// Mendapatkan data untuk Form I (Tingkat RT)
  Future<Map<String, dynamic>> getForm1Data(String rt, String rw);

  /// Mendapatkan data untuk Form II (Tingkat Kelompok Dasawisma)
  Future<Map<String, dynamic>> getForm2Data(
    String kelompokName,
    String rt,
    String rw,
  );

  /// Mendapatkan data untuk Form Data Manual Target Sasaran
  Future<Map<String, dynamic>> getFormDataManual(
    String kelompokName,
    String rt,
    String rw,
  );

  /// Mendapatkan data untuk Form III (Data Kuantitas)
  Future<Map<String, dynamic>> getForm3Data(
    String kelompokName,
    String rt,
    String rw,
  );

  /// Mendapatkan daftar nama kelompok dasawisma yang ada beserta RT dan RW-nya
  Future<List<Map<String, String>>> getAllKelompokDawisList();

  /// Mendapatkan data profil penduduk
  Future<Map<String, dynamic>> getProfilPendudukData(String kelompokName);

  /// Mendapatkan data anak yatim piatu
  Future<List<Map<String, dynamic>>> getYatimPiatuData(String kelompokName);
  Future<List<Map<String, dynamic>>> getPotensiWargaData(String kelompokName);
}
