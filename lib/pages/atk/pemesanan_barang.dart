import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';

class PemesananBarangATK extends StatefulWidget {
  const PemesananBarangATK({super.key});

  @override
  State<PemesananBarangATK> createState() => _PemesananBarangATKState();
}

class _PemesananBarangATKState extends State<PemesananBarangATK> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Pemesanan Barang ATK',
          style: TextStyle(color: AppColors.buttonColor, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}