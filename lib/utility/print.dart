import 'dart:typed_data';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';

// ====================================================
// ============ EXPORT DENGAN LANTAI ==================
// ====================================================
Future<void> exportBarcodeTableToExcel(
  List<Map<String, dynamic>> data,
  String nama_ruangan,
) async {
  final workbook = xlsio.Workbook();
  final sheet = workbook.worksheets[0];

  sheet.name = "Ruangan_$nama_ruangan";

  final headers = [
    "No",
    "Nama Barang",
    "Jumlah",
    "Tanggal",
    "Nama Pemesan",
    "Nama Ruangan",
    "Link Pembelian",
  ];

  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.getRangeByIndex(1, i + 1);
    cell.setText(headers[i]);
    cell.cellStyle.bold = true;
  }

  int row = 2;

  for (final item in data) {
    sheet.getRangeByIndex(row, 1).setText(item["id"].toString());
    sheet.getRangeByIndex(row, 2).setText(item["nama_barang"]);
    sheet.getRangeByIndex(row, 3).setText(item["jumlah"].toString());
    sheet.getRangeByIndex(row, 4).setText(item["tanggal_pemesanan"]);
    sheet.getRangeByIndex(row, 5).setText(item["nama_pemesan"]);
    sheet.getRangeByIndex(row, 6).setText(item["nama_ruangan"]);
    sheet.getRangeByIndex(row, 7).setText(item["link_pembelian"]);

    row++;
  }

  sheet.getRangeByName('A1:G1').autoFitColumns();

  final excelBytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb) {
    final blob = html.Blob([excelBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "Data_Barang_$nama_ruangan.xlsx")
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  } else {
    await FileSaver.instance.saveFile(
      name: "Data_Barang_$nama_ruangan.xlsx",
      bytes: Uint8List.fromList(excelBytes),
      mimeType: MimeType.microsoftExcel,
    );
  }
}

// ====================================================
// ============== EXPORT TANPA LANTAI =================
// ====================================================
Future<void> exportBarangToExcel(List<Map<String, dynamic>> data) async {
  final workbook = xlsio.Workbook();
  final sheet = workbook.worksheets[0];

  sheet.name = "Data_Barang";

  final headers = [
    "No",
    "Nama Barang",
    "Jumlah",
    "Tanggal",
    "Nama Pemesan",
    "Nama Ruangan",
    "Link Pembelian",
  ];
  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.getRangeByIndex(1, i + 1);
    cell.setText(headers[i]);
    cell.cellStyle.bold = true;
  }

  int row = 2;

  for (final item in data) {
    sheet.getRangeByIndex(row, 1).setText(item["id"].toString());
    sheet.getRangeByIndex(row, 2).setText(item["nama_barang"]);
    sheet.getRangeByIndex(row, 3).setText(item["jumlah"].toString());
    sheet.getRangeByIndex(row, 4).setText(item["tanggal_pemesanan"]);
    sheet.getRangeByIndex(row, 5).setText(item["nama_pemesan"]);
    sheet.getRangeByIndex(row, 6).setText(item["nama_ruangan"]);
    sheet.getRangeByIndex(row, 7).setText(item["link_pembelian"]);

    row++;
  }

  sheet.getRangeByName('A1:D1').autoFitColumns();

  final excelBytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb) {
    final blob = html.Blob([excelBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "Data_Barang.xlsx")
      ..style.display = 'none';

    html.document.body?.append(anchor);

    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  } else {
    await FileSaver.instance.saveFile(
      name: "Data_Barang.xlsx",
      bytes: Uint8List.fromList(excelBytes),
      mimeType: MimeType.microsoftExcel,
    );
  }
}
