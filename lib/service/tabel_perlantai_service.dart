import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/config.dart';

class LantaiService {
  static Future<List<int>> fetchLantai() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/lantai'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data adalah List<Map<String, dynamic>>
      return List<int>.from(data.map((item) => int.parse(item['lantai'].toString())));
    } else {
      throw Exception("Gagal memuat data lantai");
    }
  }
}
