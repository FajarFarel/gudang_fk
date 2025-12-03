import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gudang_fk/controller/atk/tabel_pemesanan_atk_controller.dart';
import 'package:gudang_fk/utility/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gudang_fk/controller/atk/hapus_data_atk_controller.dart';
import 'package:gudang_fk/utility/print.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../api/config.dart';

class TabelPemesananAtk extends StatefulWidget {
  const TabelPemesananAtk({super.key});

  @override
  State<TabelPemesananAtk> createState() => _TabelPemesananAtkState();
}

class _TabelPemesananAtkState extends State<TabelPemesananAtk> {
  final TabelPemesananATKController _controller = TabelPemesananATKController();
  final HapusAtkController _hapusController = HapusAtkController();
  final EditPemesananController _editPemesananAtkController = EditPemesananController();

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
                                  header("Aksi"),
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
                                        child:
                                            (listTanggal[i]["link_pembelian"] ??
                                                    "")
                                                .toString()
                                                .isNotEmpty
                                            ? InkWell(
                                                onTap: () async {
                                                  final url = Uri.parse(
                                                    listTanggal[i]["link_pembelian"],
                                                  );
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

                                    // Foto Barang
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
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                print("INDEX: $i");
                                                print(
                                                  "DATA DITEKAN: ${listTanggal[i]}",
                                                );

                                                final currentItem =
                                                    listTanggal[i];
                                                final id = currentItem["id"];

                                                final namaPemesanController =
                                                    TextEditingController(
                                                      text:
                                                          currentItem["nama_pemesan"] ??
                                                          "",
                                                    );
                                                final namaBarangController =
                                                    TextEditingController(
                                                      text:
                                                          currentItem["nama_barang"] ??
                                                          "",
                                                    );
                                                final jumlahController =
                                                    TextEditingController(
                                                      text:
                                                          (currentItem["jumlah"] ??
                                                                  "")
                                                              .toString(),
                                                    );
                                                String rawDate =
                                                    (currentItem["tanggal_pemesanan"] ??
                                                            "")
                                                        .toString();

                                                // Normalisasi nama bulan indonesia
                                                rawDate = rawDate
                                                    .replaceAll(
                                                      "januari",
                                                      "Januari",
                                                    )
                                                    .replaceAll(
                                                      "februari",
                                                      "Februari",
                                                    )
                                                    .replaceAll(
                                                      "maret",
                                                      "Maret",
                                                    )
                                                    .replaceAll(
                                                      "april",
                                                      "April",
                                                    )
                                                    .replaceAll("mei", "Mei")
                                                    .replaceAll("juni", "Juni")
                                                    .replaceAll("juli", "Juli")
                                                    .replaceAll(
                                                      "agustus",
                                                      "Agustus",
                                                    )
                                                    .replaceAll(
                                                      "september",
                                                      "September",
                                                    )
                                                    .replaceAll(
                                                      "oktober",
                                                      "Oktober",
                                                    )
                                                    .replaceAll(
                                                      "november",
                                                      "November",
                                                    )
                                                    .replaceAll(
                                                      "desember",
                                                      "Desember",
                                                    );

                                                DateTime parsedDate;

                                                // coba parse ISO first (yyyy-MM-dd)
                                                final isoPart = rawDate
                                                    .split(" ")
                                                    .first;
                                                if (RegExp(
                                                  r'^\d{4}-\d{2}-\d{2}$',
                                                ).hasMatch(isoPart)) {
                                                  parsedDate = DateTime.parse(
                                                    isoPart,
                                                  );
                                                } else if (rawDate.contains(
                                                      "-",
                                                    ) &&
                                                    rawDate.split("-").length ==
                                                        3) {
                                                  // format dd-MM-yyyy
                                                  final parts = rawDate.split(
                                                    "-",
                                                  );
                                                  parsedDate = DateTime(
                                                    int.parse(parts[2]),
                                                    int.parse(parts[1]),
                                                    int.parse(parts[0]),
                                                  );
                                                } else {
                                                  parsedDate = DateFormat(
                                                    "EEEE, dd MMMM yyyy",
                                                    "id_ID",
                                                  ).parseLoose(rawDate);
                                                }

                                                final tanggalController =
                                                    TextEditingController(
                                                      text: DateFormat(
                                                        "yyyy-MM-dd",
                                                      ).format(parsedDate),
                                                    );

                                                final satuanController =
                                                    TextEditingController(
                                                      text:
                                                          currentItem["satuan"] ??
                                                          "",
                                                    );
                                                final spesifikasiController =
                                                    TextEditingController(
                                                      text:
                                                          currentItem["spesifikasi"] ??
                                                          "",
                                                    );
                                                final hargaController =
                                                    TextEditingController(
                                                      text:
                                                          (currentItem["harga"] ??
                                                                  "")
                                                              .toString(),
                                                    );
                                                final linkController =
                                                    TextEditingController(
                                                      text:
                                                          currentItem["link_pembelian"] ??
                                                          "",
                                                    );

                                                File?
                                                selectedImage; // foto baru
                                                final currentPhotoUrl =
                                                    currentItem["foto"]; // string url foto dari database

                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context, setStateDialog) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          title: const Text(
                                                            "Edit Data Pemesanan",
                                                          ),
                                                          content: SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                // preview foto
                                                                selectedImage !=
                                                                        null
                                                                    ? Image.file(
                                                                        selectedImage!,
                                                                        height:
                                                                            120,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : (currentPhotoUrl !=
                                                                              null &&
                                                                          currentPhotoUrl !=
                                                                              "")
                                                                    ? Image.network(
                                                                        "${Config.baseUrl}/uploads/pemesanan/$currentPhotoUrl",
                                                                        height:
                                                                            120,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : Container(
                                                                        height:
                                                                            120,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child: const Text(
                                                                          "Tidak ada foto",
                                                                        ),
                                                                      ),

                                                                const SizedBox(
                                                                  height: 12,
                                                                ),

                                                                // button pilih foto
                                                                ElevatedButton.icon(
                                                                  onPressed: () async {
                                                                    showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                            18,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      builder: (context) {
                                                                        return Padding(
                                                                          padding: const EdgeInsets.all(
                                                                            16,
                                                                          ),
                                                                          child: Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              const Text(
                                                                                "Pilih Sumber Foto",
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 16,
                                                                              ),

                                                                              // === PILIH DARI CAMERA ===
                                                                              ListTile(
                                                                                leading: const Icon(
                                                                                  Icons.camera_alt,
                                                                                ),
                                                                                title: const Text(
                                                                                  "Kamera",
                                                                                ),
                                                                                onTap: () async {
                                                                                  final picker = ImagePicker();
                                                                                  final pickedFile = await picker.pickImage(
                                                                                    source: ImageSource.camera,
                                                                                    imageQuality: 70,
                                                                                  );

                                                                                  if (pickedFile !=
                                                                                      null) {
                                                                                    setStateDialog(
                                                                                      () {
                                                                                        selectedImage = File(
                                                                                          pickedFile.path,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  }

                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  ); // tutup bottom sheet
                                                                                },
                                                                              ),

                                                                              // === PILIH DARI GALERI ===
                                                                              ListTile(
                                                                                leading: const Icon(
                                                                                  Icons.photo_library,
                                                                                ),
                                                                                title: const Text(
                                                                                  "Galeri",
                                                                                ),
                                                                                onTap: () async {
                                                                                  final picker = ImagePicker();
                                                                                  final pickedFile = await picker.pickImage(
                                                                                    source: ImageSource.gallery,
                                                                                    imageQuality: 70,
                                                                                  );

                                                                                  if (pickedFile !=
                                                                                      null) {
                                                                                    setStateDialog(
                                                                                      () {
                                                                                        selectedImage = File(
                                                                                          pickedFile.path,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  }

                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons.photo,
                                                                  ),
                                                                  label: const Text(
                                                                    "Pilih Foto Baru",
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                  height: 16,
                                                                ),

                                                                TextField(
                                                                  controller:
                                                                      namaPemesanController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Nama Pemesan",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      namaBarangController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Nama Barang",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      jumlahController,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Jumlah",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      tanggalController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Tanggal Pemesanan",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      satuanController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Satuan",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      spesifikasiController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Spesifikasi",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      hargaController,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Harga",
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      linkController,
                                                                  decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Link Pembelian",
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
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                "Batal",
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                final sukses = await _editPemesananAtkController.editPemesanan(
                                                                  id: id,
                                                                  namaPemesan:
                                                                      namaPemesanController
                                                                          .text,
                                                                  namaBarang:
                                                                      namaBarangController
                                                                          .text,
                                                                  jumlah:
                                                                      jumlahController
                                                                          .text,
                                                                  tanggalPemesanan:
                                                                      tanggalController
                                                                          .text,
                                                                  satuan:
                                                                      satuanController
                                                                          .text,
                                                                  spesifikasi:
                                                                      spesifikasiController
                                                                          .text,
                                                                  harga:
                                                                      hargaController
                                                                          .text,
                                                                  linkPembelian:
                                                                      linkController
                                                                          .text,
                                                                  fotoBaru:
                                                                      selectedImage, // null = tidak ganti foto
                                                                );

                                                                if (!context
                                                                    .mounted)
                                                                  return;

                                                                if (sukses) {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        "Data berhasil diperbarui 🚀",
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        "Gagal update 😥",
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: const Text(
                                                                "Simpan",
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ), IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final id = listTanggal[i]["id"];

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
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text("Batal"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text("Hapus"),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              final success =
                                                  await _hapusController
                                                      .hapusBarang(id);

                                              if (success) {
                                                setState(() {}); // reload tabel
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Berhasil menghapus",
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Gagal menghapus",
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                      ),
                                    )
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

                        await exportBarangToExcel(
                          data,
                        ); // <-- Excel (no lantai)
                      },

                      icon: const Icon(Icons.table_view),
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
