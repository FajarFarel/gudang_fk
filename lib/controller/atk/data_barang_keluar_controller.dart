import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/atk/data_barang_keluar_service.dart';

class BarangKeluarController with ChangeNotifier {
  final service = BarangKeluarService();

  // Field form
  final namaC = TextEditingController();
  final namaBarangC = TextEditingController();
  final jumlahC = TextEditingController();

  File? foto;
  bool isLoading = false;

  // ==========================
  // Ambil foto kamera/galeri
  // ==========================
  Future<void> pickFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      foto = File(picked.path);
      notifyListeners();
    }
  }

  // ==========================
  // Ambil stok dari API
  // ==========================
  Future<Map<String, dynamic>> loadStok() async {
    return await service.getStokATK();
  }

  // ==========================
  // Kirim form barang keluar
  // ==========================
  Future<bool> submit(BuildContext context) async {
    if (namaC.text.isEmpty ||
        namaBarangC.text.isEmpty ||
        jumlahC.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ Semua field wajib diisi")));
      return false;
    }

    isLoading = true;
    notifyListeners();

    final ok = await service.kirimBarangKeluar(
      nama: namaC.text,
      namaBarang: namaBarangC.text,
      jumlah: jumlahC.text,
      foto: foto,
    );

    isLoading = false;
    notifyListeners();

    return ok;
  }
}
