// lib/view/tabel_stock_barang.dart
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:gudang_fk/controller/atk/tabel_atk_controller.dart';
import 'package:gudang_fk/controller/atk/hapus_data_atk_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

class TabelStockAtk extends StatefulWidget {
  const TabelStockAtk({super.key});

  @override
  State<TabelStockAtk> createState() => _TabelStockAtkState();
}

class _TabelStockAtkState extends State<TabelStockAtk> {
  final IsiTabelAtkController _controller = IsiTabelAtkController();
  final HapusDataAtkController _hapusDataAtkController =
      HapusDataAtkController();
  final EditDataAtkController _editDataAtkController = EditDataAtkController();

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
        title: const Text(
          "Tabel ATK",
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _controller.getAtk(kategori: "atk"),
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
                      headerCell("Jumlah Barang"),
                      headerCell("satuan"),
                      headerCell("Foto"),
                      headerCell("Kondisi Barang"),
                      headerCell("Jumlah Kondisi"),
                      headerCell("Barcode"),
                      headerCell("Aksi"),
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
                        cell(data[i]["jumlah"].toString()),
                        cell(data[i]["satuan"]),
                        TableCell(
                          child: Container(
                            color: const Color(0xFFF8F8F8),
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Builder(
                              builder: (context) {
                                final rawUrl = data[i]["foto_barang"];
                                if (rawUrl == null ||
                                    rawUrl.toString().trim().isEmpty) {
                                  return const Text("-");
                                }

                                final url = rawUrl.toString().trim();

                                try {
                                  final uri = Uri.parse(
                                    url,
                                  ); // pastikan format valid
                                  return Image.network(
                                    uri.toString(),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                        "🧨 Gagal load foto: $error, URL: '$url'",
                                      );
                                      return const Text("Gagal muat");
                                    },
                                  );
                                } catch (e) {
                                  print("🧨 Format URL salah: $rawUrl");
                                  return const Text("URL salah");
                                }
                              },
                            ),
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
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // TOMBOL EDIT
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final id = data[i]["id"];
                                    final namabarang = TextEditingController(
                                      text: data[i]["nama_barang"].toString(),
                                    );
                                    final noBMN = TextEditingController(
                                      text: data[i]["no_bmn"].toString(),
                                    );
                                    final tanggalbarangdatang =
                                        TextEditingController(
                                          text: data[i]["tanggal_barang_datang"]
                                              .toString(),
                                        );
                                    final jumlah = TextEditingController(
                                      text: data[i]["jumlah"].toString(),
                                    );
                                    final satuan = TextEditingController(
                                      text: data[i]["satuan"].toString(),
                                    );
                                    final spesifikasi = TextEditingController(
                                      text: data[i]["spesifikasi"].toString(),
                                    );
                                    final namaruangan = TextEditingController(
                                      text: data[i]["nama_ruangan"].toString(),
                                    );
                                    final kategori = TextEditingController(
                                      text: data[i]["kategori"].toString(),
                                    );
                                    File? selectedFotoAtk;
                                    final fotoatkLama = data[i]["foto_barang"];
                                    final bController = TextEditingController(
                                      text: data[i]["B"].toString(),
                                    );
                                    final rrController = TextEditingController(
                                      text: data[i]["RR"].toString(),
                                    );
                                    final rbController = TextEditingController(
                                      text: data[i]["RB"].toString(),
                                    );

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          title: const Text("Edit Data Gudang"),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: noBMN,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "No BMN",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: namabarang,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Nama Barang",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller:
                                                      tanggalbarangdatang,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            "Tanggal Barang Datang",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: jumlah,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Jumlah",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: satuan,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Satuan",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: spesifikasi, 
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Spesifikasi",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: kategori,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Kategori",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: bController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "B",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: rrController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "RR",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: rbController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "RB",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final sukses =
                                                    await _editDataAtkController
                                                        .editAtk(
                                                          id: id,
                                                          noBMN:
                                                              noBMN.text,
                                                          namabarang:
                                                              namabarang.text,
                                                          tanggalbarangdatang:
                                                              tanggalbarangdatang
                                                                  .text,
                                                          jumlah: jumlah.text,
                                                          satuan: satuan.text,
                                                          spesifikasi:
                                                              spesifikasi.text,
                                                          namaruangan:
                                                              namaruangan.text,
                                                          kategori:
                                                              kategori.text,
                                                          fotoatkBaru:
                                                              selectedFotoAtk,
                                                          b: bController.text,
                                                          rr: rrController.text,
                                                          rb: rbController.text,
                                                        );

                                                if (!context.mounted) return;

                                                if (sukses) {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Data berhasil diperbarui 😎",
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Gagal memperbarui 😥",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text("Simpan"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),

                                // TOMBOL HAPUS
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final id = data[i]["id"];

                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Hapus Data"),
                                        content: Text(
                                          "Yakin ingin menghapus data dengan ID $id?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      final success =
                                          await _hapusDataAtkController
                                              .hapusBarang(id);

                                      if (success) {
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Berhasil menghapus"),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Gagal menghapus"),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
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
