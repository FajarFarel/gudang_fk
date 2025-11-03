import '../service/tabel_pemesanan_service.dart';

class TabelPemesananController {
  final _service = TabelPemesananService();

  Future<List<Map<String, dynamic>>> getPemesanan() async {
    try {
      final data = await _service.fetchPemesanan();

      // bisa diolah di sini kalau perlu grouping per tanggal/kategori
      return data;
    } catch (e) {
      throw Exception('Error di controller: $e');
    }
  }
}
