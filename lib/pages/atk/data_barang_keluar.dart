import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../../controller/atk/data_barang_keluar_controller.dart';

class DataBarangKeluarATK extends StatefulWidget {
  const DataBarangKeluarATK({super.key});

  @override
  State<DataBarangKeluarATK> createState() => _DataBarangKeluarATKState();
}

class _DataBarangKeluarATKState extends State<DataBarangKeluarATK> {
  final ImagePicker _picker = ImagePicker();
  final _controller = BarangController();

  File? _pickedImage;

  final _nama = TextEditingController();
  final _namaBarang = TextEditingController();
  final _jumlah = TextEditingController();

  Map<String, int> stockData = {};

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  Future<void> _loadStock() async {
    final data = await _controller.getStok(kategori: "ATK");

    setState(() {
      stockData = {
        for (var entry in data.entries) entry.key: entry.value['total'] as int,
      };
    });
  }

  // ============ IMAGE PICKER ==================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil gambar: $e")));
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
              title: const Text("Ambil Foto"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Batal"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ============ KIRIM DATA ==================
  void _kirimData() async {
    if (_nama.text.isEmpty ||
        _namaBarang.text.isEmpty ||
        _jumlah.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Semua field wajib diisi")),
      );
      return;
    }

    // ==== DEBUG PRINTS (fallback data) ====
    print("===== DEBUG KIRIM BARANG KELUAR =====");
    print("Nama Peminta: ${_nama.text}");
    print("Nama Barang: ${_namaBarang.text}");
    print("Jumlah: ${_jumlah.text}");
    print("Kategori: ATK");

    print(
      "Gambar: ${_pickedImage != null ? _pickedImage!.path : "Tidak ada gambar"}",
    );

    print("Stock snapshot (ketika submit):");
    stockData.forEach((k, v) {
      print(" - $k : $v");
    });
    print("=====================================");

    final data = {
      "nama": _nama.text,
      "nama_barang": _namaBarang.text,
      "jumlah": _jumlah.text,
    };

    final success = await _controller.tambahBarang(data, _pickedImage);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✔ Barang Keluar Berhasil Dicatat")),
      );

      setState(() {
        _nama.clear();
        _namaBarang.clear();
        _jumlah.clear();
        _pickedImage = null;
      });

      _loadStock();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Gagal mengirim data")));
    }
  }

  // ============ BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Data Barang Keluar ATK',
          style: TextStyle(color: AppColors.buttonColor, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= STOCK =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A424A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleStock(),
                  const SizedBox(height: 20),
                  _buildStockWrapScrollable(),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ================= FORM =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A424A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Column(
                children: [
                  _inputField("Nama", _nama),
                  const SizedBox(height: 15),

                  _inputField("Nama Barang", _namaBarang),
                  const SizedBox(height: 15),

                  _inputField("Jumlah / Satuan", _jumlah),
                  const SizedBox(height: 15),

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

            const SizedBox(height: 40),

            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
    );
  }

Widget _inputField(String hint, TextEditingController controller) {
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
  Widget _titleStock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Stock ATK",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStockWrapScrollable() {
    if (stockData.isEmpty) {
      return const Text(
        "Memuat stok...",
        style: TextStyle(color: Colors.white),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: stockData.entries.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "${item.key}: ${item.value}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
