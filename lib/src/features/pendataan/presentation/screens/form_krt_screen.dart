import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/krt.dart';
import '../providers/krt_provider.dart';

class FormKrtScreen extends ConsumerStatefulWidget {
  final String? bangunanId;
  final String? krtId;

  const FormKrtScreen({super.key, this.bangunanId, this.krtId});

  @override
  ConsumerState<FormKrtScreen> createState() => _FormKrtScreenState();
}

class _FormKrtScreenState extends ConsumerState<FormKrtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _noKkController = TextEditingController();

  String? _existingBangunanId;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (widget.krtId != null) {
      final repository = ref.read(krtRepositoryProvider);
      final krt = await repository.getKrtById(widget.krtId!);
      if (krt != null) {
        setState(() {
          _existingBangunanId = krt.idBangunan;
          _namaController.text = krt.namaKrt;
          _nikController.text = krt.nikKrt;
          _noKkController.text = krt.noKkKrt;
        });
      }
    } else {
      _existingBangunanId = widget.bangunanId;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noKkController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menyimpan data...')));

      try {
        final krt = Krt(
          id: widget.krtId ?? _uuid.v4(),
          idBangunan: _existingBangunanId ?? '',
          namaKrt: _namaController.text,
          nikKrt: _nikController.text,
          noKkKrt: _noKkController.text,
          isSynced: 0,
        );

        final repo = ref.read(krtRepositoryProvider);
        if (widget.krtId != null) {
          await repo.updateKrt(krt);
        } else {
          await repo.insertKrt(krt);
        }

        ref.invalidate(krtByBangunanProvider(_existingBangunanId!));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data KRT Berhasil Disimpan!')),
          );
          context.pop();
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
        title: const Text('Form Data KRT'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Kepala Rumah Tangga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi data Kepala Rumah Tangga (KRT) di bawah ini.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    _buildOutlinedInput(
                      'Nama KRT',
                      _namaController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildOutlinedInput(
                      'NIK KRT',
                      _nikController,
                      isNumber: true,
                      isRequired: true,
                      maxLength: 16,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildOutlinedInput(
                      'Nomor KK KRT',
                      _noKkController,
                      isNumber: true,
                      isRequired: true,
                      maxLength: 16,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
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
