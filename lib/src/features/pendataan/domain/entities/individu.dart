class Individu {
  final String id;
  final String idKeluarga;
  final String namaLengkap;
  final String nik;
  final String hubunganKeluarga;
  final String? statusDgnKrt;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String statusPerkawinan;
  final String pendidikanTerakhir;
  final String pekerjaan;
  final String? noTlp;
  final String? alamatKtp;
  final String? alamatDomisili;
  final String? jenisBantuan;
  final String? tglBantuan;
  final String? lamaBantuan;
  final String? jumlahBantuan;

  // Modul Kesehatan & KB
  final String? metodeKb;
  final String? alasanBukanKb;

  // Modul Pendidikan Non-Formal (3 Buta)
  final int? isButaHuruf;
  final int? isButaAngka;
  final int? isButaBahasa;

  // Modul Kerentanan & Sosial
  final String? kriteriaBerkebutuhanKhusus;
  final String? statusYatimPiatu;
  final String? makananPokok;

  // Modul TP PKK (Tambahan)
  final String? agama;
  final int? punyaAkteKelahiran;
  final String? noAkteKelahiran;
  final int? punyaBpjs;
  final String? jenisBpjs;
  final int? aktifPosyandu;
  final String? frekuensiPosyandu;
  final int? ikutKerjaBakti;
  final int? isIbuMenyusui;
  final int? isIkutUp2k;
  final int? isIndustriRumahTangga;
  final String? namaAyah;
  final String? namaIbu;
  final int? isSynced;

  Individu({
    required this.id,
    required this.idKeluarga,
    required this.namaLengkap,
    required this.nik,
    required this.hubunganKeluarga,
    this.statusDgnKrt,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.statusPerkawinan,
    required this.pendidikanTerakhir,
    required this.pekerjaan,
    this.noTlp,
    this.alamatKtp,
    this.alamatDomisili,
    this.jenisBantuan,
    this.tglBantuan,
    this.lamaBantuan,
    this.jumlahBantuan,
    this.metodeKb,
    this.alasanBukanKb,
    this.isButaHuruf = 0,
    this.isButaAngka = 0,
    this.isButaBahasa = 0,
    this.kriteriaBerkebutuhanKhusus,
    this.statusYatimPiatu,
    this.makananPokok,
    this.agama,
    this.punyaAkteKelahiran = 0,
    this.noAkteKelahiran,
    this.punyaBpjs = 0,
    this.jenisBpjs,
    this.aktifPosyandu = 0,
    this.frekuensiPosyandu,
    this.ikutKerjaBakti,
    this.isIbuMenyusui,
    this.isIkutUp2k,
    this.isIndustriRumahTangga,
    this.namaAyah,
    this.namaIbu,
    this.isSynced = 0,
  });
}
