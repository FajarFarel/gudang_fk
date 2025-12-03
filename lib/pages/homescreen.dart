import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/pages/gudang/halamanutama.dart';
import 'package:gudang_fk/pages/atk/beranda_atk.dart';

class Homescreen extends StatefulWidget { // simpan role

  const Homescreen({
    super.key,
  });

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) { // buat cek
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Mau ke\n Gudang Mana?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.titleTextColor,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuGudangScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 80, vertical: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                "Gudang FK",
                style: TextStyle(
                    color: AppColors.buttonColor,
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // === Hanya munculkan jika role admin ===
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BerandaAtk()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "BHP dan ATK",
                  style: TextStyle(
                    color: AppColors.buttonColor,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
