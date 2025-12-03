import '../../service/gudang/hapus_data_gudang_service.dart';
import 'dart:io';

class HapusDataGudangController {
  Future<bool> hapusBarang(int id) async {
    try {
      final result = await HapusDataGudangService.hapusDataGudang(id);

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

class HapusPemesananGudangController {
  Future<bool> hapusPemesanan(int id) async {
    try {
      final result = await HapusPemesananGudangService.hapusPemesananGudang(id);

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

class EditDataGudangController {
  Future<bool> editGudang({
    required int id,
    required String b,
    required String rr,
    required String rb,
  }) async {
    try {
      final result = await EditGudangService.editGudang(
        id: id,
        b: b,
        rr: rr,
        rb: rb,
      );

      if (result["message"] != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error edit gudang: $e");
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
      final result = await EditPemesananService.editPemesanan(
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

