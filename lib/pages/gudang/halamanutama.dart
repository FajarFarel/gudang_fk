import 'package:flutter/material.dart';
import 'package:gudang_fk/pages/gudang/halaman_cari_barang/cari_barang_berdasarkan_barcode.dart';
import 'package:gudang_fk/pages/gudang/halaman_cari_barang/cari_barang_berdasarkan_no_bmn.dart';
import 'package:gudang_fk/pages/gudang/halaman_cari_barang/cari_barang_berdasarkan_ruangan.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'masukkan_data_barang.dart';
import 'tabel_data_barang_perlantai.dart';
import 'pemesanan.dart';

class MenuGudangScreen extends StatelessWidget {
  const MenuGudangScreen({super.key});

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
                      builder: (context) => const InputBarangScreen(),
                    ),
                  );
                  // Navigasi ke halaman input data
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Stock Barang Per Lantai", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TabelDataBarangPerlantai(),
                    ),
                  );
                  // Navigasi ke halaman stock per lantai
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Cari Barang\n Berdasarkan No BMN", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CariBarangBerdasarkanNoBmn(),
                    ),
                  );
                  // Navigasi ke halaman stock berdasarkan no surat
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Cari Barang\n Berdasarkan Ruangan", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CariBarangBerdasarkanRuangan(),
                    ),
                  );
                  // Navigasi ke halaman data supplier
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Cari Barang\n Berdasarkan Barcode", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CariBarangBerdasarkanBarcode(),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                _buildMenuButton("Pemesanan", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PemesananPage(
                      
                    )),
                  );
                  // Navigasi ke halaman pemesanan
                }),
                const SizedBox(height: 40),
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
