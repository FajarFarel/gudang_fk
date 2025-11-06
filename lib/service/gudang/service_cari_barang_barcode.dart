import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';

class ServiceCariBarangBarcode {

  // Fungsi pencarian barang berdasarkan barcode
  static Future<Map<String, dynamic>?> cariBarangByBarcode(String barcode) async {
    final url = Uri.parse("${Config.baseUrl}/api/cari/barcode?barcode=$barcode");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'];
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error cariBarangByBarcode: $e");
      return null;
    }
  }
}
