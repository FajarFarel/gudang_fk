import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gudang_fk/utility/colors.dart';
import '../../controller/gudang/barang_controller.dart';
import 'package:intl/intl.dart';

class InputBarangScreen extends StatefulWidget {
  const InputBarangScreen({super.key});

  @override
  State<InputBarangScreen> createState() => _InputBarangScreenState();
}

class _InputBarangScreenState extends State<InputBarangScreen> {
  final ImagePicker _picker = ImagePicker();
  final _controller = BarangController();
  int? _selectedPemesananId;
  List<Map<String, dynamic>> _pemesananPending = [];

  File? _pickedImage;

  // Text controller untuk field input
  final _noBmn = TextEditingController();
  final _tglDatang = TextEditingController();
  final _spesifikasi = TextEditingController();
  final _namaBarang = TextEditingController();
  final _jumlah = TextEditingController();
  final _namaRuangan = TextEditingController();
  final _lantai = TextEditingController();
  final _keadaanGabung = TextEditingController();
  final _barcode = TextEditingController();
  final _kategori = TextEditingController(text: "gudang");

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

  @override
  void initState() {
    super.initState();
    _fetchPemesananPending();
  }

  void _fetchPemesananPending() async {
    final response = await _controller.ambilPemesananPending(
      kategori: _kategori.text,
    );
    setState(() {
      _pemesananPending = response;
    });
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
              title: const Text('Ambil Foto (Camera)'),
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
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Harap pilih gambar dulu!')),
      );
      return;
    }

    final DateTime pickedDate = DateTime.parse(_tglDatang.text);
    final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

    // Ambil input seperti: "B:5 RR:0 RB:0"
    final kondisiText = _keadaanGabung.text.trim();

    // Parsing otomatis ke angka
    int b = 0, rr = 0, rb = 0;
    final RegExp pattern = RegExp(
      r'B:(\d+)|RR:(\d+)|RB:(\d+)',
      caseSensitive: false,
    );
    for (final match in pattern.allMatches(kondisiText)) {
      if (match.group(1) != null) b = int.parse(match.group(1)!);
      if (match.group(2) != null) rr = int.parse(match.group(2)!);
      if (match.group(3) != null) rb = int.parse(match.group(3)!);
    }

    final data = {
      'id_pemesanan': _selectedPemesananId,
      'no_bmn': _noBmn.text,
      'tanggal_barang_datang': formattedDate,
      'spesifikasi': _spesifikasi.text,
      'nama_barang': _namaBarang.text,
      'jumlah_satuan': _jumlah.text,
      'nama_ruangan': _namaRuangan.text,
      'lantai': _lantai.text,
      'B': b.toString(),
      'RR': rr.toString(),
      'RB': rb.toString(),
      'no_barcode': _barcode.text,
      'kategori': _kategori.text,
    };

    final success = await _controller.tambahBarang(data, _pickedImage);
    final updatedList = await _controller.ambilPemesananPending(kategori: _kategori.text);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Data berhasil dikirim!')));

      setState(() {
        _pickedImage = null;
        _noBmn.clear();
        _tglDatang.clear();
        _spesifikasi.clear();
        _namaBarang.clear();
        _jumlah.clear();
        _namaRuangan.clear();
        _lantai.clear();
        _keadaanGabung.clear();
        _selectedPemesananId = null;
        _barcode.clear();
        _pemesananPending = updatedList;
      });

      // Refresh daftar pemesanan pending
      _fetchPemesananPending();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Gagal kirim data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Input Data Barang",
          style: TextStyle(
            color: AppColors.titleTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
                    _buildTextField("No. BMN:", _noBmn),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Tanggal Barang Datang: (yyyy-MM-dd)",
                      _tglDatang,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField("Spesifikasi (Merk Barang):", _spesifikasi),
                    const SizedBox(height: 15),
                    _buildTextField("Nama Barang:", _namaBarang),
                    const SizedBox(height: 15),
                    _buildTextField("Jumlah / Satuan:", _jumlah),
                    const SizedBox(height: 15),
                    _buildTextField("Nama Ruangan:", _namaRuangan),
                    const SizedBox(height: 15),
                    _buildTextField("Lantai:", _lantai),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Keadaan Barang (contoh: B:5 RR:0 RB:0)",
                      _keadaanGabung,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField("No Barcode:", _barcode),
                    const SizedBox(height: 15),
                    _buildDropdownField<int>(
                      hint: "Pilih Pemesanan",
                      value: _selectedPemesananId,
                      items: _pemesananPending
                          .where(
                            (pem) => pem['status'] != 'complete',
                          ) // filter yang sudah komplit
                          .map((pem) {
                            return DropdownMenuItem<int>(
                              value: pem['id'],
                              child: Text(
                                "${pem['nama_barang']} (${pem['nama_pemesan']})",
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPemesananId = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),
                    _buildTextFieldDisabled(_kategori.text, _kategori),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _pickedImage == null
                            ? SvgPicture.asset(
                                'assets/kamera.svg',
                                width: 50,
                                height: 50,
                                color: Colors.black54,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _pickedImage!,
                                  width: 100,
                                  height: 100,
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _kirimData,
                  child: const Text(
                    "Kirim",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

  Widget _buildDropdownField<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.textColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
