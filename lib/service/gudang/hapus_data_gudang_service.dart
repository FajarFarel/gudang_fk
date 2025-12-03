import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../api/config.dart';

class HapusDataGudangService {
  static Future<Map<String, dynamic>> hapusDataGudang(int id) async {
    final url = Uri.parse("${Config.baseUrl}/api/hapus_gudang/$id");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result;
    } else {
      throw Exception('Gagal menghapus data gudang dengan id $id');
    }
  }
}

class HapusPemesananGudangService {
  static Future<Map<String, dynamic>> hapusPemesananGudang(int id) async {
    final url = Uri.parse("${Config.baseUrl}/api/hapus_pemesanan_gudang/$id");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result;
    } else {
      throw Exception('Gagal menghapus pemesanan gudang dengan id $id');
    }
  }
}

class EditGudangService {
  static Future<Map<String, dynamic>> editGudang({
    required int id,
    required String b,
    required String rr,
    required String rb,// opsional
  }) async {
    final url = Uri.parse("${Config.baseUrl}/api/edit_gudang/$id");
    final request = http.MultipartRequest("PUT", url);

    request.fields["B"] = b;
    request.fields["RR"] = rr;
    request.fields["RB"] = rb;

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(body);
    } else {
      throw Exception("Gagal update data gudang! code: ${response.statusCode}");
    }
  }
}

class EditPemesananService {
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
    final url = Uri.parse("${Config.baseUrl}/api/edit_pemesanan/$id");

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
      throw Exception("Gagal update data pemesanan! code: ${response.statusCode}");
    }
  }
}