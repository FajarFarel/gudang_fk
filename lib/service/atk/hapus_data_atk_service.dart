import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../api/config.dart';

class HapusPemesananAtkService {
  static Future<Map<String, dynamic>> hapusBarang(int id) async {
    final url = Uri.parse("${Config.baseUrl}/api/hapus_pemesanan_atk/$id");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body); // barang tidak ditemukan
    } else {
      throw Exception(
        "Gagal menghapus barang: ${response.statusCode} | ${response.body}",
      );
    }
  }
}

class HapusDataAtkService {
  static Future<Map<String, dynamic>> hapusBarang(int id) async {
    final url = Uri.parse("${Config.baseUrl}/api/hapus_atk/$id");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body); // barang tidak ditemukan
    } else {
      throw Exception(
        "Gagal menghapus barang: ${response.statusCode} | ${response.body}",
      );
    }
  }
}

class EditAtkService {
  static Future<Map<String, dynamic>> editAtk({
    required int id,
    required String b,
    required String rr,
    required String rb,
    required String noBMN,
    required String namabarang,
    required String tanggalbarangdatang,
    required String jumlah,
    required String satuan,
    required String spesifikasi,
    required String namaruangan,
    required String kategori,
    File? fotoatkBaru, // opsional
  }) async {
    final url = Uri.parse("${Config.baseUrl}/api/edit_atk/$id");
    final request = http.MultipartRequest("PUT", url);

    request.fields["no_BMN"] = noBMN;
    request.fields["nama_barang"] = namabarang;
    request.fields["tanggal_barang_datang"] = tanggalbarangdatang;
    request.fields["jumlah"] = jumlah;
    request.fields["satuan"] = satuan;
    request.fields["spesifikasi"] = spesifikasi;
    request.fields["nama_ruangan"] = namaruangan;
    request.fields["kategori"] = kategori;
    // Jika ada foto baru, tambahkan ke request
    if (fotoatkBaru != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        "foto_atk",
        fotoatkBaru.path,
      );
      request.files.add(multipartFile);
    }
    request.fields["B"] = b;
    request.fields["RR"] = rr;
    request.fields["RB"] = rb;

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body);
    } else {
      throw Exception("Gagal update data atk! code: ${response.statusCode}");
    }
  }
}

class EditPemesananAtkService {
  static Future<Map<String, dynamic>> editPemesanan({
    required int id,
    required String namaPemesan,
    required String namaBarang,
    required String jumlah,
    required String tanggalPemesanan,
    required String satuan,
    required String spesifikasi,
    required String harga,
    required String linkPembelian,
    File? fotoBaru, // null = tidak ganti foto
  }) async {
    final url = Uri.parse("${Config.baseUrl}/api/edit_pemesanan_atk/$id");

    // Multipart karena ada kemungkinan file foto
    final request = http.MultipartRequest("PUT", url);

    request.fields["nama_pemesan"] = namaPemesan;
    request.fields["nama_barang"] = namaBarang;
    request.fields["jumlah"] = jumlah;
    request.fields["tanggal_pemesanan"] = tanggalPemesanan;
    request.fields["satuan"] = satuan;
    request.fields["spesifikasi"] = spesifikasi;
    request.fields["harga"] = harga;
    request.fields["link_pembelian"] = linkPembelian;

    // Kalau foto baru ada → kirim file
    if (fotoBaru != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        "foto",
        fotoBaru.path,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body);
    } else {
      throw Exception(
        "Gagal update data pemesanan! code: ${response.statusCode}",
      );
    }
  }
}
