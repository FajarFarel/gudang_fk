import 'package:gudang_fk/service/gudang/tabel_perlantai_service.dart';

class LantaiController {
  Future<List<int>> getLantaiList() async {
    try {
      return await LantaiService.fetchLantai();
    } catch (e) {
      throw Exception("Error mengambil data lantai: $e");
    }
  }
}
