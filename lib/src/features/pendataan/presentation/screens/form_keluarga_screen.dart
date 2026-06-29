import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/keluarga.dart';
import '../../domain/entities/krt.dart';
import '../../domain/entities/bangunan.dart';
import '../providers/keluarga_provider.dart';
import '../providers/krt_provider.dart';
import '../providers/bangunan_provider.dart';

class FormKeluargaScreen extends ConsumerStatefulWidget {
  final String? krtId;
  final String? keluargaId;
  final String? jenisMutasi;

  const FormKeluargaScreen({
    super.key,
    this.krtId,
    this.keluargaId,
    this.jenisMutasi,
  });

  @override
  ConsumerState<FormKeluargaScreen> createState() => _FormKeluargaScreenState();
}

class _FormKeluargaScreenState extends ConsumerState<FormKeluargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers
  final _noKkController = TextEditingController();

  // Dropdown State
  String _statusVisitasi = 'Sudah Dikunjungi';
  String? _existingKrtId;

  // Untuk penambahan dari Mutasi
  String? _selectedBangunanId;
  List<Bangunan> _bangunanList = [];

  final List<String> _statusVisitasiOptions = [
    'Sudah Dikunjungi',
    'Menolak',
    'Pindah',
  ];

  @override
  void initState() {
    super.initState();
    _existingKrtId = widget.krtId?.isEmpty == true ? null : widget.krtId;
    _loadExistingData();
    if (widget.krtId?.isEmpty == true) {
      _loadBangunanList();
    }
  }

  Future<void> _loadBangunanList() async {
    final list = await ref.read(bangunanRepositoryProvider).getAllBangunan();
    setState(() {
      _bangunanList = list;
    });
  }

  Future<void> _loadExistingData() async {
    if (widget.keluargaId != null) {
      final repository = ref.read(keluargaRepositoryProvider);
      final keluarga = await repository.getKeluargaById(widget.keluargaId!);
      if (keluarga != null) {
        setState(() {
          _existingKrtId = keluarga.idKrt;
          _noKkController.text = keluarga.noKk;

          String sv = keluarga.statusVisitasi;
          if (sv.endsWith('.')) sv = sv.substring(0, sv.length - 1);
          _statusVisitasi = _statusVisitasiOptions.contains(sv)
              ? sv
              : _statusVisitasiOptions.first;
        });
      }
    } else {
      _existingKrtId = widget.krtId;
    }
  }

  @override
  void dispose() {
    _noKkController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      if (widget.krtId?.isEmpty == true && _selectedBangunanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih Bangunan terlebih dahulu'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menyimpan data...')));

      try {
        final repo = ref.read(keluargaRepositoryProvider);
        String finalKrtId = _existingKrtId ?? '';

        if (widget.krtId?.isEmpty == true) {
          // Buat KRT Baru
          finalKrtId = const Uuid().v4();
          final krt = Krt(
            id: finalKrtId,
            idBangunan: _selectedBangunanId!,
            namaKrt: 'KRT Baru',
            nikKrt: '-',
            noKkKrt: _noKkController.text,
            isSynced: 0,
          );
          await ref.read(krtRepositoryProvider).insertKrt(krt);
          ref.invalidate(krtByBangunanProvider(_selectedBangunanId!));
        }

        final keluarga = Keluarga(
          id: widget.keluargaId ?? _uuid.v4(),
          idKrt: finalKrtId,
          noKk: _noKkController.text,
          statusVisitasi: _statusVisitasi,
          isSynced: 0,
        );

        if (widget.keluargaId != null) {
          await repo.updateKeluarga(keluarga);
        } else {
          await repo.insertKeluarga(keluarga);
        }

        // Refresh list
        ref.invalidate(keluargaByKrtProvider(finalKrtId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data Keluarga Berhasil Disimpan!')),
          );
          if (widget.krtId?.isEmpty == true) {
            // Setelah KRT dan Keluarga dibuat dari menu Datang, lanjutkan ke Form Individu
            context.pushReplacement('/form-individu-datang/${keluarga.id}');
          } else {
            context.pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildOutlinedInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isRequired = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: isRequired
              ? (value) => value == null || value.isEmpty ? 'Wajib diisi' : null
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Form Data Keluarga'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.krtId?.isEmpty == true) ...[
                      Autocomplete<Bangunan>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return _bangunanList.where((b) {
                            final address =
                                '${b.namaBangunan} RT ${b.rt}/RW ${b.rw} ${b.kelompokDawis}';
                            return address.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        displayStringForOption: (Bangunan option) =>
                            '${option.namaBangunan} (Kel. ${option.kelompokDawis} RT ${option.rt}/RW ${option.rw})',
                        onSelected: (Bangunan selection) {
                          setState(() {
                            _selectedBangunanId = selection.id;
                          });
                        },
                        fieldViewBuilder:
                            (
                              context,
                              controller,
                              focusNode,
                              onEditingComplete,
                            ) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: InputDecoration(
                                  labelText: 'Cari & Pilih Bangunan Tujuan',
                                  hintText: 'Ketik Kelompok, RT atau RW...',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.home),
                                  suffixIcon: _selectedBangunanId != null
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : null,
                                ),
                                validator: (val) {
                                  if (widget.krtId?.isEmpty == true &&
                                      _selectedBangunanId == null) {
                                    return 'Pilih Bangunan dari hasil pencarian';
                                  }
                                  return null;
                                },
                              );
                            },
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Informasi Keluarga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi data Keluarga (KK) di bawah ini.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    _buildOutlinedInput(
                      'Nomor KK',
                      _noKkController,
                      isNumber: true,
                      isRequired: true,
                      maxLength: 16,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Status Visitasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _statusVisitasi,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                      ),
                      items: _statusVisitasiOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _statusVisitasi = val);
                        }
                      },
                    ),
                  ],
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _simpanData,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
