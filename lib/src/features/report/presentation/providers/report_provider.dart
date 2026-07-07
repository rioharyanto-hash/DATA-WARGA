import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/services/pdf_perincian_service.dart';
import '../../data/services/pdf_ringkasan_service.dart';
import '../../data/services/pdf_blank_service.dart';
import 'dart:typed_data';
import '../../../settings/presentation/providers/app_user_provider.dart';
import '../../../settings/presentation/providers/region_provider.dart';

final pdfPerincianServiceProvider = Provider((ref) => PdfPerincianService());
final pdfRingkasanServiceProvider = Provider((ref) => PdfRingkasanService());
final pdfBlankServiceProvider = Provider((ref) => PdfBlankService());

class ReportState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String? pdfPath;

  const ReportState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.pdfPath,
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    String? pdfPath,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      pdfPath: pdfPath,
    );
  }
}

class ReportRtNotifier extends Notifier<String> {
  @override
  String build() {
    final user = ref.read(loggedInUserProvider);
    return user?.rt ?? '01';
  }

  void update(String value) {
    state = value;
  }
}

final reportRtProvider = NotifierProvider<ReportRtNotifier, String>(
  ReportRtNotifier.new,
);

class ReportRwNotifier extends Notifier<String> {
  @override
  String build() {
    final user = ref.read(loggedInUserProvider);
    return user?.rw ?? '02';
  }

  void update(String value) {
    state = value;
  }
}

final reportRwProvider = NotifierProvider<ReportRwNotifier, String>(
  ReportRwNotifier.new,
);

class ReportBulanNotifier extends Notifier<String> {
  @override
  String build() {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[DateTime.now().month - 1];
  }

  void update(String value) {
    state = value;
  }
}

final reportBulanProvider = NotifierProvider<ReportBulanNotifier, String>(
  ReportBulanNotifier.new,
);

final kelompokDawisListProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final repo = ref.read(reportRepositoryProvider);
  final allList = await repo.getAllKelompokDawisList();

  final currentUser = ref.read(loggedInUserProvider);
  if (currentUser == null || currentUser.role == 'ADMIN') {
    return allList;
  }

  if (currentUser.role == 'RW') {
    return allList.where((map) => map['rw'] == currentUser.rw).toList();
  }

  if (currentUser.role == 'RT') {
    return allList
        .where(
          (map) => map['rw'] == currentUser.rw && map['rt'] == currentUser.rt,
        )
        .toList();
  }

  if (currentUser.role == 'KADER') {
    return allList
        .where((map) => map['kelompok_dawis'] == currentUser.kelompokDawis)
        .toList();
  }

  return allList;
});

class ReportController extends Notifier<ReportState> {
  @override
  ReportState build() {
    return ReportState();
  }

