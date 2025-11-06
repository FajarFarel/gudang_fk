import 'package:gudang_fk/service/gudang/service_cari_barang_lantai.dart';

class ControllerCariBarangLantai {
  // Fungsi ini akan dipanggil dari UI
  Future<Map<String, dynamic>?> cariBarang(String lantai) async {
    if (lantai.isEmpty) return null;
    return await ServiceCariBarangLantai.cariBarangByLantai(lantai);
  }
}
