import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/gudang/controller_pemesanan.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'halaman_tabel/tabel_pemesanan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utility/switch_admin.dart';

class PemesananPage extends StatefulWidget {
  const PemesananPage({super.key});

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  final ImagePicker _picker = ImagePicker();
  final _controller = ControllerPemesanan();
  File? _pickedImage;
  String? userRole;
  final _NamaPemesanController = TextEditingController();
  final _tglPemesanan = TextEditingController();
  final _JumlahController = TextEditingController();
  final _satuanController = TextEditingController();
  final _spesifikasiController = TextEditingController();
  final _NamaBarangController = TextEditingController();
  final _NamaRuanganController = TextEditingController();
  final _HargaController = TextEditingController();
  final _LInkPembelianController = TextEditingController();
  final _kategori = TextEditingController(text: "Barang");
  bool adminMode = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadAdminMode(); // ← tambahkan ini
  }

  void _showBlockedOverlay() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Pemesanan sedang ditutup oleh admin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      );
    },
  );
}


  void _loadAdminMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool saved = prefs.getBool("admin_mode") ?? false;


    setState(() {
      adminMode = saved;
    });
  }

  void _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("user_role");

    setState(() {
      userRole = role;
    });

    print("ROLE: $role");
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil gambar: $e')));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

 void _kirimData() async {

    print('🔍 Mengecek status pemesanan...');

  final isOpen = await _controller.cekStatusPemesanan(fresh: true);

  print('📌 Status dari backend: ${isOpen ? "TERBUKA ✅" : "TERTUTUP ❌"}');

  if (!isOpen) {
    print('⚠️ Pemesanan ditutup → overlay ditampilkan');
    _showBlockedOverlay();
    return;
  } else {
    print('✅ Pemesanan terbuka → lanjut kirim data');
  }

  if (_pickedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harap pilih gambar bukti pemesanan')),
    );
    return;
  }

  final pickedDate = DateTime.parse(_tglPemesanan.text);

  final data = {
    'nama_pemesan': _NamaPemesanController.text.trim(),
    'jumlah': _JumlahController.text.trim(),
    'satuan': _satuanController.text.trim(),
    'spesifikasi': _spesifikasiController.text.trim(),
    'nama_barang': _NamaBarangController.text.trim(),
    'nama_ruangan': _NamaRuanganController.text.trim(),
    'harga': _HargaController.text.trim(),
    'link_pembelian': _LInkPembelianController.text.trim(),
    'kategori': _kategori.text.trim(),
  };

  final success = await _controller.buatPemesanan(data, _pickedImage);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan berhasil dikirim')),
    );

    _NamaPemesanController.clear();
    _JumlahController.clear();
    _satuanController.clear();
    _spesifikasiController.clear();
    _tglPemesanan.clear();
    _NamaBarangController.clear();
    _NamaRuanganController.clear();
    _HargaController.clear();
    _LInkPembelianController.clear();

    setState(() => _pickedImage = null);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Gagal mengirim pemesanan')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Form Pemesanan',
          style: TextStyle(
            color: AppColors.titleTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.cardborderColor,
                    width: 7,
                  ),
                ),
                child: Column(
                  children: [
                    _buildTextField("Nama", _NamaPemesanController),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Tanggal Pemesanan (YYYY-MM-DD)",
                      _tglPemesanan,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField("Jumlah", _JumlahController),
                    const SizedBox(height: 15),
                    _buildTextField("Satuan", _satuanController),
                    const SizedBox(height: 15),
                    _buildTextField("Spesifikasi", _spesifikasiController),
                    const SizedBox(height: 15),
                    _buildTextField("Nama Barang", _NamaBarangController),
                    const SizedBox(height: 15),
                    _buildTextField("Nama Ruangan", _NamaRuanganController),
                    const SizedBox(height: 15),
                    _buildTextField("Harga", _HargaController),
                    const SizedBox(height: 15),
                    _buildTextField("Link Pembelian", _LInkPembelianController),
                    const SizedBox(height: 15),
                    _buildTextFieldDisabled(_kategori.text, _kategori),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.textColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _pickedImage == null
                            ? SvgPicture.asset(
                                'assets/kamera.svg',
                                height: 50,
                                width: 50,
                                color: Colors.black54,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _pickedImage!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor2,
                    foregroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _kirimData,
                  child: const Text(
                    "Kirim Pemesanan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor2,
                    foregroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TabelPemesanan()),
                    );
                  },
                  child: const Text(
                    "Tabel Pemesanan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: AdminButton(
                  isAdmin: userRole == "admin",
                  value: adminMode,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();

                    // Simpan ke lokal
                    setState(() {
                      adminMode = value;
                    });
                    await prefs.setBool("admin_mode", value);

                    // ⬇️ Kirim ke backend
                    await _controller.updateStatusPemesanan(value);
                  },
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.textColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildTextFieldDisabled(
    String hint,
    TextEditingController controller,
  ) {
    return TextField(
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.textColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
