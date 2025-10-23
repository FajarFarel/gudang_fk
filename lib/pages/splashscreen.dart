import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'login.dart';
import 'package:gudang_fk/api/config.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  int _seconds = 0;
  late Timer _timer;

  // minimal waktu splash (detik)
  final int _minCountdown = 3;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final start = DateTime.now();
    try {
      final response = await http
          .get(Uri.parse("${Config.baseUrl}/api/status"))
          .timeout(const Duration(seconds: 15));

      final elapsed = DateTime.now().difference(start).inSeconds;

      if (response.statusCode == 200) {
        // hitung durasi countdown
        final countdown = elapsed < _minCountdown ? _minCountdown : elapsed;
        setState(() {
          _seconds = countdown;
        });
        _startCountdown();
      } else {
        _showSnackBar("Server error: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      print('🔥 Error connecting to server: $e');
      print('📜 Stacktrace: $stacktrace');
      _showSnackBar("Tidak bisa terhubung ke server.\nCek koneksi internetmu.");

    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        _timer.cancel();
        _goToLogin();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  void _goToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: _checkServer,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF37353E),
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: SvgPicture.asset(
                "assets/rumah.svg",
                width: 200,
                height: 250,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "WELCOME",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
            const SizedBox(height: 10),
            if (_seconds > 0)
              Text(
                "Loading in $_seconds...",
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
