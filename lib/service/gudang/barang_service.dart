import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../api/config.dart';

class BarangService {
  Future<bool> tambahBarang(
    Map<String, dynamic> data,
    File? pickedImage,
  ) async {
    final url = Uri.parse('${Config.baseUrl}/api/input');
    print("➡️ POST (multipart): $url");

    try {
      var request = http.MultipartRequest('POST', url);

      // Tambah field
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Tambah file gambar
      if (pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_barang',
            pickedImage.path,
            contentType: MediaType('image', 'jpeg'), // sesuaikan format
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }

  Future<List<dynamic>> getBarang() async {
    final url = Uri.parse('${Config.baseUrl}/api/barang');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal ambil data barang");
      }
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }

  // Future<List<dynamic>> getPemesananPending({String? kategori}) async {
  //   final url = Uri.parse(
  //     kategori != null && kategori.isNotEmpty
  //         ? '${Config.baseUrl}/api/pemesanan/pending?kategori=$kategori'
  //         : '${Config.baseUrl}/api/pemesanan/pending',
  //   );

  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception("Gagal ambil data pemesanan pending");
  //     }
  //   } catch (e) {
  //     print("❌ Error ambil pemesanan: $e");
  //     return [];
  //   }
  // }

  Future<bool> updateStatusPemesanan(int idPemesanan, String statusBaru) async {
    final url = Uri.parse('${Config.baseUrl}/api/pemesanan/$idPemesanan');
    final response = await http.put(url, body: {'status': statusBaru});
    return response.statusCode == 200;
  }
}
