import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/tabel_perlantai_controller.dart';
import 'package:gudang_fk/pages/gudang/halaman_tabel/tabel_per_lantai.dart';

class TabelDataBarangPerlantai extends StatelessWidget {
  final LantaiController controller = LantaiController();

  TabelDataBarangPerlantai({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Tabel Data Barang Per Lantai',
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: FutureBuilder<List<int>>(
          future: controller.getLantaiList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            if (snapshot.hasError) {
              return Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                "Tidak ada data lantai",
                style: TextStyle(color: Colors.white),
              );
            }

            final lantaiList = snapshot.data!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Mau ke Lantai\nBerapa?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.titleTextColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Column(
                    children: lantaiList.map((lantai) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TabelStockBarang(lantai: lantai),
                              ),
                            );
                          },
                          child: Text(
                            "Lantai $lantai",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
