import 'package:gudang_fk/service/gudang/service_cari_barang_barcode.dart';

class ControllerCariBarangBarcode {
  // Fungsi ini akan dipanggil dari UI
  Future<Map<String, dynamic>?> cariBarang(String barcode) async {
    if (barcode.isEmpty) return null;
    return await ServiceCariBarangBarcode.cariBarangByBarcode(barcode);
  }
}
