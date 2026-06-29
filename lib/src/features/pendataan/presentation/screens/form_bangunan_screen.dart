import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/bangunan.dart';
import '../providers/bangunan_provider.dart';
import '../../../settings/presentation/providers/app_user_provider.dart';

class FormBangunanScreen extends ConsumerStatefulWidget {
  final String? bangunanId;

  const FormBangunanScreen({super.key, this.bangunanId});

  @override
  ConsumerState<FormBangunanScreen> createState() => _FormBangunanScreenState();
}

class _FormBangunanScreenState extends ConsumerState<FormBangunanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers
  final _nomorUrutController = TextEditingController();
  final _namaBangunanController = TextEditingController();
  final _alamatController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _nopPbbController = TextEditingController();
  final _luasBangunanController = TextEditingController();
  final _luasTanahController = TextEditingController();
  final _jumlahFasilitasBabController = TextEditingController();
  final _jumlahTempatSampahController = TextEditingController();
  final _jumlahSpalController = TextEditingController();
  final _jumlahJambanKeluargaController = TextEditingController();
  final _pemanfaatanPekaranganController = TextEditingController();

  // Dropdown States
  String _statusHunian = 'Dihuni';
  String? _statusKepemilikan;
  int? _kategoriBangunan;
  String? _sumberAirMinum;

  // Boolean/Kriteria States
  bool _isSehatLayakHuni = false;
  bool _isTidakSehatLayakHuni = false;
  bool _hasStikerP4k = false;

  String? _existingKelompokDawis;

  final List<String> _statusHunianOptions = ['Dihuni', 'Kosong', 'Dibongkar'];
  final List<String> _kepemilikanOptions = [
    'Milik Sendiri',
    'Sewa',
    'Kontrak',
    'Bebas Sewa',
    'Dinas',
    'Lainnya',
  ];
  final Map<int, String> _kategoriMap = {
    1: 'Rumah Tinggal',
    2: 'Kontrakan',
    3: 'Kos-kosan',
    4: 'Asrama/Mess',
    5: 'Rusun',
    6: 'Rumah Dinas',
    7: 'Apartemen',
    8: 'Rukan/Ruko',
    9: 'Kios/Toko/Warung',
    10: 'Tempat Usaha Lainnya',
    11: 'Sekolah',
    12: 'Tempat Ibadah',
    13: 'Panti',
    14: 'Jenis Bangunan Lainnya',
  };
  final List<String> _sumberAirOptions = [
    'PDAM',
    'Sumur Pompa',
    'Sumur Gali',
    'Mata Air',
    'Sungai',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (widget.bangunanId != null) {
      final repository = ref.read(bangunanRepositoryProvider);
      final bangunan = await repository.getBangunanById(widget.bangunanId!);
      if (bangunan != null) {
        setState(() {
          _existingKelompokDawis = bangunan.kelompokDawis;
          _nomorUrutController.text = bangunan.nomorUrutBangunan ?? '';
          _namaBangunanController.text = bangunan.namaBangunan;
          _alamatController.text = bangunan.alamatLengkap;
          _rtController.text = bangunan.rt;
          _rwController.text = bangunan.rw;
          _nopPbbController.text = bangunan.nopPbb ?? '';
          _luasBangunanController.text =
              bangunan.luasBangunan?.toString() ?? '';
          _luasTanahController.text = bangunan.luasTanah?.toString() ?? '';

          String sh = bangunan.statusHunian;
          if (sh.endsWith('.')) sh = sh.substring(0, sh.length - 1);
          _statusHunian = _statusHunianOptions.contains(sh)
              ? sh
              : _statusHunianOptions.first;

          String? sk = bangunan.statusKepemilikan;
          if (sk != null && sk.endsWith('.')) {
            sk = sk.substring(0, sk.length - 1);
          }
          _statusKepemilikan = _kepemilikanOptions.contains(sk) ? sk : null;

          _kategoriBangunan =
              _kategoriMap.containsKey(bangunan.kategoriBangunan)
              ? bangunan.kategoriBangunan
              : null;

          String? sam = bangunan.sumberAirMinum;
          if (sam != null && sam.endsWith('.')) {
            sam = sam.substring(0, sam.length - 1);
          }
          _sumberAirMinum = _sumberAirOptions.contains(sam) ? sam : null;

          _isSehatLayakHuni = bangunan.isSehatLayakHuni == 1;
          _isTidakSehatLayakHuni = bangunan.isTidakSehatLayakHuni == 1;
          _jumlahFasilitasBabController.text =
              (bangunan.jumlahFasilitasBab ?? 0).toString();
          _jumlahTempatSampahController.text =
              (bangunan.jumlahTempatSampah ?? 0).toString();
          _jumlahSpalController.text = (bangunan.jumlahSpal ?? 0).toString();
          _jumlahJambanKeluargaController.text =
              (bangunan.jumlahJambanKeluarga ?? 0).toString();
          _hasStikerP4k = bangunan.hasStikerP4k == 1;
          _pemanfaatanPekaranganController.text =
              bangunan.pemanfaatanPekarangan ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nomorUrutController.dispose();
    _namaBangunanController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _nopPbbController.dispose();
    _luasBangunanController.dispose();
    _luasTanahController.dispose();
    _jumlahFasilitasBabController.dispose();
    _jumlahTempatSampahController.dispose();
    _jumlahSpalController.dispose();
    _jumlahJambanKeluargaController.dispose();
    _pemanfaatanPekaranganController.dispose();
    super.dispose();
  }

  int _currentStep = 1;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _currentStep = 2);
    }
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menyimpan data...')));

      try {
        final user = ref.read(loggedInUserProvider);
        final bangunan = Bangunan(
          id: widget.bangunanId ?? _uuid.v4(),
          nomorUrutBangunan: _nomorUrutController.text.isEmpty
              ? null
              : _nomorUrutController.text,
          namaBangunan: _namaBangunanController.text,
          kelompokDawis:
              _existingKelompokDawis ??
              user?.kelompokDawis ??
              'UNAUTHENTICATED',
          alamatLengkap: _alamatController.text,
          rt: _rtController.text,
          rw: _rwController.text,
          statusHunian: _statusHunian,
          nopPbb: _nopPbbController.text.isEmpty
              ? null
              : _nopPbbController.text,
          luasBangunan: double.tryParse(
            _luasBangunanController.text.replaceAll(',', '.'),
          ),
          luasTanah: double.tryParse(
            _luasTanahController.text.replaceAll(',', '.'),
          ),
          kategoriBangunan: _kategoriBangunan,
          statusKepemilikan: _statusKepemilikan,
          sumberAirMinum: _sumberAirMinum,
          jumlahFasilitasBab: int.tryParse(_jumlahFasilitasBabController.text),
          pemanfaatanPekarangan: _pemanfaatanPekaranganController.text,
          isSehatLayakHuni: _isSehatLayakHuni ? 1 : 0,
          isTidakSehatLayakHuni: _isTidakSehatLayakHuni ? 1 : 0,
          jumlahTempatSampah:
              int.tryParse(_jumlahTempatSampahController.text) ?? 0,
          jumlahSpal: int.tryParse(_jumlahSpalController.text) ?? 0,
          jumlahJambanKeluarga:
              int.tryParse(_jumlahJambanKeluargaController.text) ?? 0,
          hasStikerP4k: _hasStikerP4k ? 1 : 0,
          isSynced: 0,
        );

        final repository = ref.read(bangunanRepositoryProvider);

        if (widget.bangunanId != null) {
          await repository.updateBangunan(bangunan);
        } else {
          await repository.insertBangunan(bangunan);
        }

        ref.invalidate(daftarBangunanProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data Bangunan Berhasil Disimpan!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Form Data Bangunan',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6366F1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          width: _currentStep == 1
                              ? constraints.maxWidth * 0.5
                              : constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Langkah $_currentStep dari 2',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: 'Bagian 1: Identitas & Lokasi',
          icon: Icons.location_on_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOutlinedInput(
                'Nomor Urut Bangunan',
                _nomorUrutController,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildOutlinedInput(
                'Nama Bangunan',
                _namaBangunanController,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildOutlinedInput(
                'Alamat Lengkap',
                _alamatController,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOutlinedInput(
                      'RT',
                      _rtController,
                      isNumber: true,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOutlinedInput(
                      'RW',
                      _rwController,
                      isNumber: true,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOutlinedDropdown(
                'Status Hunian',
                _statusHunian,
                _statusHunianOptions,
                (val) => setState(() => _statusHunian = val!),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori Bangunan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: _kategoriBangunan,
                    items: _kategoriMap.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _kategoriBangunan = val),
                    decoration: _outlinedDecoration(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'Bagian 2: Legalitas & Fisik',
          icon: Icons.description_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOutlinedInput(
                'Nomor Objek Pajak (NOP PBB)',
                _nopPbbController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOutlinedInput(
                      'Luas Bangunan (m2)',
                      _luasBangunanController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOutlinedInput(
                      'Luas Tanah (m2)',
                      _luasTanahController,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOutlinedDropdown(
                'Status Kepemilikan',
                _statusKepemilikan,
                _kepemilikanOptions,
                (val) => setState(() => _statusKepemilikan = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simpan Draf',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selanjutnya',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bagian 3: Sanitasi & Kriteria Rumah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildUnderlinedDropdown(
                      'Sumber Air Minum',
                      _sumberAirMinum,
                      _sumberAirOptions,
                      (val) => setState(() => _sumberAirMinum = val),
                    ),
                    const SizedBox(height: 24),
                    _buildUnderlinedInput(
                      'Jumlah Fasilitas BAB',
                      _jumlahFasilitasBabController,
                      isNumber: true,
                    ),
                    const SizedBox(height: 24),
                    _buildUnderlinedInput(
                      'Pemanfaatan Pekarangan (Contoh: Toga, Warung Hidup)',
                      _pemanfaatanPekaranganController,
                    ),
                    const SizedBox(height: 32),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildModernSwitch(
                            'Sehat Layak Huni',
                            _isSehatLayakHuni,
                            (val) => setState(() => _isSehatLayakHuni = val),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          _buildModernSwitch(
                            'Tidak Sehat Layak Huni',
                            _isTidakSehatLayakHuni,
                            (val) =>
                                setState(() => _isTidakSehatLayakHuni = val),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          _buildModernSwitch(
                            'Menempel Stiker P4K',
                            _hasStikerP4k,
                            (val) => setState(() => _hasStikerP4k = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _buildUnderlinedInput(
                            'Jml Tmp Sampah',
                            _jumlahTempatSampahController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUnderlinedInput(
                            'Jml SPAL',
                            _jumlahSpalController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUnderlinedInput(
                            'Jml Jamban',
                            _jumlahJambanKeluargaController,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                foregroundColor: const Color(0xFF64748B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _simpanData,
                              child: const Text(
                                'Simpan Data Bangunan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  InputDecoration _outlinedDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }

  Widget _buildOutlinedInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: _outlinedDecoration(),
          validator: isRequired
              ? (val) => val == null || val.isEmpty ? 'Wajib diisi' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildOutlinedDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _outlinedDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildUnderlinedInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildUnderlinedDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF94A3B8),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFC7D2FE),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}
