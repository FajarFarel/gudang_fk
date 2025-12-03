import 'package:flutter/material.dart';
import '../../../utility/colors.dart';

class AdminButton extends StatelessWidget {
  final bool isAdmin;         // apakah user adalah admin
  final bool value;           // status sekarang (ON/OFF)
  final Function(bool) onChanged;

  const AdminButton({
    super.key,
    required this.isAdmin,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // kalau bukan admin → jangan tampil
    if (!isAdmin) return const SizedBox.shrink();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: value ? AppColors.buttonColor : AppColors.buttonColor2,
        foregroundColor: value ? AppColors.textFieldFillColor : AppColors.textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () {
        onChanged(!value); // toggle
      },
      child: Text(
        value ? "Pemesanan Open" : "Pemesanan Closed",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
