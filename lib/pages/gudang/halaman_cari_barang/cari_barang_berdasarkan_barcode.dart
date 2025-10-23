import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/controller_cari_barang_barcode.dart';

class CariBarangBerdasarkanBarcode extends StatefulWidget {
  const CariBarangBerdasarkanBarcode({super.key});

  @override
  State<CariBarangBerdasarkanBarcode> createState() => _CariBarangBerdasarkanBarcodeState();
}

class _CariBarangBerdasarkanBarcodeState extends State<CariBarangBerdasarkanBarcode> {
  final TextEditingController _searchController = TextEditingController();
  final BarangController _controller = BarangController();

  bool hasData = false;
  Map<String, dynamic>? barangData;

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final result = await _controller.cariBarang(query);

    setState(() {
      hasData = true;
      barangData = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3A41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Cari Barang Berdasarkan Barcode',
          style: TextStyle(
            color: AppColors.titleTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔍 Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: "Telusuri No Barcode",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(height: 24),

              // ⚙️ Conditional UI
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: child,
                    ),
                    child: hasData
                        ? _buildResultCard()
                        : const Text(
                            "",
                            key: ValueKey("idle"),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (barangData == null) {
      return const Text(
        "Barang tidak ditemukan",
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    return Column(
      key: const ValueKey("result"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 500,
          width: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF50494E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  barangData!["nama_barang"] ?? "-",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "No BMN: ${barangData!["no_bmn"] ?? '-'}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "Lantai: ${barangData!["lantai"] ?? '-'}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Kondisi: B:${barangData!["B"] ?? 0}, RR:${barangData!["RR"] ?? 0}, RB:${barangData!["RB"] ?? 0}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                barangData!["foto_barang"] != null &&
                        barangData!["foto_barang"].toString().isNotEmpty
                    ? Image.network(
                        barangData!["foto_barang"],
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const Text("-", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
