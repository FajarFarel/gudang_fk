import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';

class MasukkanDataBarangATK extends StatefulWidget {
  const MasukkanDataBarangATK({super.key});

  @override
  State<MasukkanDataBarangATK> createState() => _MasukkanDataBarangATKState();
}

class _MasukkanDataBarangATKState extends State<MasukkanDataBarangATK> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Masukkan Data Barang ATK',
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