import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_user_provider.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _kelompokDawisController;
  late TextEditingController _namaController;
  late TextEditingController _idKaderController;
  late TextEditingController _nikController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _pendidikanTerakhirController;
  late TextEditingController _alamatController;
  late TextEditingController _rtController;
  late TextEditingController _rwController;
  late TextEditingController _kelurahanController;
  late TextEditingController _kecamatanController;
  late TextEditingController _propinsiController;
  late TextEditingController _kodePosController;
  late TextEditingController _alamatKtpController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;
  late TextEditingController _noRekeningBankController;
  late TextEditingController _npwpController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(loggedInUserProvider);
    _kelompokDawisController = TextEditingController(
      text: user?.kelompokDawis ?? '',
    );
    _namaController = TextEditingController(text: user?.nama ?? '');
    _idKaderController = TextEditingController(text: user?.idKader ?? '');
    _nikController = TextEditingController(text: user?.nik ?? '');
    _tempatLahirController = TextEditingController(
      text: user?.tempatLahir ?? '',
    );
    _tanggalLahirController = TextEditingController(
      text: user?.tanggalLahir ?? '',
    );
    _pendidikanTerakhirController = TextEditingController(
      text: user?.pendidikanTerakhir ?? '',
    );
    _alamatController = TextEditingController(text: user?.alamat ?? '');
    _rtController = TextEditingController(
      text: user?.rt?.isNotEmpty == true ? user!.rt!.padLeft(3, '0') : '',
    );
    _rwController = TextEditingController(
      text: user?.rw?.isNotEmpty == true ? user!.rw!.padLeft(3, '0') : '',
    );
    _kelurahanController = TextEditingController(text: user?.kelurahan ?? '');
    _kecamatanController = TextEditingController(text: user?.kecamatan ?? '');
    _propinsiController = TextEditingController(text: user?.propinsi ?? '');
    _kodePosController = TextEditingController(text: user?.kodePos ?? '');
    _alamatKtpController = TextEditingController(text: user?.alamatKtp ?? '');
    _noHpController = TextEditingController(text: user?.noHp ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _noRekeningBankController = TextEditingController(
      text: user?.noRekeningBank ?? '',
    );
    _npwpController = TextEditingController(text: user?.npwp ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');
  }

  @override
  void dispose() {
    _kelompokDawisController.dispose();
    _namaController.dispose();
    _idKaderController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _pendidikanTerakhirController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _propinsiController.dispose();
    _kodePosController.dispose();
    _alamatKtpController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _noRekeningBankController.dispose();
    _npwpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(loggedInUserProvider);
    if (user == null) return;

    final updatedUser = user.copyWith(
      kelompokDawis: _kelompokDawisController.text,
      nama: _namaController.text,
      idKader: _idKaderController.text,
      nik: _nikController.text,
      tempatLahir: _tempatLahirController.text,
      tanggalLahir: _tanggalLahirController.text,
      pendidikanTerakhir: _pendidikanTerakhirController.text,
      alamat: _alamatController.text,
      rt: _rtController.text,
      rw: _rwController.text,
      kelurahan: _kelurahanController.text,
      kecamatan: _kecamatanController.text,
      propinsi: _propinsiController.text,
      kodePos: _kodePosController.text,
      alamatKtp: _alamatKtpController.text,
      noHp: _noHpController.text,
      email: _emailController.text,
      noRekeningBank: _noRekeningBankController.text,
      npwp: _npwpController.text,
      password: _passwordController.text,
    );

    final repo = ref.read(appUserRepositoryProvider);
    await repo.updateUser(updatedUser);
    ref.read(loggedInUserProvider.notifier).setUser(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      context.pop();
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade200 : null,
        ),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> items,
  ) {
    String? currentValue = items.contains(controller.text)
        ? controller.text
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            controller.text = val;
          }
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final now = DateTime.now();
          final initial = controller.text.isNotEmpty
              ? DateTime.tryParse(controller.text) ?? now
              : now;
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: now,
          );
          if (selectedDate != null) {
            controller.text =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(loggedInUserProvider);
    final isAdmin = currentUser?.role == 'ADMIN';

    final pendidikanList = [
      'Tidak/Belum Sekolah',
      'PAUD',
      'TK / RA',
      'SD/MI',
      'SMP/MTs',
      'SMA/SMK/MA',
      'D1/D2/D3',
      'S1/D4',
      'S2',
      'S3',
    ];
    final rtRwList = [
      ...List.generate(20, (i) => (i + 1).toString().padLeft(3, '0')),
    ];
    if (_rtController.text.isNotEmpty &&
        !rtRwList.contains(_rtController.text)) {
      rtRwList.add(_rtController.text);
    }
    if (_rwController.text.isNotEmpty &&
        !rtRwList.contains(_rwController.text)) {
      rtRwList.add(_rwController.text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Kader Dawis',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Simpan Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Informasi Akun
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildField(
                        'Nama Kelompok',
                        _kelompokDawisController,
                        readOnly: !isAdmin,
                      ),
                      _buildField(
                        'ID / Username',
                        _idKaderController,
                        required: true,
                        readOnly: !isAdmin,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Data Diri
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Diri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildField(
                        'Nama Lengkap',
                        _namaController,
                        required: true,
                      ),
                      _buildField('NIK Kader', _nikController),
                      _buildField('Tempat Lahir', _tempatLahirController),
                      _buildDateField('Tanggal Lahir', _tanggalLahirController),
                      _buildDropdownField(
                        'Pendidikan Terakhir',
                        _pendidikanTerakhirController,
                        pendidikanList,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Alamat & Kontak
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alamat & Kontak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildField('Alamat', _alamatController),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'RT',
                              _rtController,
                              rtRwList,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              'RW',
                              _rwController,
                              rtRwList,
                            ),
                          ),
                        ],
                      ),
                      _buildField('Kelurahan', _kelurahanController),
                      _buildField('Kecamatan', _kecamatanController),
                      _buildField('Propinsi', _propinsiController),
                      _buildField('Kode Pos', _kodePosController),
                      _buildField('Alamat KTP', _alamatKtpController),
                      _buildField('No HP', _noHpController),
                      _buildField('Alamat Email', _emailController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Keuangan & Pajak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildField(
                        'No Rekening Bank DKI',
                        _noRekeningBankController,
                      ),
                      _buildField('NPWP', _npwpController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Simpan Profil',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
