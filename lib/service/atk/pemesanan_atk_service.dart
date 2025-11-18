import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/config.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ServicePemesananAtk {
  Future<bool> buatPemesanan(
    Map<String, dynamic> data,
    File? pickedImage,
  ) async {
    final url = Uri.parse('${Config.baseUrl}/api/pemesananatk');
    print("➡️ POST: $url");

    try {
      var request = http.MultipartRequest('POST', url);

      // Tambah field
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Tambah file foto kalau ada
      if (pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            pickedImage.path,
            contentType: MediaType('image', pickedImage.path.split('.').last),
          ),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: $respStr");

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }

  Future<List<dynamic>> getPemesanan() async {
    final url = Uri.parse('${Config.baseUrl}/api/pemesananatk');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal ambil data pemesanan");
      }
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }
}
