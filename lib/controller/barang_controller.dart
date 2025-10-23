import 'dart:io';
import '../../service/barang_service.dart';

class BarangController {
  final BarangService _service = BarangService();

  Future<bool> tambahBarang(Map<String, dynamic> data, File? pickedImage) async {
    if (data['nama_barang'] == null || data['nama_barang'].isEmpty) {
      print("⚠️ Nama barang wajib diisi");
      return false;
    }

    final result = await _service.tambahBarang(data, pickedImage);
    if (result) {
      print("✅ Barang berhasil ditambahkan");
    } else {
      print("❌ Gagal menambahkan barang");
    }

    return result;
  }

  Future<List<dynamic>> ambilSemuaBarang() async {
    return await _service.getBarang();
  }
}
