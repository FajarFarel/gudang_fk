import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gudang_fk/controller/gudang/tabel_pemesanan_controller.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:url_launcher/url_launcher.dart';
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
      // Bersihkan spasi
      tgl = tgl.trim();

      // Kalau bukan format "YYYY-MM-DD", jangan parse
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tgl)) {
        return tgl;
      }

      // Format normal dari backend, parse seperti biasa
      DateTime parsed = DateTime.parse(tgl);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsed);
    } catch (e) {
      print("⚠️ Error parsing tanggal: $tgl ($e)");
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
          print("====================================");
          print("📌 DATA YANG DITERIMA DARI BACKEND:");
          for (var item in data) {
            print(item);
          }
          print("====================================");
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada data pemesanan'));
          }

          // 🗓️ Group data berdasarkan bulan (aman dari format aneh)
          final groupedByMonth = <String, List<Map<String, dynamic>>>{};
          DateTime? safeParseDate(String? input) {
            print("🔍 Parsing tanggal mentah: '$input'");

            if (input == null || input.trim().isEmpty) {
              print("⛔ Kosong, skip");
              return null;
            }

            final cleaned = input.trim();

            try {
              // --- Case 1: Format ISO atau ISO + waktu ---
              final iso = cleaned.split(" ").first;
              if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(iso)) {
                final parsed = DateTime.parse(iso);
                print("✅ ISO berhasil: $parsed");
                return parsed;
              }

              // --- Case 2: Format Indonesia: 'Senin, 04 November 2025' ---
              try {
                final parsedIndo = DateFormat(
                  'EEEE, dd MMMM yyyy',
                  'id_ID',
                ).parseLoose(cleaned);

                print("✅ Format Indo berhasil: $parsedIndo");
                return parsedIndo;
              } catch (_) {
                print("❌ Bukan format Indo");
              }

              print("❌ Gagal parse semua format");
              return null;
            } catch (e) {
              print("❌ Error parsing tanggal: $e");
              return null;
            }
          }

          for (var d in data) {
            final tglRaw = d["tanggal_pemesanan"];
            final tgl = safeParseDate(tglRaw);
            if (tgl == null) continue; // skip kalau gagal parse

            final bulanKey = DateFormat("MMMM yyyy", "id_ID").format(tgl);
            groupedByMonth.putIfAbsent(bulanKey, () => []).add(d);
          }

          return ListView(
            children: groupedByMonth.entries.map((monthEntry) {
              final bulan = monthEntry.key;
              final listBulan = monthEntry.value;

              // 🧩 Dalam bulan ini, group lagi berdasarkan tanggal
              final groupedByDate = <String, List<Map<String, dynamic>>>{};
              for (var d in listBulan) {
                final tgl = d["tanggal_pemesanan"] ?? "Tidak diketahui";
                print("RAW TANGGAL: ${d["tanggal_pemesanan"]}");
                print("PARSE: ${safeParseDate(d["tanggal_pemesanan"])}");
                groupedByDate.putIfAbsent(tgl, () => []).add(d);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header Bulan
                  Container(
                    color: Colors.blueGrey[200],
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      bulan.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // 🔹 Loop tiap tanggal di bulan ini
                  ...groupedByDate.entries.map((dateEntry) {
                    final tanggal = formatTanggal(dateEntry.key);
                    final listTanggal = dateEntry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.blueGrey[100],
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
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
                            border: TableBorder.all(
                              color: Colors.black,
                              width: 1.2,
                            ),
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
                                ],
                              ),
                              for (int i = 0; i < listTanggal.length; i++)
                                TableRow(
                                  children: [
                                    cell((i + 1).toString()),
                                    cell(listTanggal[i]["nama_pemesan"] ?? "-"),
                                    cell(listTanggal[i]["jumlah"].toString()),
                                    cell(listTanggal[i]["satuan"] ?? "-"),
                                    cell(listTanggal[i]["spesifikasi"] ?? "-"),
                                    cell(listTanggal[i]["nama_barang"] ?? "-"),
                                    cell(listTanggal[i]["nama_ruangan"] ?? "-"),
                                    cell(listTanggal[i]["harga"].toString()),

                                    // 🔗 Link Pembelian
                                    TableCell(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        child:
                                            (listTanggal[i]["link_pembelian"] ??
                                                    "")
                                                .toString()
                                                .isNotEmpty
                                            ? InkWell(
                                                onTap: () async {
                                                  final link =
                                                      listTanggal[i]["link_pembelian"];
                                                  final url = Uri.parse(link);
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(
                                                      url,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  listTanggal[i]["link_pembelian"],
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              )
                                            : const Text("-"),
                                      ),
                                    ),

                                    // 🖼️ Foto Barang
                                    TableCell(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              listTanggal[i]["foto_url"] ?? "",
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorWidget: (c, u, e) =>
                                              const Text("Gagal muat"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  // 🖨 Tombol Print per Bulan
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor2,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final data = await _controller.getPemesanan();
                        await _controller.generatePdfForMonth(data);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text("Print Laporan Bulan $bulan"),
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
