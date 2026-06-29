import 'dart:io';

void main() {
  final file = File(
    r'E:\Project\DAWIS\lib\src\features\report\presentation\providers\report_provider.dart',
  );
  var content = file.readAsStringSync();

  final ringkasanMethods =
      r'''
  Future<List<String>> _getFilteredKelompokNames() async {
    final rt = ref.read(reportRtProvider);
    final rw = ref.read(reportRwProvider);
    final repo = ref.read(reportRepositoryProvider);

    final dataForm1 = await repo.getForm1Data(rt, rw);
    final allList = await repo.getAllKelompokDawisList();
    final currentUser = ref.read(loggedInUserProvider);
    
    List<Map<String, String>> targetKaders = allList;
    if (currentUser != null && currentUser.role != 'ADMIN') {
      if (currentUser.role == 'RW') {
        targetKaders = allList.where((map) => map['rw'] == currentUser.rw).toList();
      } else if (currentUser.role == 'RT') {
        targetKaders = allList
            .where((map) => map['rw'] == currentUser.rw && map['rt'] == currentUser.rt)
            .toList();
      } else if (currentUser.role == 'KADER') {
        targetKaders = allList
            .where((map) => map['kelompok_dawis'] == currentUser.kelompokDawis)
            .toList();
      }
    }

    final allowedNames = targetKaders
        .map((k) => (k['kelompok_dawis'] ?? '').toLowerCase().replaceAll(' ', '').replaceAll('.', ''))
        .toList();

    final form1Kaders = List<Map<String, dynamic>>.from(dataForm1['kelompokList'] ?? []);

    final filteredNames = <String>[];
    for (var f1 in form1Kaders) {
      final f1Name = (f1['namaKelompok'] as String).toLowerCase().replaceAll(' ', '').replaceAll('.', '');
      final isAllowed = allowedNames.any((allowed) => allowed.startsWith(f1Name) || f1Name.startsWith(allowed));
      if (isAllowed) {
        filteredNames.add(f1['namaKelompok'] as String);
      }
    }
    
    if (filteredNames.isEmpty) {
      return targetKaders.map((k) => k['kelompok_dawis'] ?? '').toList();
    }
    return filteredNames;
  }

  Future<Uint8List> generateForm3RingkasanPdf() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfReportServiceProvider);

      final allowedNames = await _getFilteredKelompokNames();
      
      List<Map<String, dynamic>> ringkasanRows = [];
      String? firstKelurahan;
      String? firstKecamatan;
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;
      int globalIndex = 1;

      for (var name in allowedNames) {
        final data = await repo.getForm3Data(name, rt, rw);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;
        
        firstKelurahan ??= data['kelurahan'];
        firstKecamatan ??= data['kecamatan'];

        int totalL = 0, totalP = 0, totalJumlah = 0;
        int totalBalita = 0, totalAnak = 0, totalRemaja = 0, totalDewasa = 0, totalLansia = 0;
        int totalKeluarga = 0, totalPus = 0, totalMow = 0, totalMop = 0;
        int totalIud = 0, totalImplant = 0, totalSuntik = 0, totalPil = 0, totalKondom = 0, totalKb = 0;
        int totalTial = 0, totalIat = 0, totalIas = 0, totalHamil = 0, totalBukanKb = 0;
        int krtCount = 0;

        for (var row in data['rows']) {
          krtCount++;
          totalL += (row['L'] as int? ?? 0);
          totalP += (row['P'] as int? ?? 0);
          totalJumlah += (row['jumlah'] as int? ?? 0);
          totalBalita += (row['balita'] as int? ?? 0);
          totalAnak += (row['anak'] as int? ?? 0);
          totalRemaja += (row['remaja'] as int? ?? 0);
          totalDewasa += (row['dewasa'] as int? ?? 0);
          totalLansia += (row['lansia'] as int? ?? 0);
          totalKeluarga += (row['jumlahKeluarga'] as int? ?? 0);
          totalPus += (row['pus'] as int? ?? 0);
          totalMow += (row['mow'] as int? ?? 0);
          totalMop += (row['mop'] as int? ?? 0);
          totalIud += (row['iud'] as int? ?? 0);
          totalImplant += (row['implant'] as int? ?? 0);
          totalSuntik += (row['suntik'] as int? ?? 0);
          totalPil += (row['pil'] as int? ?? 0);
          totalKondom += (row['kondom'] as int? ?? 0);
          totalKb += (row['jumlahKb'] as int? ?? 0);
          totalTial += (row['tial'] as int? ?? 0);
          totalIat += (row['iat'] as int? ?? 0);
          totalIas += (row['ias'] as int? ?? 0);
          totalHamil += (row['hamil'] as int? ?? 0);
          totalBukanKb += (row['jumlahBukanKb'] as int? ?? 0);
        }
        
        ringkasanRows.add({
          'no': globalIndex++,
          'namaKrt': name,
          'namaKk': krtCount.toString(),
          'L': totalL, 'P': totalP, 'jumlah': totalJumlah,
          'balita': totalBalita, 'anak': totalAnak, 'remaja': totalRemaja,
          'dewasa': totalDewasa, 'lansia': totalLansia,
          'jumlahKeluarga': totalKeluarga, 'pus': totalPus,
          'mow': totalMow, 'mop': totalMop, 'iud': totalIud,
          'implant': totalImplant, 'suntik': totalSuntik, 'pil': totalPil,
          'kondom': totalKondom, 'jumlahKb': totalKb,
          'tial': totalTial, 'iat': totalIat, 'ias': totalIas,
          'hamil': totalHamil, 'jumlahBukanKb': totalBukanKb,
        });
      }

      final ringkasanData = {
        'namaKader': allowedNames.join(', '),
        'kelompokName': 'Semua Kelompok RT $pkkRt RW $pkkRw',
        'rt': pkkRt,
        'rw': pkkRw,
        'kelurahan': firstKelurahan ?? '',
        'kecamatan': firstKecamatan ?? '',
        'kota': 'Jakarta Timur',
        'rows': ringkasanRows,
      };

      final pdfBytes = await pdfService.generateForm3(data: ringkasanData);

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateRekapPkkRingkasanPdf() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfReportServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      for (var name in allowedNames) {
        final data = await repo.getRekapPKK(name);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;
        
        int totalKk = 0, jiwaLaki = 0, jiwaPerempuan = 0;
        int balitaLaki = 0, balitaPerempuan = 0;
        int pus = 0, wus = 0, ibuHamil = 0, ibuMenyusui = 0;
        int lansia = 0, buta = 0, berkebutuhanKhusus = 0;
        int rumahSehat = 0, rumahTidakSehat = 0, punyaTempatSampah = 0, punyaSpal = 0, punyaJamban = 0, tempelStiker = 0;
        int pdam = 0, sumur = 0, dll = 0;
        int beras = 0, nonBeras = 0;
        int up2k = 0, pekarangan = 0, industri = 0, kerja = 0;
        int krtCount = 0;

        for (var r in data['rows']) {
          krtCount++;
          totalKk += (r['jmlKk'] as int? ?? 0);
          jiwaLaki += (r['jiwaLaki'] as int? ?? 0);
          jiwaPerempuan += (r['jiwaPerempuan'] as int? ?? 0);
          balitaLaki += (r['balitaLaki'] as int? ?? 0);
          balitaPerempuan += (r['balitaPerempuan'] as int? ?? 0);
          pus += (r['pus'] as int? ?? 0);
          wus += (r['wus'] as int? ?? 0);
          ibuHamil += (r['ibuHamil'] as int? ?? 0);
          ibuMenyusui += (r['ibuMenyusui'] as int? ?? 0);
          lansia += (r['lansia'] as int? ?? 0);
          buta += (r['buta'] as int? ?? 0);
          berkebutuhanKhusus += (r['berkebutuhanKhusus'] as int? ?? 0);
          rumahSehat += (r['rumahSehat'] as int? ?? 0);
          rumahTidakSehat += (r['rumahTidakSehat'] as int? ?? 0);
          punyaTempatSampah += (r['punyaTempatSampah'] as int? ?? 0);
          punyaSpal += (r['punyaSpal'] as int? ?? 0);
          punyaJamban += (r['punyaJamban'] as int? ?? 0);
          tempelStiker += (r['tempelStiker'] as int? ?? 0);
          pdam += (r['sumberAirPdam'] as int? ?? 0);
          sumur += (r['sumberAirSumur'] as int? ?? 0);
          dll += (r['sumberAirLainnya'] as int? ?? 0);
          beras += (r['makananBeras'] as int? ?? 0);
          nonBeras += (r['makananNonBeras'] as int? ?? 0);
          up2k += (r['ikutUp2k'] as int? ?? 0);
          pekarangan += (r['pekarangan'] as int? ?? 0);
          industri += (r['industriRT'] as int? ?? 0);
          kerja += (r['kerjaBakti'] as int? ?? 0);
        }
        
        ringkasanRows.add({
          'namaKrt': name,
          'jmlKk': totalKk,
          'jiwaLaki': jiwaLaki, 'jiwaPerempuan': jiwaPerempuan,
          'balitaLaki': balitaLaki, 'balitaPerempuan': balitaPerempuan,
          'pus': pus, 'wus': wus, 'ibuHamil': ibuHamil, 'ibuMenyusui': ibuMenyusui,
          'lansia': lansia, 'buta': buta, 'berkebutuhanKhusus': berkebutuhanKhusus,
          'rumahSehat': rumahSehat, 'rumahTidakSehat': rumahTidakSehat,
          'punyaTempatSampah': punyaTempatSampah, 'punyaSpal': punyaSpal,
          'punyaJamban': punyaJamban, 'tempelStiker': tempelStiker,
          'sumberAirPdam': pdam, 'sumberAirSumur': sumur, 'sumberAirLainnya': dll,
          'makananBeras': beras, 'makananNonBeras': nonBeras,
          'ikutUp2k': up2k, 'pekarangan': pekarangan, 'industriRT': industri, 'kerjaBakti': kerja,
          'keterangan': '',
        });
      }
      
      final ringkasanData = {
        'kelompokName': 'Semua Kelompok RT $pkkRt RW $pkkRw',
        'namaKader': allowedNames.join(', '),
        'rows': ringkasanRows,
      };

      final pdfBytes = await pdfService.generateRekapPkkPdf(
        namaKelompok: ringkasanData['kelompokName'] as String,
        rt: pkkRt,
        rw: pkkRw,
        desa: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI Jakarta',
        data: ringkasanData,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateProfilPendudukRingkasanPdf() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfReportServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      for (var name in allowedNames) {
        final data = await repo.getProfilPendudukData(name);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;
        
        final Map<String, int> sums = {};
        for (var r in data['rows']) {
          for (var key in r.keys) {
            if (key != 'namaKeluarga') {
               sums[key] = (sums[key] ?? 0) + (r[key] as int? ?? 0);
            }
          }
        }
        
        sums['namaKeluarga'] = 0;
        final rowMap = <String, dynamic>{
          'namaKeluarga': name,
        };
        rowMap.addAll(sums);
        ringkasanRows.add(rowMap);
      }

      final ringkasanData = {
        'kelompokName': 'Semua Kelompok RT $pkkRt RW $pkkRw',
        'namaKordinator': allowedNames.join(', '),
        'rows': ringkasanRows,
      };

      final pdfBytes = await pdfService.generateProfilKependudukan(
        data: ringkasanData,
        kelompokName: ringkasanData['kelompokName'] as String,
        rt: pkkRt,
        rw: pkkRw,
        desa: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI Jakarta',
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generatePotensiWargaRingkasanPdf() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfReportServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      for (var name in allowedNames) {
        final data = await repo.getPotensiWargaData(name);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;
        
        final Map<String, int> sums = {};
        for (var r in data['rows']) {
          for (var key in r.keys) {
            if (key != 'namaWarga' && key != 'keterangan') {
               sums[key] = (sums[key] ?? 0) + (r[key] as int? ?? 0);
            }
          }
        }
        
        final rowMap = <String, dynamic>{
          'namaWarga': name,
          'keterangan': '',
        };
        rowMap.addAll(sums);
        ringkasanRows.add(rowMap);
      }

      final ringkasanData = {
        'rows': ringkasanRows,
      };
      final kelompokNameStr = 'Semua Kelompok RT $pkkRt RW $pkkRw';

      final pdfBytes = await pdfService.generateFormDataPotensiWarga(
        data: ringkasanData,
        kelompokName: kelompokNameStr,
        rt: pkkRt,
        rw: pkkRw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI Jakarta',
        tahun: DateTime.now().year.toString(),
        bulan: ref.read(reportBulanProvider),
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateLampidRingkasanPdf() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfReportServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;
      int globalIndex = 1;

      for (var name in allowedNames) {
        final dataList = await repo.getLampidData(name);
        if (dataList.isEmpty) continue;
        
        int hamil = 0, matiHamil = 0, matiMelahirkan = 0, matiNifas = 0, matiKelahiran = 0, matiLahirBayi = 0, matiBalita = 0;
        
        for (var r in dataList) {
            if (r['tipe'] == 'hamil') hamil++;
            if (r['tipe'] == 'mati_hamil') matiHamil++;
            if (r['tipe'] == 'mati_melahirkan') matiMelahirkan++;
            if (r['tipe'] == 'mati_nifas') matiNifas++;
            if (r['tipe'] == 'kelahiran') matiKelahiran++;
            if (r['tipe'] == 'kematian_bayi') matiLahirBayi++;
            if (r['tipe'] == 'kematian_balita') matiBalita++;
        }
        
        ringkasanRows.add({
          'no': globalIndex++,
          'namaWarga': name,
          'hamil': hamil, 'matiHamil': matiHamil, 'matiMelahirkan': matiMelahirkan, 'matiNifas': matiNifas,
          'matiKelahiran': matiKelahiran, 'matiLahirBayi': matiLahirBayi, 'matiBalita': matiBalita,
        });
      }

      final ringkasanData = {
        'rows': ringkasanRows,
      };

      final pdfBytes = await pdfService.generateFormIbuHamil(
        data: ringkasanData,
        kelompokName: 'Semua Kelompok RT $pkkRt RW $pkkRw',
        rt: pkkRt,
        rw: pkkRw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI Jakarta',
        tahun: DateTime.now().year.toString(),
        bulan: ref.read(reportBulanProvider),
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
'''
      '\n}';

  var targetIdx = content.lastIndexOf('}');
  if (targetIdx != -1) {
    targetIdx = content.lastIndexOf('}', targetIdx - 1);
  }

  if (targetIdx != -1) {
    final newContent =
        content.substring(0, targetIdx) +
        ringkasanMethods +
        content.substring(targetIdx + 1);
    file.writeAsStringSync(newContent);
    print('Successfully patched report_provider.dart');
  } else {
    print('Failed to patch report_provider.dart');
  }
}
