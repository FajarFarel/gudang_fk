import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../api/config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String nama, String password) async {
  final url = Uri.parse('${Config.baseUrl}/api/login');

  final bodyJson = jsonEncode({'nama': nama, 'password': password});

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": data["user"]
      };
    } else {
      return {
        "success": false,
        "message": data["error"] ?? "Login gagal"
      };
    }
  } catch (e) {
    return {"success": false, "message": "Error koneksi: $e"};
  }
}

}
