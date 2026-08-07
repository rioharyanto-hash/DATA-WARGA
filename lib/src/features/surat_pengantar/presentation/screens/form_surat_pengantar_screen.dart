import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/surat_pengantar.dart';
import '../../data/repositories/surat_pengantar_repository.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormSuratPengantarScreen extends ConsumerStatefulWidget {
  final SuratPengantar? existingData;
  const FormSuratPengantarScreen({super.key, this.existingData});

  @override
  ConsumerState<FormSuratPengantarScreen> createState() =>
      _FormSuratPengantarScreenState();
}

class _FormSuratPengantarScreenState
    extends ConsumerState<FormSuratPengantarScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSearchingNik = false;

  late TextEditingController _noSuratController;
  late TextEditingController _tanggalSuratController;
  late TextEditingController _namaPemohonController;
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _keperluanController;

  @override
  void initState() {
    super.initState();
    _noSuratController = TextEditingController(
      text: widget.existingData?.noSurat ?? '',
    );

    // Set today's date if empty
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _tanggalSuratController = TextEditingController(
      text: widget.existingData?.tanggalSurat ?? today,
    );

    _namaPemohonController = TextEditingController(
      text: widget.existingData?.namaPemohon ?? '',
    );
    _nikController = TextEditingController(
      text: widget.existingData?.nik ?? '',
    );
    _alamatController = TextEditingController(
      text: widget.existingData?.alamat ?? '',
    );
    _keperluanController = TextEditingController(
      text: widget.existingData?.keperluan ?? '',
    );
  }

  @override
  void dispose() {
    _noSuratController.dispose();
    _tanggalSuratController.dispose();
    _namaPemohonController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _keperluanController.dispose();
    super.dispose();
  }

  Future<void> _searchNik(String nik) async {
    if (nik.length < 16) return;

    setState(() {
      _isSearchingNik = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('individu')
          .select(
            'nama_lengkap, alamat_domisili, alamat_ktp, keluarga(krt(bangunan(alamat_lengkap, rt, rw)))',
          )
          .eq('nik', nik)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _namaPemohonController.text =
              response['nama_lengkap']?.toString() ?? '';

          String alamat = '';
          final domisili = response['alamat_domisili']?.toString().trim() ?? '';
          final ktp = response['alamat_ktp']?.toString().trim() ?? '';

          if (domisili.isNotEmpty) {
            alamat = domisili;
          } else if (ktp.isNotEmpty) {
            alamat = ktp;
          } else {
            try {
              final bangunan = response['keluarga']['krt']['bangunan'];
              if (bangunan != null) {
                final almtLengkap =
                    bangunan['alamat_lengkap']?.toString().trim() ?? '';
                final rt = bangunan['rt']?.toString().trim() ?? '';
                final rw = bangunan['rw']?.toString().trim() ?? '';

                alamat = almtLengkap;
                if (rt.isNotEmpty || rw.isNotEmpty) {
                  alamat += ' RT $rt / RW $rw';
                }
              }
            } catch (e) {
              // Ignore if nested data is missing
            }
          }

          _alamatController.text = alamat;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data ditemukan, form telah diisi otomatis.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data NIK tidak ditemukan. Silakan isi manual.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan pencarian: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingNik = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(loggedInUserProvider);

      final surat = SuratPengantar(
        id: widget.existingData?.id ?? '',
        noSurat: _noSuratController.text.trim(),
        tanggalSurat: _tanggalSuratController.text.trim(),
        namaPemohon: _namaPemohonController.text.trim(),
        nik: _nikController.text.trim(),
        alamat: _alamatController.text.trim(),
        keperluan: _keperluanController.text.trim(),
        rt: user?.rt,
        rw: user?.rw,
      );

      await ref
          .read(suratPengantarRepositoryProvider)
          .saveSuratPengantar(surat);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Surat pengantar berhasil disimpan')),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.existingData == null
              ? 'Buat Surat Pengantar'
              : 'Edit Surat Pengantar',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4338CA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Surat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noSuratController,
                        decoration: _buildInputDecoration('Nomor Surat'),
                        validator: (v) =>
                            v!.isEmpty ? 'Nomor surat harus diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tanggalSuratController,
                        decoration: _buildInputDecoration(
                          'Tanggal Surat (dd-MM-yyyy)',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Tanggal surat harus diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Pemohon',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nikController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('NIK').copyWith(
                          suffixIcon: _isSearchingNik
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF4338CA),
                                  ),
                                  onPressed: () {
                                    if (_nikController.text.isNotEmpty) {
                                      _searchNik(_nikController.text.trim());
                                    }
                                  },
                                ),
                        ),
                        onChanged: (val) {
                          if (val.length == 16) {
                            _searchNik(val);
                          }
                        },
                        validator: (v) => v!.isEmpty ? 'NIK harus diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaPemohonController,
                        decoration: _buildInputDecoration('Nama Lengkap'),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama pemohon harus diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 2,
                        decoration: _buildInputDecoration('Alamat Lengkap'),
                        validator: (v) =>
                            v!.isEmpty ? 'Alamat harus diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keperluan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _keperluanController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          'Tujuan pembuatan surat',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Keperluan harus diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveData,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Data Surat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4338CA), width: 2),
      ),
    );
  }
}
