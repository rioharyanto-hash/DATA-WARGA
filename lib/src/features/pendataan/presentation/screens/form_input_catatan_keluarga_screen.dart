import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/individu_provider.dart';
import '../../domain/entities/individu.dart';

class FormInputCatatanKeluargaScreen extends ConsumerStatefulWidget {
  final String individuId;
  const FormInputCatatanKeluargaScreen({super.key, required this.individuId});

  @override
  ConsumerState<FormInputCatatanKeluargaScreen> createState() =>
      _FormInputCatatanKeluargaScreenState();
}

class _FormInputCatatanKeluargaScreenState
    extends ConsumerState<FormInputCatatanKeluargaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _pekerjaanController = TextEditingController();
  final _kebutuhanKhususController = TextEditingController();
  final _makananPokokController = TextEditingController();

  String _statusPerkawinan = 'Belum Kawin';
  String _agama = 'Islam';
  String _pendidikan = 'Tidak/Belum Sekolah';
  int _ikutKerjaBakti = 0;
  int _isIkutUp2k = 0;
  int _isButaHuruf = 0;

  bool _isInitialized = false;

  final List<String> _statusKawinOptions = [
    'Belum Kawin',
    'Kawin',
    'Cerai Hidup',
    'Cerai Mati',
  ];
  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
    'Lainnya',
  ];
  final List<String> _pendidikanOptions = [
    'Tidak/Belum Sekolah',
    'Belum Tamat SD/Sederajat',
    'Tamat SD/Sederajat',
    'SLTP/Sederajat',
    'SLTA/Sederajat',
    'Diploma I/II',
    'Akademi/Diploma III/S.Muda',
    'Diploma IV/Strata I',
    'Strata II',
    'Strata III',
  ];

  String _ensureValidOption(
    String? value,
    List<String> options,
    String defaultValue,
  ) {
    if (value == null || value.isEmpty) return defaultValue;
    if (options.contains(value)) return value;

    // Custom mappings for mismatching data from other screens
    final upperValue = value.toUpperCase();
    if (upperValue.contains('SD') || upperValue.contains('MI')) {
      return 'Tamat SD/Sederajat';
    }
    if (upperValue.contains('SMP') || upperValue.contains('MTS')) {
      return 'SLTP/Sederajat';
    }
    if (upperValue.contains('SMA') ||
        upperValue.contains('SMK') ||
        upperValue.contains('MA')) {
      return 'SLTA/Sederajat';
    }
    if (upperValue.contains('D1') ||
        upperValue.contains('D2') ||
        upperValue.contains('D3')) {
      return 'Akademi/Diploma III/S.Muda';
    }
    if (upperValue.contains('S1') || upperValue.contains('D4')) {
      return 'Diploma IV/Strata I';
    }
    if (upperValue.contains('S2')) return 'Strata II';
    if (upperValue.contains('S3')) return 'Strata III';

    for (final option in options) {
      if (option.toLowerCase() == value.toLowerCase()) return option;
    }
    return defaultValue;
  }

  void _initData(Individu individu) {
    if (_isInitialized) return;
    _pekerjaanController.text = individu.pekerjaan;
    _kebutuhanKhususController.text = individu.kriteriaBerkebutuhanKhusus ?? '';
    _makananPokokController.text = individu.makananPokok ?? '';

    _statusPerkawinan = _ensureValidOption(
      individu.statusPerkawinan,
      _statusKawinOptions,
      'Belum Kawin',
    );
    _agama = _ensureValidOption(individu.agama, _agamaOptions, 'Islam');
    _pendidikan = _ensureValidOption(
      individu.pendidikanTerakhir,
      _pendidikanOptions,
      'Tidak/Belum Sekolah',
    );

    _ikutKerjaBakti = individu.ikutKerjaBakti ?? 0;
    _isIkutUp2k = individu.isIkutUp2k ?? 0;
    _isButaHuruf = individu.isButaHuruf ?? 0;

    _isInitialized = true;
  }

  @override
  void dispose() {
    _pekerjaanController.dispose();
    _kebutuhanKhususController.dispose();
    _makananPokokController.dispose();
    super.dispose();
  }

  void _save(Individu original) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Individu(
      id: original.id,
      idKeluarga: original.idKeluarga,
      namaLengkap: original.namaLengkap,
      nik: original.nik,
      hubunganKeluarga: original.hubunganKeluarga,
      jenisKelamin: original.jenisKelamin,
      tempatLahir: original.tempatLahir,
      tanggalLahir: original.tanggalLahir,
      statusPerkawinan: _statusPerkawinan,
      pendidikanTerakhir: _pendidikan,
      pekerjaan: _pekerjaanController.text,
      agama: _agama,
      kriteriaBerkebutuhanKhusus: _kebutuhanKhususController.text,
      makananPokok: _makananPokokController.text,
      ikutKerjaBakti: _ikutKerjaBakti,
      isIkutUp2k: _isIkutUp2k,
      isButaHuruf: _isButaHuruf,

      // Preserve other fields
      alamatKtp: original.alamatKtp,
      alamatDomisili: original.alamatDomisili,
      jenisBantuan: original.jenisBantuan,
      tglBantuan: original.tglBantuan,
      lamaBantuan: original.lamaBantuan,
      jumlahBantuan: original.jumlahBantuan,
      metodeKb: original.metodeKb,
      alasanBukanKb: original.alasanBukanKb,
      isButaAngka: original.isButaAngka,
      isButaBahasa: original.isButaBahasa,
      punyaAkteKelahiran: original.punyaAkteKelahiran,
      noAkteKelahiran: original.noAkteKelahiran,
      punyaBpjs: original.punyaBpjs,
      jenisBpjs: original.jenisBpjs,
      aktifPosyandu: original.aktifPosyandu,
      frekuensiPosyandu: original.frekuensiPosyandu,
      isIbuMenyusui: original.isIbuMenyusui,
      isIndustriRumahTangga: original.isIndustriRumahTangga,
      isSynced: 0,
    );

    final repo = ref.read(individuRepositoryProvider);
    await repo.insertIndividu(updated);

    // Refresh the provider
    ref.invalidate(individuByIdProvider(widget.individuId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan Keluarga berhasil disimpan!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final individuAsync = ref.watch(individuByIdProvider(widget.individuId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Catatan Keluarga'), elevation: 0),
      body: individuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (individu) {
          if (individu == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          _initData(individu);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card (Readonly)
                  Card(
                    color: Colors.green.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama: ${individu.namaLengkap}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'NIK: ${individu.nik.isEmpty ? '-' : individu.nik}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'TTL: ${individu.tempatLahir}, ${individu.tanggalLahir}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text('L/P: ${individu.jenisKelamin}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context
                                      .push(
                                        '/form-individu-edit/${individu.idKeluarga}/${individu.id}',
                                      )
                                      .then((_) {
                                        ref.invalidate(
                                          individuByIdProvider(individu.id),
                                        );
                                      });
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                tooltip: 'Ubah Data Dasar',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Data Dasar Anggota',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _statusPerkawinan,
                    decoration: const InputDecoration(
                      labelText: 'Status Perkawinan',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusKawinOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _statusPerkawinan = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _agama,
                    decoration: const InputDecoration(
                      labelText: 'Agama',
                      border: OutlineInputBorder(),
                    ),
                    items: _agamaOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _agama = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _pendidikan,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan',
                      border: OutlineInputBorder(),
                    ),
                    items: _pendidikanOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _pendidikan = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pekerjaanController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kebutuhanKhususController,
                    decoration: const InputDecoration(
                      labelText: 'Berkebutuhan Khusus (Bila Ada)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Kegiatan / Catatan Khusus',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _makananPokokController,
                    decoration: const InputDecoration(
                      labelText: 'Makanan Pokok (Pangan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Ikut Gotong Royong / Kerja Bakti'),
                    value: _ikutKerjaBakti == 1,
                    onChanged: (val) =>
                        setState(() => _ikutKerjaBakti = val ? 1 : 0),
                  ),
                  SwitchListTile(
                    title: const Text('Ikut Koperasi / UP2K'),
                    value: _isIkutUp2k == 1,
                    onChanged: (val) =>
                        setState(() => _isIkutUp2k = val ? 1 : 0),
                  ),
                  SwitchListTile(
                    title: const Text('Buta Huruf'),
                    value: _isButaHuruf == 1,
                    onChanged: (val) =>
                        setState(() => _isButaHuruf = val ? 1 : 0),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: const Color(0xFF10B981),
                            side: const BorderSide(color: Color(0xFF10B981)),
                          ),
                          child: const Text('BATAL'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _save(individu),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('SIMPAN'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
