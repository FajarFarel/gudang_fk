// lib/view/tabel_stock_barang.dart
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/isi_tabel_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TabelStockBarang extends StatefulWidget {
  final int lantai;

  const TabelStockBarang({super.key, required this.lantai});

  @override
  State<TabelStockBarang> createState() => _TabelStockBarangState();
}

class _TabelStockBarangState extends State<TabelStockBarang> {
  final IsiTabelController _controller = IsiTabelController();

  @override
  void initState() {
    super.initState();
    // Aktifkan format tanggal Indonesia
    initializeDateFormatting('id_ID', null);
  }

  // Format tanggal jadi bahasa Indonesia
  String formatTanggal(String tgl) {
    if (tgl.isEmpty) return "-";
    try {
      // Hapus "GMT" atau zona waktu aneh dari string
      String cleanDate = tgl.replaceAll("GMT", "").trim();

      // Coba beberapa format umum
      DateTime? parsedDate;
      List<String> formats = [
        "EEE, dd MMM yyyy HH:mm:ss",
        "EEE, dd MMM yyyy HH:mm:ss zzz",
        "yyyy-MM-dd",
        "yyyy-MM-dd HH:mm:ss",
      ];

      for (var format in formats) {
        try {
          parsedDate = DateFormat(format, "en_US").parseLoose(cleanDate);
          break;
        } catch (_) {}
      }

      if (parsedDate == null) return tgl;

      // Ubah ke format Indonesia
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (_) {
      return tgl;
    }
  }

  TableCell headerCell(String mainText, {String? subText}) {
    return TableCell(
      child: Container(
        color: AppColors.tabelHeaderColor,
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mainText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            if (subText != null) ...[
              const SizedBox(height: 4),
              Text(
                subText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TableCell cell(
    String text, {
    FontWeight weight = FontWeight.normal,
    Color? color,
    Alignment align = Alignment.center,
    Color? textColor,
  }) {
    return TableCell(
      child: Container(
        alignment: align,
        padding: const EdgeInsets.all(8),
        color: color ?? const Color(0xFFF8F8F8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: weight,
            fontSize: 13,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tabel Barang - Lantai ${widget.lantai}",
          style: const TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _controller.getBarangByLantai(widget.lantai),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("Tidak ada data untuk lantai ini"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 2),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  // Header
                  TableRow(
                    children: [
                      headerCell("No"),
                      headerCell("No BMN"),
                      headerCell("Tanggal Barang Masuk"),
                      headerCell("Nama Barang"),
                      headerCell("Lantai"),
                      headerCell("Jumlah Barang"),
                      headerCell("Foto"),
                      headerCell("Kondisi Barang"),
                      headerCell("Jumlah Kondisi"),
                      headerCell("Barcode"),
                    ],
                  ),

                  // Data
                  for (int i = 0; i < data.length; i++)
                    TableRow(
                      children: [
                        cell((i + 1).toString()), // ✅ nomor urut dimulai dari 1
                        cell(data[i]["no_bmn"]),
                        cell(
                          formatTanggal(data[i]["tanggal_barang_datang"] ?? ""),
                        ),
                        cell(data[i]["nama_barang"]),
                        cell(data[i]["lantai"].toString()),
                        cell(data[i]["jumlah_satuan"].toString()),
                        TableCell(
                          child: Container(
                            color: const Color(0xFFF8F8F8),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child:
                                data[i]["foto_barang"] != null &&
                                    data[i]["foto_barang"].toString().isNotEmpty
                                ? Image.network(
                                    data[i]["foto_barang"],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text("Gagal muat");
                                    },
                                  )
                                : const Text("-"),
                          ),
                        ),
                        cell(
                          "B:${data[i]["B"] ?? 0}, RR:${data[i]["RR"] ?? 0}, RB:${data[i]["RB"] ?? 0}",
                        ),
                        cell(
                          ((data[i]["B"] ?? 0) +
                                  (data[i]["RR"] ?? 0) +
                                  (data[i]["RB"] ?? 0))
                              .toString(),
                        ),
                        TableCell(
                          child: Container(
                            color: const Color(0xFFF8F8F8),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child:
                                  (data[i]["no_barcode"] != null &&
                                      data[i]["no_barcode"]
                                          .toString()
                                          .isNotEmpty)
                                  ? BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data: data[i]["no_barcode"].toString(),
                                      width: 120,
                                      height: 60,
                                      drawText: true,
                                    )
                                  : const Text("-"),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
