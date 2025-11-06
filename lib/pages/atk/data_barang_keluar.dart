import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';

class DataBarangKeluarATK extends StatefulWidget {
  const DataBarangKeluarATK({super.key});

  @override
  State<DataBarangKeluarATK> createState() => _DataBarangKeluarATKState();
}

class _DataBarangKeluarATKState extends State<DataBarangKeluarATK> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Data Barang Keluar ATK',
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
