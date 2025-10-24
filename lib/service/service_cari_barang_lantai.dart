import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/config.dart';

class ServiceCariBarangLantai {

  // Fungsi pencarian barang berdasarkan barcode
  static Future<Map<String, dynamic>?> cariBarangByLantai(String lantai) async {
    final url = Uri.parse("${Config.baseUrl}/api/cari/lantai?lantai=$lantai");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'];
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error cariBarangByLantai: $e");
      return null;
    }
  }
}
