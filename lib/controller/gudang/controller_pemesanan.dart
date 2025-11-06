import "dart:io";
import '../../service/gudang/service_pemesanan.dart';

class ControllerPemesanan {
  final ServicePemesanan _service = ServicePemesanan();

  Future<bool> buatPemesanan(
    Map<String, dynamic> data,
    File? pickedImage,
  ) async {
    if (data['nama_pemesan'] == null || data['nama_pemesan'].isEmpty) {
      print("⚠️ Nama pemesan wajib diisi");
      return false;
    }

    final result = await _service.buatPemesanan(
      data,
      pickedImage,
    ); // pass pickedImage
    if (result) {
      print("✅ Pemesanan berhasil dibuat");
    } else {
      print("❌ Gagal membuat pemesanan");
    }

    return result;
  }

  Future<List<dynamic>> ambilSemuaPemesanan() async {
    return await _service.getPemesanan();
  }
}
