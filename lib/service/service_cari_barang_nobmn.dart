import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/config.dart';

class ServiceCariBarangNoBMN {

  // Fungsi pencarian barang berdasarkan nobmn
  static Future<Map<String, dynamic>?> cariBarangByNoBMN(String nobmn) async {
    final url = Uri.parse("${Config.baseUrl}/api/cari/nobmn?nobmn=$nobmn");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'];
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error cariBarangByNoBMN: $e");
      return null;
    }
  }
}