  Future<Uint8List> generateRekapPkkPdf(String namaKelompok) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getRekapPKK(namaKelompok);
      final region = ref.read(regionProvider);
      data['tahun'] = DateTime.now().year.toString();

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateRekapPkkPerincianPdf(
        namaKelompok: namaKelompok,
        rt: ref.read(reportRtProvider),
        rw: ref.read(reportRwProvider),
        desa: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI JAKARTA',
        data: data,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateYatimPiatuPdf(String namaKelompok) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final dataList = await repo.getYatimPiatuData(namaKelompok);
      final region = ref.read(regionProvider);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      // Determine RT and RW from somewhere. Actually, just use dummy for now or fetch from user
      // Let's assume RT and RW can be taken from region or default
      final pdfBytes = await pdfService.generateYatimPiatuPdf(
        namaKelompok: namaKelompok,
        rt: '01', // Should be dynamic, but for now fallback to 01
        rw: '02',
        desa: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
        provinsi: 'DKI JAKARTA',
        data: dataList,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateProfilPendudukPdf(String namaKelompok) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getProfilPendudukData(namaKelompok);
      final region = ref.read(regionProvider);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateProfilUsiaPdf(
        namaKelompok: namaKelompok,
        rt: data['rt']?.toString() ?? '',
        rw: data['rw']?.toString() ?? '',
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kota: region.kotaKab,
        bulanTahun: '${ref.read(reportBulanProvider)} ${DateTime.now().year}',
        data:
            (data['keluargaList'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateLampidPdf(String namaKelompok) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final region = ref.read(regionProvider);
      final bulan = ref.read(reportBulanProvider);
      final tahun = DateTime.now().year.toString();

      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getLampidData(namaKelompok);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateLampidPdfPerincian(
        namaKelompok: namaKelompok,
        mutasiList: data,
        rt: rt,
        rw: rw,
        kelurahan: region.kelurahan,
        bulan: bulan,
        tahun: tahun,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateForm1Pdf(String namaKelompok) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final region = ref.read(regionProvider);

      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getForm1Data(rt, rw);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateForm1(
        data: data,
        rt: rt,
        rw: rw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kabupaten: region.kotaKab,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateForm2Pdf(String kelompokName) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);

      final repo = ref.read(reportRepositoryProvider);

      // Fetch all Kelompok Dawis list
      final allList = await repo.getAllKelompokDawisList();
      final currentUser = ref.read(loggedInUserProvider);
      List<Map<String, String>> targetKaders = allList;
      if (currentUser != null && currentUser.role != 'ADMIN') {
        if (currentUser.role == 'RW') {
          targetKaders = allList
              .where((map) => map['rw'] == currentUser.rw)
              .toList();
        } else if (currentUser.role == 'RT') {
          targetKaders = allList
              .where(
                (map) =>
                    map['rw'] == currentUser.rw && map['rt'] == currentUser.rt,
              )
              .toList();
        } else if (currentUser.role == 'KADER') {
          targetKaders = allList
              .where(
                (map) => map['kelompok_dawis'] == currentUser.kelompokDawis,
              )
              .toList();
        }
      }

      List<Map<String, dynamic>> allDataList = [];
      for (final kader in targetKaders) {
        final name = kader['kelompok_dawis'] ?? '';
        final kaderRt = kader['rt'] ?? rt;
        final kaderRw = kader['rw'] ?? rw;
        final data = await repo.getForm2Data(name, kaderRt, kaderRw);
        allDataList.add(data);
      }

      // If for some reason targetKaders is empty, fallback to the selected one from parameter
      if (allDataList.isEmpty) {
        final data = await repo.getForm2Data(kelompokName, rt, rw);
        allDataList.add(data);
      }

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateForm2(dataList: allDataList);

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateForm1And2Pdf(String kelompokName) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final region = ref.read(regionProvider);
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);

      final repo = ref.read(reportRepositoryProvider);

      // Fetch data for Form 1
      final dataForm1 = await repo.getForm1Data(rt, rw);

      // Fetch data for Form 2 (multiple pages)
      final allList = await repo.getAllKelompokDawisList();
      final currentUser = ref.read(loggedInUserProvider);
      List<Map<String, String>> targetKaders = allList;
      if (currentUser != null && currentUser.role != 'ADMIN') {
        if (currentUser.role == 'RW') {
          targetKaders = allList
              .where((map) => map['rw'] == currentUser.rw)
              .toList();
        } else if (currentUser.role == 'RT') {
          targetKaders = allList
              .where(
                (map) =>
                    map['rw'] == currentUser.rw && map['rt'] == currentUser.rt,
              )
              .toList();
        } else if (currentUser.role == 'KADER') {
          targetKaders = allList
              .where(
                (map) => map['kelompok_dawis'] == currentUser.kelompokDawis,
              )
              .toList();
        }
      }

      if (!kelompokName.startsWith('Semua ')) {
        targetKaders = targetKaders
            .where((k) => k['kelompok_dawis'] == kelompokName)
            .toList();
      }

      final form1Kaders = List<Map<String, dynamic>>.from(
        dataForm1['kelompokList'] ?? [],
      );

      final allowedNames = targetKaders
          .map(
            (k) => (k['kelompok_dawis'] ?? '')
                .toLowerCase()
                .replaceAll(' ', '')
                .replaceAll('.', ''),
          )
          .toList();

      final filteredForm1Kaders = form1Kaders.where((f1) {
        final f1Name = (f1['namaKelompok'] as String)
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('.', '');
        return allowedNames.any(
          (allowed) => allowed.startsWith(f1Name) || f1Name.startsWith(allowed),
        );
      }).map((f1) {
        final f1Name = (f1['namaKelompok'] as String)
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('.', '');
            
        final matchedKader = targetKaders.cast<Map<String, String>?>().firstWhere(
          (k) {
             if (k == null) return false;
             final allowed = (k['kelompok_dawis'] ?? '').toLowerCase().replaceAll(' ', '').replaceAll('.', '');
             return allowed.startsWith(f1Name) || f1Name.startsWith(allowed);
          },
          orElse: () => null,
        );
        
        return {
          ...f1,
          'idKader': matchedKader?['id_kader'] ?? '',
          'namaKordinator': matchedKader?['nama'] ?? '',
        };
      }).toList();

      int newJumlahBangunan = 0;
      int newJumlahKrt = 0;
      int newJumlahKeluarga = 0;
      int newJumlahIndividu = 0;

      for (var f1 in filteredForm1Kaders) {
        newJumlahBangunan += (f1['jumlahBangunan'] as int? ?? 0);
        newJumlahKrt += (f1['jumlahKrt'] as int? ?? 0);
        newJumlahKeluarga += (f1['jumlahKeluarga'] as int? ?? 0);
        newJumlahIndividu += (f1['jumlahIndividu'] as int? ?? 0);
      }

      final filteredDataForm1 = {
        ...dataForm1,
        'jumlahKelompok': filteredForm1Kaders.length,
        'jumlahBangunan': newJumlahBangunan,
        'jumlahKrt': newJumlahKrt,
        'jumlahKeluarga': newJumlahKeluarga,
        'jumlahIndividu': newJumlahIndividu,
        'kelompokList': filteredForm1Kaders,
      };

      List<Map<String, dynamic>> allDataListForm2 = [];
      for (final f1 in filteredForm1Kaders) {
        final name = f1['namaKelompok'] ?? '';
        final data = await repo.getForm2Data(name, rt, rw);
        allDataListForm2.add(data);
      }

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateForm1And2(
        dataForm1: filteredDataForm1,
        dataForm2: allDataListForm2,
        kabupaten: region.kotaKab,
        kecamatan: region.kecamatan,
        kelurahan: region.kelurahan,
        rw: rw == 'Semua' ? '...' : rw,
        rt: rt == 'Semua' ? '...' : rt,
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateFormDataManualPdf(String kelompokName) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);

      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getFormDataManual(kelompokName, rt, rw);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateFormDataManual(data: data);

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateForm3Pdf(String kelompokName) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);

      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getForm3Data(kelompokName, rt, rw);

      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generateForm3Perincian(data: data);

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generatePotensiWargaPdf(String kelompokName) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final region = ref.read(regionProvider);
      final rw = ref.read(reportRwProvider);
      final pkkRw = rw == 'Semua' ? '...' : rw;
      final tahun = DateTime.now().year.toString();

      final repo = ref.read(reportRepositoryProvider);
      final data = await repo.getPotensiWargaData(kelompokName);

      final rt = ref.read(reportRtProvider);
      final pdfService = ref.read(pdfPerincianServiceProvider);
      final pdfBytes = await pdfService.generatePotensiWargaPdfPerincian(
        data: {
          'rows': data,
          'rt': rt == 'Semua' ? '...' : rt,
          'rw': pkkRw,
          'kelurahan': region.kelurahan,
          'kecamatan': region.kecamatan,
          'tahun': tahun,
          'bulan': ref.read(reportBulanProvider),
          'periode': ref.read(reportBulanProvider),
          'kelompok': kelompokName,
        },
      );

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Uint8List> generateBlankPdf(String formType) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final pdfService = ref.read(pdfBlankServiceProvider);
      Uint8List pdfBytes;

      switch (formType) {
        case 'rekap_pkk':
          pdfBytes = await pdfService.generateBlankFormRekap();
          break;
        case 'profil_penduduk':
          pdfBytes = await pdfService.generateBlankFormProfilUsia();
          break;
        case 'potensi_warga':
          pdfBytes = await pdfService.generateBlankFormDataPotensiWarga();
          break;
        case 'ibu_hamil':
          pdfBytes = await pdfService.generateBlankFormIbuHamil();
          break;
        case 'form1':
          final region = ref.read(regionProvider);
          pdfBytes = await pdfService.generateBlankForm1(
            kabupaten: region.kotaKab,
            kecamatan: region.kecamatan,
            kelurahan: region.kelurahan,
          );
          break;
        case 'form2':
          pdfBytes = await pdfService.generateBlankForm2();
          break;
        case 'form3':
          pdfBytes = await pdfService.generateBlankForm3();
          break;
        case 'data_manual':
          pdfBytes = await pdfService.generateBlankFormDataManual();
          break;
        default:
          throw Exception('Tipe form tidak dikenali');
      }

      state = state.copyWith(isLoading: false);
      return pdfBytes;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

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
        targetKaders = allList
            .where((map) => map['rw'] == currentUser.rw)
            .toList();
      } else if (currentUser.role == 'RT') {
        targetKaders = allList
            .where(
              (map) =>
                  map['rw'] == currentUser.rw && map['rt'] == currentUser.rt,
            )
            .toList();
      } else if (currentUser.role == 'KADER') {
        targetKaders = allList
            .where((map) => map['kelompok_dawis'] == currentUser.kelompokDawis)
            .toList();
      }
    }

    final allowedNames = targetKaders
        .map(
          (k) => (k['kelompok_dawis'] ?? '')
              .toLowerCase()
              .replaceAll(' ', '')
              .replaceAll('.', ''),
        )
        .toList();

    final form1Kaders = List<Map<String, dynamic>>.from(
      dataForm1['kelompokList'] ?? [],
    );

    final filteredNames = <String>[];
    for (var f1 in form1Kaders) {
      final f1Name = (f1['namaKelompok'] as String)
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll('.', '');
      final isAllowed = allowedNames.any(
        (allowed) => allowed.startsWith(f1Name) || f1Name.startsWith(allowed),
      );
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
      final pdfService = ref.read(pdfRingkasanServiceProvider);

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
        int totalBalita = 0,
            totalAnak = 0,
            totalRemaja = 0,
            totalDewasa = 0,
            totalLansia = 0;
        int totalKeluarga = 0, totalPus = 0, totalMow = 0, totalMop = 0;
        int totalIud = 0,
            totalImplant = 0,
            totalSuntik = 0,
            totalPil = 0,
            totalKondom = 0,
            totalKb = 0;
        int totalTial = 0,
            totalIat = 0,
            totalIas = 0,
            totalHamil = 0,
            totalBukanKb = 0;
        int totalKrtCount = 0;
        int totalKkCount = 0;

        for (var row in data['rows']) {
          totalKkCount++;
          if ((row['namaKrt'] as String).isNotEmpty) {
            totalKrtCount++;
          }
          totalL += _parseInt(row['L']);
          totalP += _parseInt(row['P']);
          totalJumlah += _parseInt(row['jumlah']);
          totalBalita += _parseInt(row['balita']);
          totalAnak += _parseInt(row['anak']);
          totalRemaja += _parseInt(row['remaja']);
          totalDewasa += _parseInt(row['dewasa']);
          totalLansia += _parseInt(row['lansia']);
          totalKeluarga += _parseInt(row['jumlahKeluarga']);
          totalPus += _parseInt(row['pus']);
          totalMow += _parseInt(row['mow']);
          totalMop += _parseInt(row['mop']);
          totalIud += _parseInt(row['iud']);
          totalImplant += _parseInt(row['implant']);
          totalSuntik += _parseInt(row['suntik']);
          totalPil += _parseInt(row['pil']);
          totalKondom += _parseInt(row['kondom']);
          totalKb += _parseInt(row['jumlahKb']);
          totalTial += _parseInt(row['tial']);
          totalIat += _parseInt(row['iat']);
          totalIas += _parseInt(row['ias']);
          totalHamil += _parseInt(row['hamil']);
          totalBukanKb += _parseInt(row['jumlahBukanKb']);
        }

        ringkasanRows.add({
          'no': globalIndex++,
          'namaKrt': totalKrtCount.toString(),
          'namaKk': totalKkCount.toString(),
          'L': totalL,
          'P': totalP,
          'jumlah': totalJumlah,
          'balita': totalBalita,
          'anak': totalAnak,
          'remaja': totalRemaja,
          'dewasa': totalDewasa,
          'lansia': totalLansia,
          'jumlahKeluarga': totalKeluarga,
          'pus': totalPus,
          'mow': totalMow,
          'mop': totalMop,
          'iud': totalIud,
          'implant': totalImplant,
          'suntik': totalSuntik,
          'pil': totalPil,
          'kondom': totalKondom,
          'jumlahKb': totalKb,
          'tial': totalTial,
          'iat': totalIat,
          'ias': totalIas,
          'hamil': totalHamil,
          'jumlahBukanKb': totalBukanKb,
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
        'isRingkasan': true,
      };

      final pdfBytes = await pdfService.generateForm3Ringkasan(
        data: ringkasanData,
      );

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
      final pdfService = ref.read(pdfRingkasanServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;
      int globalIndex = 1;

      for (var name in allowedNames) {
        final data = await repo.getRekapPKK(name);
        if (data['rows'] == null || (data['rows'] as List).isEmpty) continue;

        int krtCount = (data['rows'] as List).length;
        int totalKk = 0, jiwaLaki = 0, jiwaPerempuan = 0;
        int balitaLaki = 0, balitaPerempuan = 0;
        int remaja = 0, praLansia = 0, lansia = 0;
        int pus = 0, wus = 0, ibuHamil = 0, ibuMenyusui = 0;
        int buta = 0, berkebutuhanKhusus = 0;
        int rumahSehat = 0,
            rumahTidakSehat = 0,
            punyaTempatSampah = 0,
            punyaSpal = 0,
            punyaJamban = 0,
            tempelStiker = 0;
        int pdam = 0, sumur = 0, dll = 0;
        int beras = 0, nonBeras = 0;
        int up2k = 0, pekarangan = 0, industri = 0, kerja = 0;

        for (var r in data['rows']) {
          totalKk += _parseInt(r['jmlKk']);
          jiwaLaki += _parseInt(r['jiwaLaki']);
          jiwaPerempuan += _parseInt(r['jiwaPerempuan']);
          balitaLaki += _parseInt(r['balitaLaki']);
          balitaPerempuan += _parseInt(r['balitaPerempuan']);
          remaja += _parseInt(r['remaja']);
          praLansia += _parseInt(r['praLansia']);
          pus += _parseInt(r['pus']);
          wus += _parseInt(r['wus']);
          ibuHamil += _parseInt(r['ibuHamil']);
          ibuMenyusui += _parseInt(r['ibuMenyusui']);
          lansia += _parseInt(r['lansia']);
          buta += _parseInt(r['buta']);
          berkebutuhanKhusus += _parseInt(r['berkebutuhanKhusus']);
          rumahSehat += _parseInt(r['rumahSehat']);
          rumahTidakSehat += _parseInt(r['rumahTidakSehat']);
          punyaTempatSampah += _parseInt(r['punyaTempatSampah']);
          punyaSpal += _parseInt(r['punyaSpal']);
          punyaJamban += _parseInt(r['punyaJamban']);
          tempelStiker += _parseInt(r['tempelStiker']);
          pdam += _parseInt(r['sumberAirPdam']);
          sumur += _parseInt(r['sumberAirSumur']);
          dll += _parseInt(r['sumberAirLainnya']);
          beras += _parseInt(r['makananBeras']);
          nonBeras += _parseInt(r['makananNonBeras']);
          up2k += _parseInt(r['ikutUp2k']);
          pekarangan += _parseInt(r['pekarangan']);
          industri += _parseInt(r['industriRT']);
          kerja += _parseInt(r['kerjaBakti']);
        }

        final match = RegExp(r'\d+').firstMatch(name);
        String dasawismaNo = match != null
            ? match.group(0)!
            : globalIndex.toString();
        // Fallback if we can't extract kader RT
        final dataKader = await repo.getForm3Data(name, rt, rw);
        final kaderRt = dataKader['rt']?.toString() ?? pkkRt;

        ringkasanRows.add({
          'no': globalIndex++,
          'rt': kaderRt.isNotEmpty && kaderRt != 'Semua' ? kaderRt : pkkRt,
          'dasawisma': dasawismaNo,
          'jmlKrt': krtCount,
          'jmlKk': totalKk,
          'L': jiwaLaki,
          'P': jiwaPerempuan,
          'balitaL': balitaLaki,
          'balitaP': balitaPerempuan,
          'remaja': remaja,
          'pus': pus,
          'wus': wus,
          'ibuHamil': ibuHamil,
          'ibuMenyusui': ibuMenyusui,
          'praLansia': praLansia,
          'lansia': lansia,
          'buta': buta,
          'berkebutuhanKhusus': berkebutuhanKhusus,
          'rumahSehat': rumahSehat,
          'rumahTidakSehat': rumahTidakSehat,
          'punyaTempatSampah': punyaTempatSampah,
          'punyaSpal': punyaSpal,
          'punyaJamban': punyaJamban,
          'tempelStiker': tempelStiker,
          'sumberAirPdam': pdam,
          'sumberAirSumur': sumur,
          'sumberAirLainnya': dll,
          'makananBeras': beras,
          'makananNonBeras': nonBeras,
          'ikutUp2k': up2k,
          'pekarangan': pekarangan,
          'industriRT': industri,
          'kerjaBakti': kerja,
          'keterangan': '',
        });
      }

      final ringkasanData = {
        'rw': pkkRw,
        'kelurahan': region.kelurahan,
        'kecamatan': region.kecamatan,
        'kota': region.kotaKab,
        'rows': ringkasanRows,
        'tahun': DateTime.now().year.toString(),
      };

      final pdfBytes = await pdfService.generateRekapPkkPdf(
        namaKelompok: 'Semua Kelompok RT $pkkRt RW $pkkRw',
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
      final pdfService = ref.read(pdfRingkasanServiceProvider);
      final region = ref.read(regionProvider);

      final allowedNames = await _getFilteredKelompokNames();
      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      final List<Map<String, int>> perKelompokTotals = [];
      final List<String> namaKaderList = [];

      for (var name in allowedNames) {
        final data = await repo.getProfilPendudukData(name);

        final kaderName = (data['namaKader']?.toString() ?? '');
        if (kaderName.isNotEmpty) {
          namaKaderList.add(kaderName);
        }

        final keluargaList =
            (data['keluargaList'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (keluargaList.isEmpty) continue;

        final Map<String, int> kelTotals = {};
        for (var r in keluargaList) {
          for (var key in r.keys) {
            if (key != 'namaKeluarga') {
              kelTotals[key] = (kelTotals[key] ?? 0) + _parseInt(r[key]);
            }
          }
        }
        perKelompokTotals.add(kelTotals);
      }

      final bulan = ref.read(reportBulanProvider);
      final tahun = DateTime.now().year.toString();

      String formatKelompokNames(List<String> names) {
        if (names.isEmpty) return '';
        if (names.length == 1) return names.first.replaceFirst('.', ' ');
        
        String first = names.first;
        int lastDotIndex = first.lastIndexOf('.');
        if (lastDotIndex != -1) {
          String prefix = first.substring(0, lastDotIndex + 1).replaceFirst('.', ' ');
          List<String> suffixes = [];
          for (String name in names) {
            if (name.lastIndexOf('.') != -1) {
              suffixes.add(name.substring(name.lastIndexOf('.') + 1));
            } else {
              suffixes.add(name);
            }
          }
          return prefix + suffixes.join(', ');
        }
        return names.join(', ').replaceFirst('.', ' ');
      }

      final pdfBytes = await pdfService.generateProfilUsiaRingkasanPortraitPdf(
        perKelompokData: perKelompokTotals,
        namaKelompok: allowedNames.isNotEmpty
            ? formatKelompokNames(allowedNames)
            : 'Semua Kelompok RT $pkkRt RW $pkkRw',
        namaKader: namaKaderList.isNotEmpty ? namaKaderList.join(', ') : '',
        rt: pkkRt,
        rw: pkkRw,
        kelurahan: region.kelurahan,
        kecamatan: region.kecamatan,
        kota: region
            .kotaKab, // The parameter in PdfReportService is 'kota', not 'kabupaten'
        bulanTahun: '$bulan $tahun',
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
      final repo = ref.read(reportRepositoryProvider);
      final pdfService = ref.read(pdfRingkasanServiceProvider);
      
      final rt = ref.read(reportRtProvider);
      final rw = ref.read(reportRwProvider);
      final region = ref.read(regionProvider);
      final bulan = ref.read(reportBulanProvider);
      final tahun = DateTime.now().year.toString();

      String pkkRw = rw == 'Semua' ? '...' : rw;
      String pkkRt = rt == 'Semua' ? '...' : rt;

      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];

      for (var name in allowedNames) {
        final dataList = await repo.getPotensiWargaData(name);
        if (dataList.isEmpty) continue;

        final Map<String, int> sums = {};
        for (var r in dataList) {
          for (var key in r.keys) {
            if (key != 'namaWarga' && key != 'keterangan') {
              sums[key] = (sums[key] ?? 0) + _parseInt(r[key]);
            }
          }
        }

        final rowMap = <String, dynamic>{'namaWarga': name, 'keterangan': ''};
        rowMap.addAll(sums);
        ringkasanRows.add(rowMap);
      }

      if (ringkasanRows.isNotEmpty) {
        int remainder = ringkasanRows.length % 15;
        if (remainder != 0) {
          int needed = 15 - remainder;
          for (int i = 0; i < needed; i++) {
            ringkasanRows.add({});
          }
        }
      }
      final ringkasanData = {
        'rows': ringkasanRows,
        'rt': pkkRt,
        'rw': pkkRw,
        'kelurahan': region.kelurahan,
        'kecamatan': region.kecamatan,
        'tahun': tahun,
        'bulan': bulan,
        'periode': bulan,
      };

      final pdfBytes = await pdfService.generatePotensiWargaPdfRingkasan(
        data: ringkasanData,
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
      final pdfService = ref.read(pdfRingkasanServiceProvider);
      final allowedNames = await _getFilteredKelompokNames();
      List<Map<String, dynamic>> ringkasanRows = [];
      int globalIndex = 1;

      for (var name in allowedNames) {
        final dataList = await repo.getLampidData(name);
        if (dataList.isEmpty) continue;

        int hamil = 0,
            matiHamil = 0,
            matiMelahirkan = 0,
            matiNifas = 0,
            matiKelahiran = 0,
            matiLahirBayi = 0,
            matiBalita = 0;

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
          'hamil': hamil,
          'matiHamil': matiHamil,
          'matiMelahirkan': matiMelahirkan,
          'matiNifas': matiNifas,
          'matiKelahiran': matiKelahiran,
          'matiLahirBayi': matiLahirBayi,
          'matiBalita': matiBalita,
        });
      }

      if (ringkasanRows.isNotEmpty) {
        int remainder = ringkasanRows.length % 15;
        if (remainder != 0) {
          int needed = 15 - remainder;
          for (int i = 0; i < needed; i++) {
            ringkasanRows.add({});
          }
        }
      }

      final pdfBytes = await pdfService.generateLampidPdfRingkasan(
        mutasiList: ringkasanRows,
        namaKelompok:
            'Semua Kelompok RT ${rt == 'Semua' ? '...' : rt} RW ${rw == 'Semua' ? '...' : rw}',
        rt: rt == 'Semua' ? '...' : rt,
        rw: rw == 'Semua' ? '...' : rw,
        kelurahan: ref.read(regionProvider).kelurahan,
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
}

final reportControllerProvider =
    NotifierProvider<ReportController, ReportState>(() {
      return ReportController();
    });

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
