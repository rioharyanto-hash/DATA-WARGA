import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/app_user.dart';
import '../providers/app_user_provider.dart';

class FormUserScreen extends ConsumerStatefulWidget {
  final String? userId;

  const FormUserScreen({super.key, this.userId});

  @override
  ConsumerState<FormUserScreen> createState() => _FormUserScreenState();
}

class _FormUserScreenState extends ConsumerState<FormUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _idKaderController = TextEditingController();
  final _passwordController = TextEditingController(text: 'dawis010');
  final _rwController = TextEditingController();
  final _rtController = TextEditingController();
  final _dawisController = TextEditingController();

  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _alamatKtpController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _noRekeningBankController = TextEditingController();
  final _npwpController = TextEditingController();

  String _selectedRole = 'KADER';
  String? _selectedPendidikan;
  String? _selectedPropinsi;

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _dawisRt = '001';
  String? _dawisNoUrut = '001';

  final List<String> _pendidikanList = [
    'SD',
    'SMP',
    'SMA',
    'D3',
    'S1',
    'S2',
    'S3',
    'Lainnya',
  ];
  final List<String> _propinsiList = [
    'DKI Jakarta',
    'Jawa Barat',
    'Banten',
    'Jawa Tengah',
    'Jawa Timur',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUser(widget.userId!);
    }
  }

  Future<void> _loadUser(String id) async {
    setState(() => _isLoading = true);
    final repo = ref.read(appUserRepositoryProvider);
    final user = await repo.getUserById(id);
    if (user != null) {
      _namaController.text = user.nama;
      _idKaderController.text = user.idKader;
      _passwordController.text = user.password;
      setState(() {
        _selectedRole = user.role;
      });
      _rwController.text = user.rw?.isNotEmpty == true
          ? user.rw!.padLeft(2, '0')
          : '';
      _rtController.text = user.rt?.isNotEmpty == true
          ? user.rt!.padLeft(2, '0')
          : '';
      _dawisController.text = user.kelompokDawis ?? '';

      if (user.kelompokDawis != null &&
          user.kelompokDawis!.startsWith('BUAH GOWOK 010.')) {
        final parts = user.kelompokDawis!
            .substring('BUAH GOWOK 010.'.length)
            .split('.');
        if (parts.length >= 2) {
          _dawisRt = parts[0];
          _dawisNoUrut = parts[1];
        }
      }

      _nikController.text = user.nik ?? '';
      _tempatLahirController.text = user.tempatLahir ?? '';
      String initialDate = user.tanggalLahir ?? '';
      if (initialDate.length > 10 && initialDate.contains('T')) {
        initialDate = initialDate.substring(0, 10);
      }
      _tanggalLahirController.text = initialDate;

      if (_pendidikanList.contains(user.pendidikanTerakhir)) {
        _selectedPendidikan = user.pendidikanTerakhir;
      }

      _alamatController.text = user.alamat ?? '';
      _kelurahanController.text = user.kelurahan ?? '';
      _kecamatanController.text = user.kecamatan ?? '';

      if (_propinsiList.contains(user.propinsi)) {
        _selectedPropinsi = user.propinsi;
      }

      _kodePosController.text = user.kodePos ?? '';
      _alamatKtpController.text = user.alamatKtp ?? '';
      _noHpController.text = user.noHp ?? '';
      _emailController.text = user.email ?? '';
      _noRekeningBankController.text = user.noRekeningBank ?? '';
      _npwpController.text = user.npwp ?? '';
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _idKaderController.dispose();
    _passwordController.dispose();
    _rwController.dispose();
    _rtController.dispose();
    _dawisController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _kodePosController.dispose();
    _alamatKtpController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _noRekeningBankController.dispose();
    _npwpController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalLahir(BuildContext context) async {
    final initialDate = _tanggalLahirController.text.isNotEmpty
        ? DateTime.tryParse(_tanggalLahirController.text) ?? DateTime.now()
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(appUserRepositoryProvider);

      final isNew = widget.userId == null;
      final userId = isNew ? const Uuid().v4() : widget.userId!;

      final user = AppUser(
        id: userId,
        nama: _namaController.text.trim(),
        idKader: _idKaderController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        rw: _selectedRole != 'ADMIN' ? _rwController.text.trim() : null,
        rt: (_selectedRole == 'RT' || _selectedRole == 'KADER')
            ? _rtController.text.trim()
            : null,
        kelompokDawis: _selectedRole == 'KADER'
            ? 'BUAH GOWOK 010.${_dawisRt ?? '001'}.${_dawisNoUrut ?? '001'}'
            : null,
        nik: _nikController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _tanggalLahirController.text.trim(),
        pendidikanTerakhir: _selectedPendidikan,
        alamat: _alamatController.text.trim(),
        kelurahan: _kelurahanController.text.trim(),
        kecamatan: _kecamatanController.text.trim(),
        propinsi: _selectedPropinsi,
        kodePos: _kodePosController.text.trim(),
        alamatKtp: _alamatKtpController.text.trim(),
        noHp: _noHpController.text.trim(),
        email: _emailController.text.trim(),
        noRekeningBank: _noRekeningBankController.text.trim(),
        npwp: _npwpController.text.trim(),
      );

      if (isNew) {
        await repo.insertUser(user);
      } else {
        await repo.updateUser(user);
      }

      ref.invalidate(allUsersProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.userId == null ? 'Tambah Kader' : 'Edit Kader'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'BATAL',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton(
              onPressed: _saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'SIMPAN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            // 1. Informasi Akun
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: _idKaderController,
                                            decoration: const InputDecoration(
                                              labelText: 'ID / Username',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            validator: (val) =>
                                                val == null || val.isEmpty
                                                ? 'Wajib diisi'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  size: 20,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                ),
                                              ),
                                            ),
                                            validator: (val) =>
                                                widget.userId == null &&
                                                    (val == null || val.isEmpty)
                                                ? 'Wajib diisi'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Data Diri
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (_selectedRole == 'KADER')
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Nama Kelompok',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        'BUAH GOWOK 010.',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      DropdownButtonHideUnderline(
                                                        child: DropdownButton<String>(
                                                          isDense: true,
                                                          value: _dawisRt,
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 16,
                                                          ),
                                                          items: List.generate(20, (
                                                            index,
                                                          ) {
                                                            final val =
                                                                (index + 1)
                                                                    .toString()
                                                                    .padLeft(
                                                                      3,
                                                                      '0',
                                                                    );
                                                            return DropdownMenuItem(
                                                              value: val,
                                                              child: Text(
                                                                val,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                              ),
                                                            );
                                                          }),
                                                          onChanged: (val) =>
                                                              setState(
                                                                () => _dawisRt =
                                                                    val,
                                                              ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        '.',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      DropdownButtonHideUnderline(
                                                        child: DropdownButton<String>(
                                                          isDense: true,
                                                          value: _dawisNoUrut,
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 16,
                                                          ),
                                                          items: List.generate(5, (
                                                            index,
                                                          ) {
                                                            final val =
                                                                (index + 1)
                                                                    .toString()
                                                                    .padLeft(
                                                                      3,
                                                                      '0',
                                                                    );
                                                            return DropdownMenuItem(
                                                              value: val,
                                                              child: Text(
                                                                val,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                              ),
                                                            );
                                                          }),
                                                          onChanged: (val) =>
                                                              setState(
                                                                () =>
                                                                    _dawisNoUrut =
                                                                        val,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (_selectedRole == 'KADER')
                                          const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _namaController,
                                            decoration: const InputDecoration(
                                              labelText: 'Nama Lengkap',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            validator: (val) =>
                                                val == null || val.isEmpty
                                                ? 'Wajib diisi'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _nikController,
                                            decoration: const InputDecoration(
                                              labelText: 'NIK',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _tempatLahirController,
                                            decoration: const InputDecoration(
                                              labelText: 'Tempat Lahir',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _tanggalLahirController,
                                            readOnly: true,
                                            onTap: () =>
                                                _selectTanggalLahir(context),
                                            decoration: const InputDecoration(
                                              labelText: 'Tanggal Lahir',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                                initialValue:
                                                    _selectedPendidikan,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText:
                                                          'Pendidikan Terakhir',
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                    ),
                                                items: _pendidikanList
                                                    .map(
                                                      (p) => DropdownMenuItem(
                                                        value: p,
                                                        child: Text(p),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (val) => setState(
                                                  () =>
                                                      _selectedPendidikan = val,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Alamat & Kontak
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: TextFormField(
                                            controller: _alamatController,
                                            decoration: const InputDecoration(
                                              labelText: 'Alamat',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              DropdownButtonFormField<String>(
                                                initialValue:
                                                    _rtController.text.isEmpty
                                                    ? null
                                                    : _rtController.text,
                                                items:
                                                    [
                                                          ...List.generate(
                                                            20,
                                                            (i) => (i + 1)
                                                                .toString()
                                                                .padLeft(
                                                                  2,
                                                                  '0',
                                                                ),
                                                          ),
                                                          if (_rtController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              !List.generate(
                                                                20,
                                                                (i) => (i + 1)
                                                                    .toString()
                                                                    .padLeft(
                                                                      2,
                                                                      '0',
                                                                    ),
                                                              ).contains(
                                                                _rtController
                                                                    .text,
                                                              ))
                                                            _rtController.text,
                                                        ]
                                                        .map(
                                                          (e) =>
                                                              DropdownMenuItem(
                                                                value: e,
                                                                child: Text(e),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    _rtController.text = val;
                                                  }
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'RT',
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                    ),
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              DropdownButtonFormField<String>(
                                                initialValue:
                                                    _rwController.text.isEmpty
                                                    ? null
                                                    : _rwController.text,
                                                items:
                                                    [
                                                          ...List.generate(
                                                            20,
                                                            (i) => (i + 1)
                                                                .toString()
                                                                .padLeft(
                                                                  2,
                                                                  '0',
                                                                ),
                                                          ),
                                                          if (_rwController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              !List.generate(
                                                                20,
                                                                (i) => (i + 1)
                                                                    .toString()
                                                                    .padLeft(
                                                                      2,
                                                                      '0',
                                                                    ),
                                                              ).contains(
                                                                _rwController
                                                                    .text,
                                                              ))
                                                            _rwController.text,
                                                        ]
                                                        .map(
                                                          (e) =>
                                                              DropdownMenuItem(
                                                                value: e,
                                                                child: Text(e),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    _rwController.text = val;
                                                  }
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'RW',
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                    ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _kelurahanController,
                                            decoration: const InputDecoration(
                                              labelText: 'Kelurahan',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _kecamatanController,
                                            decoration: const InputDecoration(
                                              labelText: 'Kecamatan',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                                initialValue: _selectedPropinsi,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Propinsi',
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                    ),
                                                items: _propinsiList
                                                    .map(
                                                      (p) => DropdownMenuItem(
                                                        value: p,
                                                        child: Text(p),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (val) => setState(
                                                  () => _selectedPropinsi = val,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _kodePosController,
                                            decoration: const InputDecoration(
                                              labelText: 'Kode Pos',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _alamatKtpController,
                                            decoration: const InputDecoration(
                                              labelText: 'Alamat KTP',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _noHpController,
                                            decoration: const InputDecoration(
                                              labelText: 'No HP',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9+]'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _emailController,
                                            decoration: const InputDecoration(
                                              labelText: 'Alamat Email',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. Informasi Keuangan & Pajak
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _noRekeningBankController,
                                            decoration: const InputDecoration(
                                              labelText: 'No Rekening Bank DKI',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _npwpController,
                                            decoration: const InputDecoration(
                                              labelText: 'NPWP',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.\-]'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
