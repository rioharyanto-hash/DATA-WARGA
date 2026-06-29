class AppUser {
  final String id;
  final String nama;
  final String idKader;
  final String password;
  final String role; // ADMIN, RW, RT, KADER
  final String? rw;
  final String? rt;
  final String? kelompokDawis;
  final String? nik;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? pendidikanTerakhir;
  final String? alamat;
  final String? kelurahan;
  final String? kecamatan;
  final String? propinsi;
  final String? kodePos;
  final String? alamatKtp;
  final String? noHp;
  final String? email;
  final String? noRekeningBank;
  final String? npwp;
  final int isActive;

  const AppUser({
    required this.id,
    required this.nama,
    required this.idKader,
    required this.password,
    this.role = 'KADER',
    this.rw,
    this.rt,
    this.kelompokDawis,
    this.nik,
    this.tempatLahir,
    this.tanggalLahir,
    this.pendidikanTerakhir,
    this.alamat,
    this.kelurahan,
    this.kecamatan,
    this.propinsi,
    this.kodePos,
    this.alamatKtp,
    this.noHp,
    this.email,
    this.noRekeningBank,
    this.npwp,
    this.isActive = 1,
  });

  AppUser copyWith({
    String? id,
    String? nama,
    String? idKader,
    String? password,
    String? role,
    String? rw,
    String? rt,
    String? kelompokDawis,
    String? nik,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikanTerakhir,
    String? alamat,
    String? kelurahan,
    String? kecamatan,
    String? propinsi,
    String? kodePos,
    String? alamatKtp,
    String? noHp,
    String? email,
    String? noRekeningBank,
    String? npwp,
    int? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idKader: idKader ?? this.idKader,
      password: password ?? this.password,
      role: role ?? this.role,
      rw: rw ?? this.rw,
      rt: rt ?? this.rt,
      kelompokDawis: kelompokDawis ?? this.kelompokDawis,
      nik: nik ?? this.nik,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      pendidikanTerakhir: pendidikanTerakhir ?? this.pendidikanTerakhir,
      alamat: alamat ?? this.alamat,
      kelurahan: kelurahan ?? this.kelurahan,
      kecamatan: kecamatan ?? this.kecamatan,
      propinsi: propinsi ?? this.propinsi,
      kodePos: kodePos ?? this.kodePos,
      alamatKtp: alamatKtp ?? this.alamatKtp,
      noHp: noHp ?? this.noHp,
      email: email ?? this.email,
      noRekeningBank: noRekeningBank ?? this.noRekeningBank,
      npwp: npwp ?? this.npwp,
      isActive: isActive ?? this.isActive,
    );
  }
}
