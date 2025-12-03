  // lib/controller/barang_controller.dart
  import 'package:gudang_fk/service/atk/tabel_atk_service.dart';

  class IsiTabelAtkController {
    Future<List<Map<String, dynamic>>> getAtk({String? kategori}) async {
      try {
        final data = await IsiTabelAtkService.fetchAtk(kategori: kategori);
        return data;
      } catch (e) {
        rethrow;
      }
    }
  }
