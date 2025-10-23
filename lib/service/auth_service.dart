import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/config.dart';

class AuthService {
Future<String?> login(String nama, String password) async {
  final url = Uri.parse('${Config.baseUrl}/api/login');
  final bodyJson = jsonEncode({'nama': nama, 'password': password});

  print("➡️ Request URL: $url");
  print("➡️ Request body: $bodyJson");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    print("⬅️ Status code: ${response.statusCode}");
    print("⬅️ Response body: ${response.body}");

    final data = jsonDecode(response.body);

    // Ambil pesan error walaupun status code 401
    if (response.statusCode == 200) {
      return null; // login berhasil
    } else {
      // login gagal → tampilkan message dari backend
      return data['error'] ?? "Email atau password salah";
    }
  } catch (e) {
    print("❌ Exception: $e");
    return "Gagal koneksi ke server: $e";
  }
}
} 
