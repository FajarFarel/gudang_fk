import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';

class CariBarangBerdasarkanNoBmn extends StatefulWidget {
  const CariBarangBerdasarkanNoBmn({super.key});

  @override
  State<CariBarangBerdasarkanNoBmn> createState() => _CariBarangBerdasarkanNoBmnState();
}

class _CariBarangBerdasarkanNoBmnState extends State<CariBarangBerdasarkanNoBmn> {
  final TextEditingController _searchController = TextEditingController();
  bool hasData = false;

  void _search() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        hasData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3A41),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // warna AppBar gelap
        title: const Text('Cari Barang Berdasarkan No BMN',
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
                    hintText: "Telusuri No Surat",
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
                            " ",
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
          child: const Center(
            child: Text(
              "Menampilkan data dari\n no BMN",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              "Export",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}
