import 'package:gudang_fk/service/service_cari_barang_nobmn.dart';

class ControllerCariBarangNoBMN {
  // Fungsi ini akan dipanggil dari UI
  Future<Map<String, dynamic>?> cariBarang(String nobmn) async {
    if (nobmn.isEmpty) return null;
    return await ServiceCariBarangNoBMN.cariBarangByNoBMN(nobmn);
  }
}
