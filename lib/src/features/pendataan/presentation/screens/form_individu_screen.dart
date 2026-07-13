import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:dawis/core/database/local_db_helper.dart';
import '../../domain/entities/individu.dart';
import '../../domain/entities/krt.dart';
import '../../domain/entities/mutasi.dart';
import '../providers/individu_provider.dart';
import '../providers/keluarga_provider.dart';
import '../providers/krt_provider.dart';
import '../providers/mutasi_provider.dart';

class FormIndividuScreen extends ConsumerStatefulWidget {
  final String keluargaId;
  final String? individuId;
  final String? jenisMutasi;

  const FormIndividuScreen({
    super.key,
    required this.keluargaId,
    this.individuId,
    this.jenisMutasi,
  });

  @override
  ConsumerState<FormIndividuScreen> createState() => _FormIndividuScreenState();
}

class _FormIndividuScreenState extends ConsumerState<FormIndividuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String? _selectedKeluargaId;

  // ── Bagian 1: Biodata Dasar ──
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _noTlpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatKtpController = TextEditingController();
  String _hubunganKeluarga = 'Kepala Keluarga';
  String _statusDgnKrt = 'Kepala Rumah Tangga';
  String _jenisKelamin = 'Laki-laki';
  String _agama = 'Islam';
  bool _punyaAkteKelahiran = false;
  final _noAkteController = TextEditingController();

  // ── Bagian 2: Demografi Sosial ──
  String _statusPerkawinan = 'Belum Kawin';
  String _pendidikanTerakhir = 'Tidak/Belum Sekolah';
  String _pekerjaan = 'Belum/Tidak Bekerja';
  String? _jenisBantuan;
  final _tglBantuanController = TextEditingController();
  final _lamaBantuanController = TextEditingController();
  final _jumlahBantuanController = TextEditingController();
  final _makananPokokController = TextEditingController();

  // ── Bagian 3: Kesehatan & 3 Buta ──
  bool _isButaHuruf = false;
  bool _isButaAngka = false;
  bool _isButaBahasa = false;
  final _berkebutuhanKhususController = TextEditingController();
  bool _punyaBpjs = false;
  bool _isBpjsKesehatan = false;
  bool _isBpjsKetenagakerjaan = false;
  bool _aktifPosyandu = false;
  final _frekuensiPosyanduController = TextEditingController();
  bool _isIbuMenyusui = false;
  String _statusYatimPiatu = 'Tidak';

  // ── Bagian Tambahan: Kegiatan Warga ──
  bool _ikutKerjaBakti = false;
  bool _isIkutUp2k = false;
  bool _isIndustriRumahTangga = false;

  // ── Bagian 4: Keluarga Berencana ──
  String? _metodeKb;
  String? _alasanBukanKb;

  // ── Options ──
  final List<String> _hubunganOptions = [
    'Kepala Keluarga',
    'Istri',
    'Anak',
    'Menantu',
    'Cucu',
    'Orang Tua',
    'Mertua',
    'Kakak',
    'Adik',
    'Famili Lain',
    'Pembantu',
    'Lainnya',
  ];

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
    'Kepercayaan Lain',
  ];

  final List<String> _yatimPiatuOptions = [
    'Tidak',
    'Yatim',
    'Piatu',
    'Yatim Piatu',
  ];

  final List<String> _pendidikanOptions = [
    'Tidak/Belum Sekolah',
    'SD/MI',
    'SMP/MTs',
    'SMA/SMK/MA',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];

  final List<String> _pekerjaanOptions = [
    'Belum/Tidak Bekerja',
    'PNS',
    'TNI/POLRI',
    'Karyawan Swasta',
    'Wiraswasta',
    'Petani',
    'Buruh',
    'Pensiunan',
    'Ibu Rumah Tangga',
    'Pelajar/Mahasiswa',
    'Lainnya',
  ];

  final List<String> _bantuanSosialOptions = [
    'PKH',
    'BPNT / Program Sembako',
    'PBI JK/KIS',
    'PIP',
    'BLT',
    'BST',
    'Program Bantuan Atensi',
    'BANTUAN PANGAN',
  ];

  final List<String> _metodeKbOptions = [
    'MOW/Steril Wanita',
    'MOP/Steril Pria',
    'IUD/Spiral/AKDR',
    'Implant/Susuk',
    'Suntik',
    'Pil',
    'Kondom',
  ];

  final List<String> _alasanBukanKbOptions = ['TIAL', 'IAT', 'IAS', 'Hamil'];

  String? _getJenisBpjs() {
    List<String> list = [];
    if (_isBpjsKesehatan) list.add('BPJS KESEHATAN');
    if (_isBpjsKetenagakerjaan) list.add('BPJS KETENAGA KERJAAN');
    return list.isEmpty ? null : list.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _selectedKeluargaId = widget.keluargaId.isEmpty ? null : widget.keluargaId;
    _nikController.addListener(_onNikChanged);
    if (widget.individuId != null) {
      _loadData();
    }
  }

  String _ensureValidOption(
    String? value,
    List<String> options,
    String defaultValue,
  ) {
    if (value == null || value.isEmpty) return defaultValue;
    if (options.contains(value)) return value;

    // Custom mappings
    final upperValue = value.toUpperCase();
    if (upperValue == 'KK') {
      if (options.contains('Kepala Keluarga')) return 'Kepala Keluarga';
      if (options.contains('Kepala Rumah Tangga')) return 'Kepala Rumah Tangga';
    }
    if (upperValue == 'ISTRI' && options.contains('Istri')) return 'Istri';
    if (upperValue == 'ANAK' && options.contains('Anak')) return 'Anak';

    // Case-insensitive match
    for (final option in options) {
      if (option.toLowerCase() == value.toLowerCase()) return option;
    }
    return defaultValue;
  }

  Future<void> _fetchParentsIfAnak() async {
    if (_hubunganKeluarga.toLowerCase() != 'anak') return;

    final assignedKeluargaId = _selectedKeluargaId ?? widget.keluargaId;
    if (assignedKeluargaId.isNotEmpty) {
      final repo = ref.read(individuRepositoryProvider);
      final parents = await repo.getParentsNames(assignedKeluargaId);
      if (mounted) {
        setState(() {
          if (parents['nama_ayah'] != null &&
              _namaAyahController.text.isEmpty) {
            _namaAyahController.text = parents['nama_ayah']!;
          }
          if (parents['nama_ibu'] != null && _namaIbuController.text.isEmpty) {
            _namaIbuController.text = parents['nama_ibu']!;
          }
        });
      }
    }
  }

  Future<void> _loadData() async {
    final individu = await ref.read(
      individuByIdProvider(widget.individuId!).future,
    );
    if (individu != null && mounted) {
      setState(() {
        _nikController.text = individu.nik;
        _namaController.text = individu.namaLengkap;
        _namaAyahController.text = individu.namaAyah ?? '';
        _namaIbuController.text = individu.namaIbu ?? '';
        _noTlpController.text = individu.noTlp ?? '';
        _tempatLahirController.text = individu.tempatLahir;
        _tanggalLahirController.text = individu.tanggalLahir;
        _alamatKtpController.text = individu.alamatKtp ?? '';
        _tglBantuanController.text = individu.tglBantuan ?? '';
        _lamaBantuanController.text = individu.lamaBantuan ?? '';
        _jumlahBantuanController.text = individu.jumlahBantuan ?? '';
        _berkebutuhanKhususController.text =
            individu.kriteriaBerkebutuhanKhusus ?? '';
        _makananPokokController.text = individu.makananPokok ?? '';
        _noAkteController.text = individu.noAkteKelahiran ?? '';
        _frekuensiPosyanduController.text = individu.frekuensiPosyandu ?? '';

        _hubunganKeluarga = _ensureValidOption(
          individu.hubunganKeluarga,
          _hubunganOptions,
          'Kepala Keluarga',
        );

        final statusKrtOptions = [
          'Kepala Rumah Tangga',
          'Istri',
          'Anak',
          'Menantu',
          'Cucu',
          'Orang Tua',
          'Mertua',
          'Kakak',
          'Adik',
          'Famili Lain',
          'Lainnya',
        ];
        _statusDgnKrt = _ensureValidOption(
          individu.statusDgnKrt,
          statusKrtOptions,
          'Kepala Rumah Tangga',
        );

        _jenisKelamin = _ensureValidOption(individu.jenisKelamin, [
          'Laki-laki',
          'Perempuan',
        ], 'Laki-laki');
        _statusPerkawinan = _ensureValidOption(
          individu.statusPerkawinan,
          _statusKawinOptions,
          'Belum Kawin',
        );
        _pendidikanTerakhir = _ensureValidOption(
          individu.pendidikanTerakhir,
          _pendidikanOptions,
          'Tidak/Belum Sekolah',
        );
        _pekerjaan = _ensureValidOption(
          individu.pekerjaan,
          _pekerjaanOptions,
          'Belum/Tidak Bekerja',
        );

        _jenisBantuan = _ensureValidOption(
          individu.jenisBantuan,
          _bantuanSosialOptions,
          '',
        );
        if (_jenisBantuan == '') _jenisBantuan = null; // optional

        _metodeKb = _ensureValidOption(individu.metodeKb, _metodeKbOptions, '');
        if (_metodeKb == '') _metodeKb = null;

        _alasanBukanKb = _ensureValidOption(
          individu.alasanBukanKb,
          _alasanBukanKbOptions,
          '',
        );
        if (_alasanBukanKb == '') _alasanBukanKb = null;

        _isButaHuruf = individu.isButaHuruf == 1;
        _isButaAngka = individu.isButaAngka == 1;
        _isButaBahasa = individu.isButaBahasa == 1;
        _agama = _ensureValidOption(individu.agama, _agamaOptions, 'Islam');
        _punyaAkteKelahiran = individu.punyaAkteKelahiran == 1;
        _punyaBpjs = individu.punyaBpjs == 1;

        if (individu.jenisBpjs != null) {
          final jbpjs = individu.jenisBpjs!.toUpperCase();
          _isBpjsKesehatan = jbpjs.contains('BPJS KESEHATAN');
          _isBpjsKetenagakerjaan = jbpjs.contains('BPJS KETENAGA KERJAAN');
        }

        _aktifPosyandu = individu.aktifPosyandu == 1;
        _ikutKerjaBakti = individu.ikutKerjaBakti == 1;
        _isIbuMenyusui = individu.isIbuMenyusui == 1;
        _isIkutUp2k = individu.isIkutUp2k == 1;
        _isIndustriRumahTangga = individu.isIndustriRumahTangga == 1;
        _statusYatimPiatu = _ensureValidOption(
          individu.statusYatimPiatu,
          _yatimPiatuOptions,
          'Tidak',
        );
      });

      // Coba fetch nama ayah dan ibu jika sebelumnya kosong
      await _fetchParentsIfAnak();
    }
  }

  void _onNikChanged() {
    final nik = _nikController.text;
    if (nik.length == 16) {
      _parseNik(nik);
    }
  }

  void _parseNik(String nik) {
    if (nik.length < 12) return;
    try {
      final dobStr = nik.substring(6, 12);
      int dd = int.parse(dobStr.substring(0, 2));
      int mm = int.parse(dobStr.substring(2, 4));
      int yy = int.parse(dobStr.substring(4, 6));

      String gender = 'Laki-laki';
      if (dd > 40) {
        gender = 'Perempuan';
        dd -= 40;
      }

      final currentYearLast2 = DateTime.now().year % 100;
      int fullYear = yy > currentYearLast2 ? 1900 + yy : 2000 + yy;

      final dob = DateTime(fullYear, mm, dd);
      setState(() {
        _jenisKelamin = gender;
        _tanggalLahirController.text =
            '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      // Abaikan jika gagal parse
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _namaAyahController.dispose();
    _namaIbuController.dispose();
    _noTlpController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatKtpController.dispose();
    _makananPokokController.dispose();
    _berkebutuhanKhususController.dispose();
    _tglBantuanController.dispose();
    _lamaBantuanController.dispose();
    _jumlahBantuanController.dispose();
    _noAkteController.dispose();
    _frekuensiPosyanduController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pilihTanggalBantuan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tglBantuanController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final assignedKeluargaId = _selectedKeluargaId ?? widget.keluargaId;
      final individu = Individu(
        id: widget.individuId ?? _uuid.v4(),
        idKeluarga: assignedKeluargaId,
        namaLengkap: _namaController.text,
        nik: _nikController.text,
        hubunganKeluarga: _hubunganKeluarga,
        statusDgnKrt: _statusDgnKrt,
        jenisKelamin: _jenisKelamin,
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _tanggalLahirController.text,
        statusPerkawinan: _statusPerkawinan,
        pendidikanTerakhir: _pendidikanTerakhir,
        pekerjaan: _pekerjaan,
        noTlp: _noTlpController.text.trim(),
        alamatKtp: _alamatKtpController.text.trim(),
        alamatDomisili: '',
        jenisBantuan: _jenisBantuan,
        tglBantuan: _tglBantuanController.text.isEmpty
            ? null
            : _tglBantuanController.text,
        lamaBantuan: _lamaBantuanController.text.isEmpty
            ? null
            : _lamaBantuanController.text,
        jumlahBantuan: _jumlahBantuanController.text.isEmpty
            ? null
            : _jumlahBantuanController.text,
        metodeKb: _metodeKb,
        alasanBukanKb: _alasanBukanKb,
        isButaHuruf: _isButaHuruf ? 1 : 0,
        isButaAngka: _isButaAngka ? 1 : 0,
        isButaBahasa: _isButaBahasa ? 1 : 0,
        kriteriaBerkebutuhanKhusus: _berkebutuhanKhususController.text.isEmpty
            ? null
            : _berkebutuhanKhususController.text,
        makananPokok: _makananPokokController.text.isEmpty
            ? null
            : _makananPokokController.text,
        agama: _agama,
        punyaAkteKelahiran: _punyaAkteKelahiran ? 1 : 0,
        noAkteKelahiran: _noAkteController.text.isEmpty
            ? null
            : _noAkteController.text,
        punyaBpjs: _punyaBpjs ? 1 : 0,
        jenisBpjs: _getJenisBpjs(),
        aktifPosyandu: _aktifPosyandu ? 1 : 0,
        frekuensiPosyandu: _frekuensiPosyanduController.text.isEmpty
            ? null
            : _frekuensiPosyanduController.text,
        ikutKerjaBakti: _ikutKerjaBakti ? 1 : 0,
        isIbuMenyusui: _isIbuMenyusui ? 1 : 0,
        isIkutUp2k: _isIkutUp2k ? 1 : 0,
        isIndustriRumahTangga: _isIndustriRumahTangga ? 1 : 0,
        statusYatimPiatu: _statusYatimPiatu == 'Tidak'
            ? null
            : _statusYatimPiatu,
        namaAyah: _namaAyahController.text.isEmpty
            ? null
            : _namaAyahController.text,
        namaIbu: _namaIbuController.text.isEmpty
            ? null
            : _namaIbuController.text,
        isSynced: 0,
      );

      final repo = ref.read(individuRepositoryProvider);

      if (widget.individuId != null) {
        await repo.updateIndividu(individu);
      } else {
        await repo.insertIndividu(individu);

        if (widget.jenisMutasi != null && widget.jenisMutasi!.isNotEmpty) {
          final db = await LocalDbHelper.database;
          final res = await db.rawQuery(
            '''
            SELECT krt.id_bangunan 
            FROM keluarga 
            JOIN krt ON keluarga.id_krt = krt.id 
            WHERE keluarga.id = ?
          ''',
            [assignedKeluargaId],
          );

          final resolvedIdBangunan = res.isNotEmpty
              ? res.first['id_bangunan'] as String
              : '';

          final mutasi = Mutasi(
            id: const Uuid().v4(),
            idIndividuAsal: individu.id,
            namaOrang: individu.namaLengkap,
            jenisMutasi: widget.jenisMutasi!,
            tanggalMutasi: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            asal: '',
            tujuan: '',
            keterangan: 'Pencatatan Otomatis',
            idBangunan: resolvedIdBangunan,
          );
          await ref.read(mutasiRepositoryProvider).insertMutasi(mutasi);
          ref.invalidate(allMutasiProvider);
          ref.invalidate(mutasiFilteredProvider);
        }
      }

      // Refresh list
      ref.invalidate(individuByKeluargaProvider(assignedKeluargaId));

      // Update KRT jika individu adalah Kepala Keluarga
      final upperStatus = individu.hubunganKeluarga.toUpperCase();
      final upperStatusKrt = individu.statusDgnKrt?.toUpperCase() ?? '';
      if (upperStatus == "KK" ||
          upperStatus == "KEPALA KELUARGA" ||
          upperStatus == "KEPALA RUMAH TANGGA" ||
          upperStatusKrt == "KK" ||
          upperStatusKrt == "KEPALA KELUARGA" ||
          upperStatusKrt == "KEPALA RUMAH TANGGA") {
        final keluargaRepo = ref.read(keluargaRepositoryProvider);
        final keluarga = await keluargaRepo.getKeluargaById(assignedKeluargaId);
        if (keluarga != null) {
          final krtRepo = ref.read(krtRepositoryProvider);
          final krt = await krtRepo.getKrtById(keluarga.idKrt);
          if (krt != null) {
            final updatedKrt = Krt(
              id: krt.id,
              idBangunan: krt.idBangunan,
              namaKrt: individu.namaLengkap,
              nikKrt: individu.nik,
              noKkKrt: krt.noKkKrt,
              isSynced: krt.isSynced,
            );
            await krtRepo.updateKrt(updatedKrt);
            ref.invalidate(krtByBangunanProvider(krt.idBangunan));
            ref.invalidate(krtByIdProvider(krt.id));
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.individuId != null
                  ? 'Data Individu Berhasil Diperbarui!'
                  : 'Data Individu Berhasil Disimpan!',
            ),
          ),
        );
        if (widget.keluargaId.isEmpty) {
          context.go('/dashboard');
        } else {
          context.pop();
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menyimpan! Periksa kembali isian form yang ditandai merah.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Data Individu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.keluargaId.isEmpty) ...[
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    final repo = ref.read(keluargaRepositoryProvider);
                    return await repo.searchKeluargaWithKrtName(
                      textEditingValue.text,
                    );
                  },
                  displayStringForOption: (Map<String, dynamic> option) {
                    final anggota = option['anggota_keluarga'];
                    final suffix =
                        (anggota != null && anggota.toString().isNotEmpty)
                        ? ' (Anggota: $anggota)'
                        : '';
                    return 'No KK: ${option['no_kk']} - ${option['nama_krt']}$suffix';
                  },
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      _selectedKeluargaId = selection['keluarga_id'];
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            labelText: 'Cari & Pilih Kartu Keluarga (KK)',
                            hintText: 'Ketik NIK atau Nama...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _selectedKeluargaId != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                          validator: (val) {
                            if (widget.keluargaId.isEmpty &&
                                _selectedKeluargaId == null) {
                              return 'Silakan pilih KK dari hasil pencarian';
                            }
                            return null;
                          },
                        );
                      },
                ),
                const SizedBox(height: 16),
              ],
              // ── Bagian 1: Biodata Dasar ──
              ExpansionTile(
                title: const Text(
                  'Bagian 1: Biodata Dasar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                initiallyExpanded: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  TextFormField(
                    controller: _nikController,
                    decoration: const InputDecoration(
                      labelText: 'NIK',
                      hintText: 'Masukkan 16 digit NIK',
                    ),
                    maxLength: 16,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'NIK wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noTlpController,
                    decoration: const InputDecoration(
                      labelText: 'No. Tlp / WhatsApp (Opsional)',
                      hintText: 'Contoh: 081234567890',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _hubunganKeluarga,
                    decoration: const InputDecoration(
                      labelText: 'Hubungan Keluarga',
                    ),
                    items: _hubunganOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => _hubunganKeluarga = val);
                        await _fetchParentsIfAnak();
                      }
                    },
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaAyahController,
                    decoration: const InputDecoration(labelText: 'Nama Ayah'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaIbuController,
                    decoration: const InputDecoration(labelText: 'Nama Ibu'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _statusDgnKrt,
                    decoration: const InputDecoration(
                      labelText: 'Status Hubungan dengan KRT',
                    ),
                    items:
                        [
                              'Kepala Rumah Tangga',
                              'Istri',
                              'Anak',
                              'Menantu',
                              'Cucu',
                              'Orang Tua',
                              'Mertua',
                              'Kakak',
                              'Adik',
                              'Famili Lain',
                              'Lainnya',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _statusDgnKrt = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _agama,
                    decoration: const InputDecoration(labelText: 'Agama'),
                    items: _agamaOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _agama = val!),
                  ),
                  const SizedBox(height: 16),
                  // Jenis Kelamin - Radio
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: InputBorder.none,
                    ),
                    child: RadioGroup<String>(
                      groupValue: _jenisKelamin,
                      onChanged: (val) => setState(() => _jenisKelamin = val!),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Laki-laki'),
                              value: 'Laki-laki',
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Perempuan'),
                              value: 'Perempuan',
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tempatLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Lahir',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tanggalLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'yyyy-MM-dd',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _pilihTanggalLahir,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Tanggal lahir wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alamatKtpController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Sesuai KTP',
                      hintText: 'Masukkan alamat lengkap sesuai KTP',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Alamat KTP wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Memiliki Akte Kelahiran'),
                    value: _punyaAkteKelahiran,
                    onChanged: (val) =>
                        setState(() => _punyaAkteKelahiran = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_punyaAkteKelahiran) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noAkteController,
                      decoration: const InputDecoration(
                        labelText: 'No Akte Kelahiran',
                        hintText: 'Masukkan no akte',
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 8),

              // ── Bagian 2: Demografi Sosial ──
              ExpansionTile(
                title: const Text(
                  'Bagian 2: Demografi Sosial',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _statusPerkawinan,
                    decoration: const InputDecoration(
                      labelText: 'Status Perkawinan',
                    ),
                    items: _statusKawinOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _statusPerkawinan = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _pendidikanTerakhir,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Terakhir',
                    ),
                    items: _pendidikanOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _pendidikanTerakhir = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _pekerjaan,
                    decoration: const InputDecoration(labelText: 'Pekerjaan'),
                    items: _pekerjaanOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _pekerjaan = val!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _makananPokokController,
                    decoration: const InputDecoration(
                      labelText: 'Makanan Pokok (Opsional)',
                      hintText: 'Contoh: Nasi, Jagung',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 8),

              // ── Bagian 3: Kesehatan & 3 Buta ──
              ExpansionTile(
                title: const Text(
                  'Bagian 3: Kesehatan & 3 Buta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  CheckboxListTile(
                    title: const Text('Buta Huruf'),
                    value: _isButaHuruf,
                    onChanged: (val) =>
                        setState(() => _isButaHuruf = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Buta Angka'),
                    value: _isButaAngka,
                    onChanged: (val) =>
                        setState(() => _isButaAngka = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('Buta Bahasa Indonesia'),
                    value: _isButaBahasa,
                    onChanged: (val) =>
                        setState(() => _isButaBahasa = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _berkebutuhanKhususController,
                    decoration: const InputDecoration(
                      labelText: 'Berkebutuhan Khusus (Opsional)',
                      hintText: 'Isi jenis jika ada, kosongkan jika tidak',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _statusYatimPiatu,
                    decoration: const InputDecoration(
                      labelText: 'Status Yatim / Piatu (Khusus Anak)',
                    ),
                    items: _yatimPiatuOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _statusYatimPiatu = val!),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Kepesertaan BPJS'),
                    value: _punyaBpjs,
                    onChanged: (val) =>
                        setState(() => _punyaBpjs = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_punyaBpjs) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('BPJS KESEHATAN'),
                            value: _isBpjsKesehatan,
                            onChanged: (val) =>
                                setState(() => _isBpjsKesehatan = val ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('BPJS KETENAGA KERJAAN'),
                            value: _isBpjsKetenagakerjaan,
                            onChanged: (val) => setState(
                              () => _isBpjsKetenagakerjaan = val ?? false,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Aktif Dalam Kegiatan Posyandu'),
                    value: _aktifPosyandu,
                    onChanged: (val) =>
                        setState(() => _aktifPosyandu = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_aktifPosyandu) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _frekuensiPosyanduController,
                      decoration: const InputDecoration(
                        labelText: 'Frekuensi Posyandu',
                        hintText: 'Contoh: 3 kali',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_jenisKelamin == 'Perempuan') ...[
                    CheckboxListTile(
                      title: const Text('Sedang Menyusui'),
                      value: _isIbuMenyusui,
                      onChanged: (val) =>
                          setState(() => _isIbuMenyusui = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // ── Bagian 4: Keluarga Berencana (KB) ──
              ExpansionTile(
                title: const Text(
                  'Bagian 4: Keluarga Berencana (KB)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _metodeKb,
                    decoration: const InputDecoration(
                      labelText: 'Metode KB (Opsional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('- Tidak Ada -'),
                      ),
                      ..._metodeKbOptions.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _metodeKb = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _alasanBukanKb,
                    decoration: const InputDecoration(
                      labelText: 'Alasan Bukan Peserta KB (Opsional)',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('- Tidak Ada -'),
                      ),
                      ..._alasanBukanKbOptions.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _alasanBukanKb = val),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 8),

              // ── Bagian 5: Bantuan Sosial (Opsional) ──
              ExpansionTile(
                title: const Text(
                  'Bagian 5: Bantuan Sosial (Opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _jenisBantuan,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Bantuan',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('- Tidak Ada -'),
                      ),
                      ..._bantuanSosialOptions.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _jenisBantuan = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tglBantuanController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Bantuan',
                      hintText: 'yyyy-MM-dd',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _pilihTanggalBantuan,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lamaBantuanController,
                    decoration: const InputDecoration(
                      labelText: 'Lama Bantuan',
                      hintText: 'Contoh: 6 bulan, 1 tahun',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jumlahBantuanController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Bantuan',
                      hintText: 'Contoh: Rp 500.000, 1 Paket Sembako',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 8),

              // ── Bagian 6: Data Kegiatan Warga ──
              ExpansionTile(
                title: const Text(
                  'Bagian 6: Data Kegiatan Warga',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                maintainState: true,
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  CheckboxListTile(
                    title: const Text('Mengikuti Kerja Bakti'),
                    value: _ikutKerjaBakti,
                    onChanged: (val) =>
                        setState(() => _ikutKerjaBakti = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Mengikuti Kegiatan UP2K'),
                    value: _isIkutUp2k,
                    onChanged: (val) =>
                        setState(() => _isIkutUp2k = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Memiliki Industri Rumah Tangga'),
                    value: _isIndustriRumahTangga,
                    onChanged: (val) =>
                        setState(() => _isIndustriRumahTangga = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 24),

              // ── Tombol Simpan ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _simpanData,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Data'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
