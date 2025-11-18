import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gudang_fk/controller/atk/tabel_pemesanan_atk_controller.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TabelPemesananAtk extends StatefulWidget {
  const TabelPemesananAtk({super.key});

  @override
  State<TabelPemesananAtk> createState() => _TabelPemesananAtkState();
}

class _TabelPemesananAtkState extends State<TabelPemesananAtk> {
  final TabelPemesananATKController _controller = TabelPemesananATKController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    CachedNetworkImage.evictFromCache("");
  }

  String formatTanggal(String tgl) {
    try {
      tgl = tgl.trim();

      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tgl)) {
        return tgl;
      }

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
          'Tabel Pemesanan ATK',
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

          // Group data by month
          final groupedByMonth = <String, List<Map<String, dynamic>>>{};

          DateTime? safeParseDate(String? input) {
            if (input == null || input.trim().isEmpty) return null;
            try {
              final cleaned = input.split(" ").first.trim();

              if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleaned)) {
                return DateTime.parse(cleaned);
              }

              final possible = DateFormat(
                'EEEE, dd MMMM yyyy',
                'id_ID',
              ).parseLoose(input, true);
              return possible;
            } catch (_) {
              return null;
            }
          }

          for (var d in data) {
            final tglRaw = d["tanggal_pemesanan"];
            final tgl = safeParseDate(tglRaw);
            if (tgl == null) continue;

            final bulanKey = DateFormat("MMMM yyyy", "id_ID").format(tgl);
            groupedByMonth.putIfAbsent(bulanKey, () => []).add(d);
          }

          return ListView(
            children: groupedByMonth.entries.map((monthEntry) {
              final bulan = monthEntry.key;
              final listBulan = monthEntry.value;

              // Group again by date inside the same month
              final groupedByDate = <String, List<Map<String, dynamic>>>{};
              for (var d in listBulan) {
                final tgl = d["tanggal_pemesanan"] ?? "Tidak diketahui";
                groupedByDate.putIfAbsent(tgl, () => []).add(d);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                    cell(listTanggal[i]["harga"].toString()),

                                    // Link
                                    TableCell(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        child: (listTanggal[i]["link_pembelian"] ?? "")
                                                .toString()
                                                .isNotEmpty
                                            ? InkWell(
                                                onTap: () async {
                                                  final url = Uri.parse(listTanggal[i]["link_pembelian"]);
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(
                                                      url,
                                                      mode: LaunchMode.externalApplication,
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  listTanggal[i]["link_pembelian"],
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              )
                                            : const Text("-"),
                                      ),
                                    ),

                                    // Foto Barang
                                    TableCell(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        child: CachedNetworkImage(
                                          imageUrl: listTanggal[i]["foto_url"] ?? "",
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

                  // Print Button
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
