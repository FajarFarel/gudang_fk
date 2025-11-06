// lib/service/barang_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/config.dart';

class IsiTabelService { // ubah sesuai IP backend kamu

  static Future<List<Map<String, dynamic>>> fetchBarangByLantai(int lantai) async {
    final url = Uri.parse('${Config.baseUrl}/api/isitabel/$lantai');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Gagal ambil data dari server: ${response.statusCode}');
    }
  }
}
