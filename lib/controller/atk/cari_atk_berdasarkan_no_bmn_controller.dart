import 'package:gudang_fk/service/atk/cari_atk_berdasarkan_no_bmn_service.dart';

class ControllerCariAtkNoBMN {
  // Fungsi ini akan dipanggil dari UI
  Future<Map<String, dynamic>?> cariBarang(String nobmn) async {
    if (nobmn.isEmpty) return null;
    return await ServiceCariAtkNoBMN.cariBarangByNoBMN(nobmn);
  }
}
