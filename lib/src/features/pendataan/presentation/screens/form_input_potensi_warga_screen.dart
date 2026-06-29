import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/individu_provider.dart';
import '../../domain/entities/individu.dart';

class FormInputPotensiWargaScreen extends ConsumerStatefulWidget {
  final String individuId;
  const FormInputPotensiWargaScreen({super.key, required this.individuId});

  @override
  ConsumerState<FormInputPotensiWargaScreen> createState() =>
      _FormInputPotensiWargaScreenState();
}

class _FormInputPotensiWargaScreenState
    extends ConsumerState<FormInputPotensiWargaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _noAkteController = TextEditingController();
  final _metodeKbController = TextEditingController();
  final _alasanBukanKbController = TextEditingController();
  final _jenisBpjsController = TextEditingController();
  final _frekuensiPosyanduController = TextEditingController();

  int _punyaAkteKelahiran = 0;
  int _punyaBpjs = 0;
  int _aktifPosyandu = 0;
  int _isIbuMenyusui = 0;

  bool _isInitialized = false;

  void _initData(Individu individu) {
    if (_isInitialized) return;
    _noAkteController.text = individu.noAkteKelahiran ?? '';
    _metodeKbController.text = individu.metodeKb ?? '';
    _alasanBukanKbController.text = individu.alasanBukanKb ?? '';
    _jenisBpjsController.text = individu.jenisBpjs ?? '';
    _frekuensiPosyanduController.text = individu.frekuensiPosyandu ?? '';

    _punyaAkteKelahiran = individu.punyaAkteKelahiran ?? 0;
    _punyaBpjs = individu.punyaBpjs ?? 0;
    _aktifPosyandu = individu.aktifPosyandu ?? 0;
    _isIbuMenyusui = individu.isIbuMenyusui ?? 0;

    _isInitialized = true;
  }

  @override
  void dispose() {
    _noAkteController.dispose();
    _metodeKbController.dispose();
    _alasanBukanKbController.dispose();
    _jenisBpjsController.dispose();
    _frekuensiPosyanduController.dispose();
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
      statusPerkawinan: original.statusPerkawinan,
      pendidikanTerakhir: original.pendidikanTerakhir,
      pekerjaan: original.pekerjaan,

      punyaAkteKelahiran: _punyaAkteKelahiran,
      noAkteKelahiran: _noAkteController.text,
      punyaBpjs: _punyaBpjs,
      jenisBpjs: _jenisBpjsController.text,
      aktifPosyandu: _aktifPosyandu,
      frekuensiPosyandu: _frekuensiPosyanduController.text,
      metodeKb: _metodeKbController.text,
      alasanBukanKb: _alasanBukanKbController.text,
      isIbuMenyusui: _isIbuMenyusui,

      // Preserve other fields
      agama: original.agama,
      kriteriaBerkebutuhanKhusus: original.kriteriaBerkebutuhanKhusus,
      makananPokok: original.makananPokok,
      ikutKerjaBakti: original.ikutKerjaBakti,
      isIkutUp2k: original.isIkutUp2k,
      isButaHuruf: original.isButaHuruf,
      alamatKtp: original.alamatKtp,
      alamatDomisili: original.alamatDomisili,
      jenisBantuan: original.jenisBantuan,
      tglBantuan: original.tglBantuan,
      lamaBantuan: original.lamaBantuan,
      jumlahBantuan: original.jumlahBantuan,
      isButaAngka: original.isButaAngka,
      isButaBahasa: original.isButaBahasa,
      isIndustriRumahTangga: original.isIndustriRumahTangga,
      isSynced: 0,
    );

    final repo = ref.read(individuRepositoryProvider);
    await repo.insertIndividu(updated);

    ref.invalidate(individuByIdProvider(widget.individuId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Potensi Warga berhasil disimpan!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final individuAsync = ref.watch(individuByIdProvider(widget.individuId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Potensi & Kesja Warga'),
        elevation: 0,
      ),
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
                  Card(
                    color: Colors.amber.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          Text('NIK: ${individu.nik}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Administrasi & Asuransi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Punya Akte Kelahiran?'),
                    value: _punyaAkteKelahiran == 1,
                    onChanged: (val) =>
                        setState(() => _punyaAkteKelahiran = val ? 1 : 0),
                  ),
                  if (_punyaAkteKelahiran == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _noAkteController,
                        decoration: const InputDecoration(
                          labelText: 'No Akte Kelahiran',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  SwitchListTile(
                    title: const Text('Punya BPJS / Asuransi Kesehatan?'),
                    value: _punyaBpjs == 1,
                    onChanged: (val) =>
                        setState(() => _punyaBpjs = val ? 1 : 0),
                  ),
                  if (_punyaBpjs == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _jenisBpjsController,
                        decoration: const InputDecoration(
                          labelText:
                              'Jenis BPJS/Asuransi (Contoh: Mandiri/PBI)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                  const Divider(height: 32),
                  const Text(
                    'Kesehatan & KB',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aktif Posyandu?'),
                    value: _aktifPosyandu == 1,
                    onChanged: (val) =>
                        setState(() => _aktifPosyandu = val ? 1 : 0),
                  ),
                  if (_aktifPosyandu == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _frekuensiPosyanduController,
                        decoration: const InputDecoration(
                          labelText: 'Frekuensi Posyandu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  SwitchListTile(
                    title: const Text('Ibu Menyusui?'),
                    value: _isIbuMenyusui == 1,
                    onChanged: (val) =>
                        setState(() => _isIbuMenyusui = val ? 1 : 0),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _metodeKbController,
                    decoration: const InputDecoration(
                      labelText: 'Metode KB (Bila Ikut)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alasanBukanKbController,
                    decoration: const InputDecoration(
                      labelText: 'Alasan Bila Bukan PUS/Tidak KB',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                          ),
                          child: const Text('BATAL'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _save(individu),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
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
