import 'dart:io';
import '../../service/atk/data_barang_keluar_service.dart';

class BarangController {
  final ATKService _service = ATKService();

  Future<bool> tambahBarang(Map<String, dynamic> data, File? foto) async {
    return await _service.tambahBarang(data, foto);
  }

  Future<bool> barangKeluar(Map<String, dynamic> data) async {
    return await _service.tambahKeluar(data);
  }

  Future<Map<String, dynamic>> getStok({String? kategori}) async {
    return await _service.getStok(kategori: kategori);
  }
}
