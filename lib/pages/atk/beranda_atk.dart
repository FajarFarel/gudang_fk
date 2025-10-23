import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/pages/atk/data_barang_keluar.dart';
import 'package:gudang_fk/pages/atk/masukkan_data_barang.dart';
import 'package:gudang_fk/pages/atk/pemesanan_barang.dart';

class BerandaAtk extends StatelessWidget {
  const BerandaAtk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // warna AppBar gelap
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ), // warna background gelap
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                const SizedBox(height: 50),
                // Judul Halaman
                const Text(
                  "Mau Ke Halaman\nMana?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.titleTextColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                  ),
                ),
                const SizedBox(height: 60),

                // Tombol Menu
                _buildMenuButton("Masukkan Data Barang", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MasukkanDataBarang(),
                    ),
                  );
                  // Navigasi ke halaman input data
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Barang Keluar", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataBarangKeluar(),
                    ),
                  );
                  // Navigasi ke halaman stock per lantai
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Pemesanan Barang", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PemesananBarang(),
                    ),
                  );
                  // Navigasi ke halaman stock berdasarkan no surat
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: 300,
      height: 80,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor2, // warna tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.buttonColor, // warna teks tombol
            fontFamily: 'poppins',
          ),
        ),
      ),
    );
  }
}
