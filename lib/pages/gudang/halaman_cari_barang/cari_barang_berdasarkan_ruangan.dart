import 'package:flutter/material.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/gudang/controller_cari_barang_lantai.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class CariBarangBerdasarkanRuangan extends StatefulWidget {
  const CariBarangBerdasarkanRuangan({super.key});

  @override
  State<CariBarangBerdasarkanRuangan> createState() =>
      _CariBarangBerdasarkanRuanganState();
}

class _CariBarangBerdasarkanRuanganState
    extends State<CariBarangBerdasarkanRuangan> {
  final TextEditingController _searchController = TextEditingController();
  final ControllerCariBarangLantai _controller = ControllerCariBarangLantai();

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

  Future<void> _exportToPDF() async {
    if (barangData == null) return;

    final pdf = pw.Document();

    final imageProvider = barangData!["foto_barang"] != null
        ? await networkImage(barangData!["foto_barang"])
        : null;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Data Barang Berdasarkan Ruangan',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                if (imageProvider != null)
                  pw.Image(imageProvider, height: 150, fit: pw.BoxFit.cover),
                pw.SizedBox(height: 20),
                pw.Text(
                  barangData!["nama_barang"] ?? "-",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("No BMN: ${barangData!["no_bmn"] ?? '-'}"),
                pw.Text("Lantai: ${barangData!["lantai"] ?? '-'}"),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Kondisi: B:${barangData!["B"] ?? 0}, RR:${barangData!["RR"] ?? 0}, RB:${barangData!["RB"] ?? 0}",
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text(
                  "Dicetak pada ${DateTime.now()}",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3A41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Cari Barang Berdasarkan Ruangan',
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    hintText: "Telusuri No Ruangan",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: hasData
                        ? SingleChildScrollView(child: _buildResultCard())
                        : const Text("", key: ValueKey("idle")),
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
                barangData!["foto_barang"] != null &&
                        barangData!["foto_barang"].toString().trim().isNotEmpty
                    ? Image.network(
                        barangData!["foto_barang"].toString().trim(),
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const Text("-", style: TextStyle(color: Colors.white)),

                const SizedBox(height: 20),
                Text(
                  barangData!["nama_barang"] ?? "-",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _exportToPDF,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Print / Ekspor ke PDF"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
