import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../api/config.dart';
import 'dart:convert';

class ATKService {

  Future<bool> tambahBarang(Map<String, dynamic> data, File? image) async {
    final url = Uri.parse("${Config.baseUrl}/api/atk/keluar");

    var request = http.MultipartRequest("POST", url);

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          image.path,
          contentType: MediaType('image', 'jpg'),
        ),
      );
    }

    var response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }



Future<Map<String, dynamic>> getStok({String? kategori}) async {
  final url = kategori == null
      ? Uri.parse("${Config.baseUrl}/api/stok")
      : Uri.parse("${Config.baseUrl}/api/stok?kategori=$kategori");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {};
  }
}


  Future<bool> tambahKeluar(Map<String, dynamic> data) async {
    final url = Uri.parse("${Config.baseUrl}/api/atk/keluar");

    final response = await http.post(
      url,
      body: data,
    );

    return response.statusCode == 201;
  }
}
