import '../../service/atk/hapus_data_atk_service.dart';
import 'dart:io';

class HapusAtkController {
  Future<bool> hapusBarang(int id) async {
    try {
      final result = await HapusPemesananAtkService.hapusBarang(id);

      // Backend selalu ngasih "message" kalo sukses
      if (result["message"] != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error hapus: $e");
      return false;
    }
  }
}

class HapusDataAtkController {
  Future<bool> hapusBarang(int id) async {
    try {
      final result = await HapusDataAtkService.hapusBarang(id);

      // Backend selalu ngasih "message" kalo sukses
      if (result["message"] != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error hapus: $e");
      return false;
    }
  }
}

class EditDataAtkController {
  Future<bool> editAtk({
    required int id,
    required String noBMN,
    required String namabarang,
    required String tanggalbarangdatang,
    required String jumlah,
    required String satuan,
    required String spesifikasi,
    required String namaruangan,
    required String kategori,
    File? fotoatkBaru,
    required String b,
    required String rr,
    required String rb,
  }) async {
    try {
      final result = await EditAtkService.editAtk(
        id: id,
        noBMN: noBMN,
        namabarang: namabarang,
        tanggalbarangdatang: tanggalbarangdatang,
        jumlah: jumlah,
        satuan: satuan,
        spesifikasi: spesifikasi,
        namaruangan: namaruangan,
        kategori: kategori,
        fotoatkBaru: fotoatkBaru,
        b: b,
        rr: rr,
        rb: rb,
      );

      if (result["message"] != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error edit atk: $e");
      return false;
    }
  }
}

class EditPemesananController {
  Future<bool> editPemesanan({
    required int id,
    required String namaPemesan,
    required String namaBarang,
    required String jumlah,
    required String tanggalPemesanan,
    required String satuan,
    required String spesifikasi,
    required String harga,
    required String linkPembelian,
    File? fotoBaru,
  }) async {
    try {
      final result = await EditPemesananAtkService.editPemesanan(
        id: id,
        namaPemesan: namaPemesan,
        namaBarang: namaBarang,
        jumlah: jumlah,
        tanggalPemesanan: tanggalPemesanan,
        satuan: satuan,
        spesifikasi: spesifikasi,
        harga: harga,
        linkPembelian: linkPembelian,
        fotoBaru: fotoBaru,
      );

      if (result["message"] != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error edit pemesanan: $e");
      return false;
    }
  }
}



