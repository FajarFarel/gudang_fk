import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gudang_fk/controller/gudang/tabel_pemesanan_controller.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class TabelPemesanan extends StatefulWidget {
  const TabelPemesanan({super.key});

  @override
  State<TabelPemesanan> createState() => _TabelPemesananState();
}

class _TabelPemesananState extends State<TabelPemesanan> {
  final TabelPemesananController _controller = TabelPemesananController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    // 🧹 Bersihkan cache biar gambar baru muncul
    CachedNetworkImage.evictFromCache("");
  }

  String formatTanggal(String tgl) {
    try {
      DateTime parsed = DateTime.parse(tgl);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return tgl;
    }
  }

  TableCell header(String text) => TableCell(
        child: Container(
          color: AppColors.tabelHeaderColor,
          padding: const EdgeInsets.all(6),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      );

  TableCell cell(String text) => TableCell(
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          color: const Color(0xFFF8F8F8),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tabel Pemesanan',
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _controller.getPemesanan(),
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
            return const Center(child: Text('Belum ada data pemesanan'));
          }

          // Group data berdasarkan tanggal pemesanan
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (var d in data) {
            final tgl = d["tanggal_pemesanan"] ?? "Tidak diketahui";
            grouped.putIfAbsent(tgl, () => []).add(d);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              final tanggal = formatTanggal(entry.key);
              final list = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.blueGrey[100],
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      tanggal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.black, width: 1.5),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          children: [
                            header("No"),
                            header("Nama Pemesan"),
                            header("Jumlah"),
                            header("Satuan"),
                            header("Spesifikasi"),
                            header("Nama Barang"),
                            header("Nama Ruangan"),
                            header("Harga"),
                            header("Link Pembelian"),
                            header("Foto Barang"),
                            header("Status"),
                          ],
                        ),
                        for (int i = 0; i < list.length; i++)
                          TableRow(
                            children: [
                              cell((i + 1).toString()),
                              cell(list[i]["nama_pemesan"] ?? "-"),
                              cell(list[i]["jumlah"].toString()),
                              cell(list[i]["satuan"] ?? "-"),
                              cell(list[i]["spesifikasi"] ?? "-"),
                              cell(list[i]["nama_barang"] ?? "-"),
                              cell(list[i]["nama_ruangan"] ?? "-"),
                              cell(list[i]["harga"].toString()),

                              // LINK PEMBELIAN
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  color: const Color(0xFFF8F8F8),
                                  child: list[i]["link_pembelian"] != null &&
                                          list[i]["link_pembelian"] != ""
                                      ? InkWell(
                                          onTap: () async {
                                            final link =
                                                list[i]["link_pembelian"];
                                            final url = Uri.parse(link);

                                            try {
                                              if (Platform.isWindows) {
                                                await Process.run('start', [
                                                  link,
                                                ], runInShell: true);
                                              } else {
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                } else {
                                                  throw 'Tidak bisa membuka URL';
                                                }
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Gagal membuka link: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            list[i]["link_pembelian"],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        )
                                      : const Text("-"),
                                ),
                              ),

                              // FOTO BARANG
                              TableCell(
                                child: Container(
                                  color: const Color(0xFFF8F8F8),
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Builder(
                                    builder: (context) {
                                      final rawUrl = list[i]["foto_url"];
                                      if (rawUrl == null ||
                                          rawUrl.toString().trim().isEmpty) {
                                        return const Text("-");
                                      }

                                      final url = rawUrl.toString().trim();
                                      final id = list[i]["id"] ?? i;

                                      final finalUrl = "$url?v=$id";

                                      try {
                                        final uri = Uri.parse(finalUrl);

                                        return CachedNetworkImage(
                                          key: ValueKey("img_$id"),
                                          imageUrl: uri.toString(),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          useOldImageOnUrlChange: false,
                                          cacheKey: "cache_$id",
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          errorWidget:
                                              (context, url, error) {
                                            print(
                                                "🧨 Gagal load foto: $error, URL: '$url'");
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

                              cell(list[i]["status"] ?? "-"),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
