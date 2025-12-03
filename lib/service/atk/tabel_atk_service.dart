// lib/service/barang_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/config.dart';

class IsiTabelAtkService { // ubah sesuai IP backend kamu

  static Future<List<Map<String, dynamic>>> fetchAtk({String? kategori}) async {
    final url = Uri.parse('${Config.baseUrl}/api/isitabelatk?kategori=${kategori ?? ''}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Gagal ambil data dari server: ${response.statusCode}');
    }
  }
}
