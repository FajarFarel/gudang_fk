import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../api/config.dart';

class BarangKeluarService {
  // GET STOK ATK
  Future<Map<String, dynamic>> getStokATK() async {
    final url = Uri.parse("${Config.baseUrl}/stok?kategori=atk");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Gagal memuat stok");
    }
  }

  // POST BARANG KELUAR
  Future<bool> kirimBarangKeluar({
    required String nama,
    required String namaBarang,
    required String jumlah,
    File? foto,
  }) async {
    final url = Uri.parse("${Config.baseUrl}/api/atk/keluar");

    var req = http.MultipartRequest('POST', url);

    req.fields['nama'] = nama;
    req.fields['nama_barang'] = namaBarang;
    req.fields['jumlah'] = jumlah;

    if (foto != null) {
      req.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }

    final res = await req.send();
    return res.statusCode == 201;
  }
}
