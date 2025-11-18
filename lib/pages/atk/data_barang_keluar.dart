import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/atk/data_barang_keluar_controller.dart';


class DataBarangKeluarATKPage extends StatelessWidget {
  const DataBarangKeluarATKPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarangKeluarController(),
      child: const _PageContent(),
    );
  }
}

class _PageContent extends StatefulWidget {
  const _PageContent();

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  Map<String, dynamic> stok = {};

  @override
  void initState() {
    super.initState();
    loadStok();
  }

  Future<void> loadStok() async {
    final controller = context.read<BarangKeluarController>();
    stok = await controller.loadStok();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BarangKeluarController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Barang Keluar ATK")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Stok ATK:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            // tampilkan stok
            ...stok.entries.map((e) => Text("${e.key}: ${e.value['total']}")),

            const SizedBox(height: 30),

            TextField(controller: ctrl.namaC, decoration: InputDecoration(hintText: "Nama")),
            TextField(controller: ctrl.namaBarangC, decoration: InputDecoration(hintText: "Nama Barang")),
            TextField(controller: ctrl.jumlahC, decoration: InputDecoration(hintText: "Jumlah")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => ctrl.pickFoto(ImageSource.camera),
              child: const Text("Ambil Foto"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final ok = await ctrl.submit(context);

                if (ok) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("✔ Barang Keluar Berhasil")));
                }
              },
              child: ctrl.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Kirim"),
            ),
          ],
        ),
      ),
    );
  }
}
