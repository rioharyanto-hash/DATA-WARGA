import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/mutasi.dart';
import '../../domain/entities/individu.dart';
import '../providers/mutasi_provider.dart';
import '../providers/individu_provider.dart';
import '../providers/keluarga_provider.dart';
import '../providers/bangunan_provider.dart';
import '../providers/krt_provider.dart';

class FormMutasiScreen extends ConsumerStatefulWidget {
  final String bangunanId;
  final String? idIndividuAsal;
  final String? defaultNama;
  final String? defaultNik;
  final String? defaultJenisMutasi;

  const FormMutasiScreen({
    super.key,
    required this.bangunanId,
    this.idIndividuAsal,
    this.defaultNama,
    this.defaultNik,
    this.defaultJenisMutasi,
  });

  @override
  ConsumerState<FormMutasiScreen> createState() => _FormMutasiScreenState();
}

class _FormMutasiScreenState extends ConsumerState<FormMutasiScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _jenisMutasi;
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tanggalMutasiController = TextEditingController();
  final _asalController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _sebabKematianController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _namaSuamiController = TextEditingController();
  String? _statusIbu;

  final List<String> _jenisMutasiList = [
    'Lahir',
    'Meninggal',
    'Pindah',
    'Datang',
    'Status Ibu (Hamil/Nifas)',
  ];

  final List<String> _statusIbuList = ['Hamil', 'Melahirkan', 'Nifas'];

  String? _idBangunan;
  
  Individu? _asalIndividu;
  bool _isKk = false;
  bool _isKrt = false;
  List<Individu> _kkCandidates = [];
  List<Individu> _krtCandidates = [];
  String? _selectedReplacementKkId;
  String? _selectedReplacementKrtId;

  @override
  void initState() {
    super.initState();
    if (widget.defaultJenisMutasi != null &&
        _jenisMutasiList.contains(widget.defaultJenisMutasi)) {
      _jenisMutasi = widget.defaultJenisMutasi;
    }
    if (widget.defaultNama != null) {
      _namaController.text = widget.defaultNama!;
    }
    if (widget.defaultNik != null) {
      _nikController.text = widget.defaultNik!;
    }
    _loadIndividuDetails();
  }

  Future<void> _loadIndividuDetails() async {
    if (widget.idIndividuAsal == null) return;
    
    final individuRepo = ref.read(individuRepositoryProvider);
    final individu = await individuRepo.getIndividuById(widget.idIndividuAsal!);
    if (individu == null || !mounted) return;

    setState(() {
      _asalIndividu = individu;
      
      final hk = individu.hubunganKeluarga.toUpperCase();
      _isKk = (hk == 'KK' || hk == 'KEPALA KELUARGA');
      
      final stKrt = (individu.statusDgnKrt ?? '').toUpperCase();
      _isKrt = (stKrt == 'KEPALA RUMAH TANGGA' || stKrt == 'KK' || stKrt == 'KEPALA KELUARGA');
    });

    if (_isKk) {
      final candidates = await individuRepo.getPenggantiKkCandidates(individu.idKeluarga, individu.id);
      if (mounted) setState(() => _kkCandidates = candidates);
    }

    if (_isKrt) {
      final candidates = await individuRepo.getPenggantiKrtCandidates(widget.bangunanId, individu.id);
      if (mounted) setState(() => _krtCandidates = candidates);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _tanggalMutasiController.dispose();
    _asalController.dispose();
    _tujuanController.dispose();
    _keteranganController.dispose();
    _sebabKematianController.dispose();
    _namaIbuController.dispose();
    _namaSuamiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalMutasiController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jenisMutasi == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jenis mutasi')));
      return;
    }

    if (_idBangunan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menemukan data bangunan dari warga ini'),
        ),
      );
      return;
    }

    try {
      final mutasi = Mutasi(
        id: const Uuid().v4(),
        idBangunan: widget.bangunanId,
        idIndividuAsal: widget.idIndividuAsal,
        jenisMutasi: _jenisMutasi!,
        namaOrang: _namaController.text,
        nik: _nikController.text.isEmpty ? null : _nikController.text,
        tanggalMutasi: _tanggalMutasiController.text,
        asal: _asalController.text.isEmpty ? null : _asalController.text,
        tujuan: _tujuanController.text.isEmpty ? null : _tujuanController.text,
        sebabKematian: _sebabKematianController.text.isEmpty
            ? null
            : _sebabKematianController.text,
        namaIbu: _namaIbuController.text.isEmpty
            ? null
            : _namaIbuController.text,
        namaSuami: _namaSuamiController.text.isEmpty
            ? null
            : _namaSuamiController.text,
        statusIbu: _statusIbu,
        keterangan: _keteranganController.text.isEmpty
            ? null
            : _keteranganController.text,
      );

      await ref.read(mutasiRepositoryProvider).insertMutasi(mutasi);
      
      final individuRepo = ref.read(individuRepositoryProvider);
      
      if (_jenisMutasi == 'Meninggal' || _jenisMutasi == 'Pindah') {
        if (_isKk && _selectedReplacementKkId != null) {
          final newKk = await individuRepo.getIndividuById(_selectedReplacementKkId!);
          if (newKk != null) {
            final updatedKk = Individu(
              id: newKk.id,
              idKeluarga: newKk.idKeluarga,
              namaLengkap: newKk.namaLengkap,
              nik: newKk.nik,
              hubunganKeluarga: 'Kepala Keluarga',
              statusDgnKrt: newKk.statusDgnKrt,
              jenisKelamin: newKk.jenisKelamin,
              tempatLahir: newKk.tempatLahir,
              tanggalLahir: newKk.tanggalLahir,
              statusPerkawinan: newKk.statusPerkawinan,
              pendidikanTerakhir: newKk.pendidikanTerakhir,
              pekerjaan: newKk.pekerjaan,
              noTlp: newKk.noTlp,
              alamatKtp: newKk.alamatKtp,
              alamatDomisili: newKk.alamatDomisili,
              jenisBantuan: newKk.jenisBantuan,
              tglBantuan: newKk.tglBantuan,
              lamaBantuan: newKk.lamaBantuan,
              jumlahBantuan: newKk.jumlahBantuan,
              metodeKb: newKk.metodeKb,
              alasanBukanKb: newKk.alasanBukanKb,
              isButaHuruf: newKk.isButaHuruf,
              isButaAngka: newKk.isButaAngka,
              isButaBahasa: newKk.isButaBahasa,
              kriteriaBerkebutuhanKhusus: newKk.kriteriaBerkebutuhanKhusus,
              statusYatimPiatu: newKk.statusYatimPiatu,
              makananPokok: newKk.makananPokok,
              agama: newKk.agama,
              punyaAkteKelahiran: newKk.punyaAkteKelahiran,
              noAkteKelahiran: newKk.noAkteKelahiran,
              punyaBpjs: newKk.punyaBpjs,
              jenisBpjs: newKk.jenisBpjs,
              aktifPosyandu: newKk.aktifPosyandu,
              frekuensiPosyandu: newKk.frekuensiPosyandu,
              ikutKerjaBakti: newKk.ikutKerjaBakti,
              isIbuMenyusui: newKk.isIbuMenyusui,
              isIkutUp2k: newKk.isIkutUp2k,
              isIndustriRumahTangga: newKk.isIndustriRumahTangga,
              isSynced: newKk.isSynced,
            );
            await individuRepo.updateIndividu(updatedKk);
          }
        }
        
        if (_isKrt && _selectedReplacementKrtId != null && _asalIndividu != null) {
          final newKrt = await individuRepo.getIndividuById(_selectedReplacementKrtId!);
          if (newKrt != null) {
            final updatedKrt = Individu(
              id: newKrt.id,
              idKeluarga: newKrt.idKeluarga,
              namaLengkap: newKrt.namaLengkap,
              nik: newKrt.nik,
              hubunganKeluarga: newKrt.hubunganKeluarga,
              statusDgnKrt: 'Kepala Rumah Tangga',
              jenisKelamin: newKrt.jenisKelamin,
              tempatLahir: newKrt.tempatLahir,
              tanggalLahir: newKrt.tanggalLahir,
              statusPerkawinan: newKrt.statusPerkawinan,
              pendidikanTerakhir: newKrt.pendidikanTerakhir,
              pekerjaan: newKrt.pekerjaan,
              noTlp: newKrt.noTlp,
              alamatKtp: newKrt.alamatKtp,
              alamatDomisili: newKrt.alamatDomisili,
              jenisBantuan: newKrt.jenisBantuan,
              tglBantuan: newKrt.tglBantuan,
              lamaBantuan: newKrt.lamaBantuan,
              jumlahBantuan: newKrt.jumlahBantuan,
              metodeKb: newKrt.metodeKb,
              alasanBukanKb: newKrt.alasanBukanKb,
              isButaHuruf: newKrt.isButaHuruf,
              isButaAngka: newKrt.isButaAngka,
              isButaBahasa: newKrt.isButaBahasa,
              kriteriaBerkebutuhanKhusus: newKrt.kriteriaBerkebutuhanKhusus,
              statusYatimPiatu: newKrt.statusYatimPiatu,
              makananPokok: newKrt.makananPokok,
              agama: newKrt.agama,
              punyaAkteKelahiran: newKrt.punyaAkteKelahiran,
              noAkteKelahiran: newKrt.noAkteKelahiran,
              punyaBpjs: newKrt.punyaBpjs,
              jenisBpjs: newKrt.jenisBpjs,
              aktifPosyandu: newKrt.aktifPosyandu,
              frekuensiPosyandu: newKrt.frekuensiPosyandu,
              ikutKerjaBakti: newKrt.ikutKerjaBakti,
              isIbuMenyusui: newKrt.isIbuMenyusui,
              isIkutUp2k: newKrt.isIkutUp2k,
              isIndustriRumahTangga: newKrt.isIndustriRumahTangga,
              isSynced: newKrt.isSynced,
            );
            await individuRepo.updateIndividu(updatedKrt);
            
            final keluargaRepo = ref.read(keluargaRepositoryProvider);
            final keluarga = await keluargaRepo.getKeluargaById(_asalIndividu!.idKeluarga);
            if (keluarga != null) {
               final krtRepo = ref.read(krtRepositoryProvider);
               await krtRepo.updateKrtNameAndNik(keluarga.idKrt, newKrt.namaLengkap, newKrt.nik);
            }
          }
        }
        
        ref.invalidate(individuByIdProvider);
        ref.invalidate(individuByKeluargaProvider);
        ref.invalidate(krtByBangunanProvider);
      }

      ref.invalidate(mutasiByBangunanProvider(widget.bangunanId));
      ref.invalidate(allMutasiProvider);
      ref.invalidate(mutasiFilteredProvider);

      // Data individu tetap dipertahankan sesuai permintaan agar masuk ke laporan LAMPID.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data mutasi berhasil disimpan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Mutasi & Ibu Hamil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _jenisMutasi,
                decoration: const InputDecoration(labelText: 'Jenis Mutasi'),
                items: _jenisMutasiList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _jenisMutasi = newValue;
                  });
                },
                validator: (value) => value == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Orang'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK (Opsional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalMutasiController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Mutasi (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _asalController,
                decoration: const InputDecoration(labelText: 'Asal (Opsional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tujuanController,
                decoration: const InputDecoration(
                  labelText: 'Tujuan (Opsional)',
                ),
              ),
              if (_jenisMutasi == 'Meninggal') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sebabKematianController,
                  decoration: const InputDecoration(
                    labelText: 'Sebab Kematian (Opsional)',
                  ),
                ),
              ],
              if (_jenisMutasi == 'Lahir' ||
                  _jenisMutasi == 'Meninggal' ||
                  _jenisMutasi == 'Status Ibu (Hamil/Nifas)') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaIbuController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Ibu (Opsional - Jika Bayi/Balita)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaSuamiController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Suami/Ayah (Opsional)',
                  ),
                ),
              ],
              if (_jenisMutasi == 'Lahir' ||
                  _jenisMutasi == 'Status Ibu (Hamil/Nifas)') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _statusIbu,
                  decoration: const InputDecoration(
                    labelText: 'Status Ibu (Opsional)',
                  ),
                  items: _statusIbuList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _statusIbu = newValue;
                    });
                  },
                ),
              ],
              if ((_jenisMutasi == 'Meninggal' || _jenisMutasi == 'Pindah') && _isKk && _kkCandidates.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedReplacementKkId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Pengganti Kepala Keluarga (KK)',
                    helperText: 'Wajib dipilih karena warga yang mutasi adalah KK',
                  ),
                  items: _kkCandidates.map((individu) {
                    return DropdownMenuItem<String>(
                      value: individu.id,
                      child: Text(individu.namaLengkap),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedReplacementKkId = newValue;
                      // Jika dia juga memilih KRT pengganti tapi blm terpilih, bisa otomatis,
                      // tapi kita biarkan user milih saja di dropdown bawah.
                    });
                  },
                  validator: (value) => value == null ? 'Wajib pilih pengganti KK' : null,
                ),
              ],
              if ((_jenisMutasi == 'Meninggal' || _jenisMutasi == 'Pindah') && _isKrt && (_krtCandidates.isNotEmpty || (_isKk && _selectedReplacementKkId != null))) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedReplacementKrtId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Pengganti KRT',
                    helperText: 'Pilih KK di bangunan ini yang akan menjadi KRT baru',
                  ),
                  items: [
                    if (_isKk && _selectedReplacementKkId != null) 
                      // Tambahkan calon KK yang baru saja dipilih
                      DropdownMenuItem<String>(
                        value: _selectedReplacementKkId,
                        child: Text('${_kkCandidates.firstWhere((e) => e.id == _selectedReplacementKkId).namaLengkap} (KK Baru)'),
                      ),
                    ..._krtCandidates.map((individu) {
                      return DropdownMenuItem<String>(
                        value: individu.id,
                        child: Text(individu.namaLengkap),
                      );
                    }).toList(),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedReplacementKrtId = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Wajib pilih pengganti KRT' : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (Opsional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
