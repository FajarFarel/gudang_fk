  // lib/controller/barang_controller.dart
  import 'package:gudang_fk/service/isi_tabel_service.dart';

  class IsiTabelController {
    Future<List<Map<String, dynamic>>> getBarangByLantai(int lantai) async {
      try {
        final data = await IsiTabelService.fetchBarangByLantai(lantai);
        return data;
      } catch (e) {
        rethrow;
      }
    }
  }
