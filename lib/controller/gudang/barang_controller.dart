import 'dart:io';
import '../../service/gudang/barang_service.dart';

class BarangController {
  final BarangService _service = BarangService();

  Future<bool> tambahBarang(
    Map<String, dynamic> data,
    File? pickedImage,
  ) async {
    if (data['nama_barang'] == null || data['nama_barang'].isEmpty) {
      print("⚠️ Nama barang wajib diisi");
      return false;
    }

    if (data['id_pemesanan'] == null) {
      print("⚠️ Harap pilih pesanan terlebih dahulu!");
      return false;
    }

    final result = await _service.tambahBarang(data, pickedImage);
    if (result) {
      print("✅ Barang berhasil ditambahkan, update status pemesanan...");
      await _service.updateStatusPemesanan(data['id_pemesanan'], 'selesai');
    } else {
      print("❌ Gagal menambahkan barang");
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> ambilPemesananPending({
    String? kategori,
  }) async {
    final result = await _service.getPemesananPending(kategori: kategori);
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
}
