import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/mutasi.dart';
import '../providers/mutasi_provider.dart';

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
  final bool _isInitialized = false;

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
      ref.invalidate(mutasiByBangunanProvider(widget.bangunanId));

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
