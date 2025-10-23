import 'package:flutter/material.dart';
import 'package:gudang_fk/pages/homescreen.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obsecurePassword = true;
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan password harus diisi"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? result = await _authService.login(username, password);

setState(() {
  _isLoading = false;
});

if (result == null) {
  // sukses login
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Login Berhasil 🎉"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
    ),
  )..closed.then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    });
} else {
  // gagal login, tampilkan error spesifik dari backend
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result), // bisa "Username salah" atau "Password salah"
      backgroundColor: Colors.redAccent,
    ),
  );
}

  } // <-- Add this closing brace for _handleLogin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2930),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "LOGIN",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6EBF1),
              ),
            ),
            const SizedBox(height: 40),

            // Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: "Username",
                filled: true,
                fillColor: const Color(0xFF715A5A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: _obsecurePassword,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: const Color(0xFF715A5A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obsecurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obsecurePassword = !_obsecurePassword;
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),

            // Tombol Login
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3D3D3),
                foregroundColor: const Color(0xFF715A5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF715A5A))
                  : const Text("Login", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
