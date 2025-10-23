import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';

class Pemesanan extends StatelessWidget {
  const Pemesanan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // warna AppBar gelap
        title: const Text('Pemesanan',
            style: TextStyle(
              color: AppColors.titleTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor, // background utama
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor, // warna kotak form
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.cardborderColor,
                      width: 7,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildTextField("Nama Barang:"),
                      const SizedBox(height: 15),
                      _buildTextField("Jumlah/Satuan:"),
                      const SizedBox(height: 15),
                      _buildTextField("Nama Ruangan:"),
                      const SizedBox(height: 15),
                      _buildTextField("Harga:"),
                      const SizedBox(height: 15),
                      _buildTextField("Link Pembelian:"),
                      const SizedBox(height: 15),          
                    ],
                  ),
                ),
                    
                 const SizedBox(height: 30),
                    
                // Tombol Kirim (di luar card)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: AppColors.buttonColor, // warna tombol
                      foregroundColor: AppColors.backgroundColor, // warna teks
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: AppColors.backgroundColor),
        filled: true,
        fillColor: AppColors.titleTextColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: AppColors.backgroundColor),
    );
  }
}
