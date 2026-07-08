class DataWargaBangunan {
  final String id;
  final String namaBangunan;
  final String alamat;
  final String rt;
  final String rw;
  final String kelurahan;
  final int totalPenghuni;
  final int totalKk;
  final int lakiLaki;
  final int perempuan;
  final int? kategoriBangunan;

  const DataWargaBangunan({
    required this.id,
    required this.namaBangunan,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.totalPenghuni,
    required this.totalKk,
    required this.lakiLaki,
    required this.perempuan,
    this.kategoriBangunan,
  });

  String get formattedAddress {
    final rtRw = 'RT $rt/RW $rw';
    if (alamat.isNotEmpty) {
      if (kelurahan.isNotEmpty) {
        return '$alamat, $rtRw, Kel. $kelurahan';
      }
      return '$alamat, $rtRw';
    } else {
      if (kelurahan.isNotEmpty) {
        return '$rtRw, Kel. $kelurahan';
      }
      return rtRw;
    }
  }

  String get jenisBangunan {
    switch (kategoriBangunan) {
      case 1: return 'Rumah Tinggal';
      case 2: return 'Kontrakan';
      case 3: return 'Kos-kosan';
      case 4: return 'Asrama/Mess';
      case 5: return 'Rusun';
      case 6: return 'Rumah Dinas';
      case 7: return 'Apartemen';
      case 8: return 'Rukan/Ruko';
      case 9: return 'Kios/Toko/Warung';
      case 10: return 'Tempat Usaha Lainnya';
      case 11: return 'Sekolah';
      case 12: return 'Tempat Ibadah';
      case 13: return 'Panti';
      case 14: return 'Jenis Bangunan Lainnya';
      default: return 'Lainnya';
    }
  }
}
