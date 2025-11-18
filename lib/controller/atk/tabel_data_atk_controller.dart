  // lib/controller/barang_controller.dart
  import 'package:gudang_fk/service/atk/tabel_data_atk_service.dart';

  class IsiTabelAtkController {
    Future<List<Map<String, dynamic>>> getBarangAtk() async {
      try {
        final data = await IsiTabelAtkService.fetchBarangAtk();
        return data;
      } catch (e) {
        rethrow;
      }
    }
  }
