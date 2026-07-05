import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/mutasi.dart';
import '../../domain/entities/individu.dart';
import '../providers/mutasi_provider.dart';
import '../providers/individu_provider.dart';

class FormMutasiMasterScreen extends ConsumerStatefulWidget {
  const FormMutasiMasterScreen({super.key});

  @override
  ConsumerState<FormMutasiMasterScreen> createState() =>
      _FormMutasiMasterScreenState();
}

class _FormMutasiMasterScreenState
    extends ConsumerState<FormMutasiMasterScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _jenisMutasi;
  final List<String> _jenisMutasiList = [
    'Lahir',
    'Datang',
    'Meninggal',
    'Pindah',
    'Status Ibu (Hamil/Nifas)',
  ];

  Individu? _selectedIndividu;
  final _tanggalMutasiController = TextEditingController();
  final _asalController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _sebabKematianController = TextEditingController();
  String? _statusIbu;
  final List<String> _statusIbuList = ['Hamil', 'Melahirkan', 'Nifas'];

  bool _isLoading = false;

  @override
  void dispose() {
    _tanggalMutasiController.dispose();
    _asalController.dispose();
    _tujuanController.dispose();
    _keteranganController.dispose();
    _sebabKematianController.dispose();
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
        _tanggalMutasiController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveMutasi() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIndividu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih warga terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = const Uuid().v4();
      final date = _tanggalMutasiController.text.isEmpty
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : _tanggalMutasiController.text;

      final mutasi = Mutasi(
        id: id,
        idIndividuAsal: _selectedIndividu!.id,
        namaOrang: _selectedIndividu!.namaLengkap,
        jenisMutasi: _jenisMutasi!,
        tanggalMutasi: date,
        asal: _asalController.text,
        tujuan: _tujuanController.text,
        keterangan: _jenisMutasi == 'Meninggal'
            ? 'Sebab Kematian: ${_sebabKematianController.text}'
            : (_jenisMutasi == 'Status Ibu (Hamil/Nifas)'
                  ? 'Status: $_statusIbu'
                  : _keteranganController.text),
        idBangunan:
            '', // Kita tidak punya bangunan ID secara langsung dari individu di sini,
        // tapi repository sebenarnya bisa join untuk mencari bangunan jika dibutuhkan di kemudian hari.
      );

      await ref.read(mutasiRepositoryProvider).insertMutasi(mutasi);
      ref.invalidate(allMutasiProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mutasi berhasil disimpan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Mutasi Ibu Hamil & Warga'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _jenisMutasi,
                decoration: const InputDecoration(
                  labelText: 'Pilih Jenis Mutasi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _jenisMutasiList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _jenisMutasi = value;
                    _selectedIndividu = null;
                  });
                },
                validator: (val) => val == null ? 'Pilih jenis mutasi' : null,
              ),
              const SizedBox(height: 24),

              if (_jenisMutasi == 'Lahir') ...[
                const Text(
                  'Untuk menambahkan anak yang baru lahir, Anda harus mendaftarkannya ke dalam Kartu Keluarga (KK) orang tuanya.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/form-individu-lahir');
                  },
                  icon: const Icon(Icons.child_friendly),
                  label: const Text('Lanjut Isi Form Data Anak Lahir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ] else if (_jenisMutasi == 'Datang') ...[
                const Text(
                  'Untuk warga yang baru datang, Anda harus membuatkan Form Keluarga baru yang akan ditempatkan di sebuah Bangunan.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/form-keluarga-datang');
                  },
                  icon: const Icon(Icons.family_restroom),
                  label: const Text('Lanjut Buat Keluarga Datang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ] else if (_jenisMutasi != null) ...[
                // Meninggal, Pindah, Status Ibu
                Autocomplete<Individu>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    final repo = ref.read(individuRepositoryProvider);
                    return await repo.searchIndividu(textEditingValue.text);
                  },
                  displayStringForOption: (Individu option) =>
                      '${option.namaLengkap} - NIK: ${option.nik}',
                  onSelected: (Individu selection) {
                    setState(() {
                      _selectedIndividu = selection;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            labelText: 'Cari Nama Warga',
                            hintText: 'Ketik minimal 2 huruf...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _selectedIndividu != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                          validator: (val) {
                            if (_selectedIndividu == null) {
                              return 'Pilih warga dari hasil pencarian';
                            }
                            return null;
                          },
                        );
                      },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _tanggalMutasiController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal (Lahir/Wafat/Pindah/dll)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                if (_jenisMutasi == 'Pindah') ...[
                  TextFormField(
                    controller: _tujuanController,
                    decoration: const InputDecoration(
                      labelText: 'Pindah Ke (Tujuan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_jenisMutasi == 'Meninggal') ...[
                  TextFormField(
                    controller: _sebabKematianController,
                    decoration: const InputDecoration(
                      labelText: 'Sebab Kematian',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_jenisMutasi == 'Status Ibu (Hamil/Nifas)') ...[
                  DropdownButtonFormField<String>(
                    initialValue: _statusIbu,
                    decoration: const InputDecoration(
                      labelText: 'Status Kehamilan/Ibu',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusIbuList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _statusIbu = value),
                    validator: (val) => val == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _keteranganController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan Tambahan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _saveMutasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Data Mutasi'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
