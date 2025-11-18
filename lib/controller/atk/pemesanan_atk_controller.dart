import 'dart:io';
import '../../service/atk/pemesanan_atk_service.dart';

class PemesananAtkController {
  final ServicePemesananAtk _service = ServicePemesananAtk();

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
      print("✅ Pemesanan ATK berhasil dibuat");
    } else {
      print("❌ Gagal membuat pemesanan ATK");
    }

    return result;
  }

  Future<List<dynamic>> ambilSemuaPemesanan() async {
    return await _service.getPemesanan();
  }
}
