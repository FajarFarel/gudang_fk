import 'package:gudang_fk/service/service_cari_barang_barcode.dart';

class BarangController {
  // Fungsi ini akan dipanggil dari UI
  Future<Map<String, dynamic>?> cariBarang(String barcode) async {
    if (barcode.isEmpty) return null;
    return await ServiceCariBarangBarcode.cariBarangByBarcode(barcode);
  }
}
