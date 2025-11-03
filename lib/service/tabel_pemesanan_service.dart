import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/config.dart';

class TabelPemesananService {
  Future<List<Map<String, dynamic>>> fetchPemesanan() async {
    final url = Uri.parse('${Config.baseUrl}/api/pemesanan');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal mengambil data pemesanan');
    }
  }
}
