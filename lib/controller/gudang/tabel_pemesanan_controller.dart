import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../service/gudang/tabel_pemesanan_service.dart';

class TabelPemesananController {
  final _service = TabelPemesananService();

  Future<List<Map<String, dynamic>>> getPemesanan() async {
    try {
      final data = await _service.fetchPemesanan();
      return data;
    } catch (e) {
      throw Exception('Error di controller: $e');
    }
  }

  // 🔹 Parse tanggal biar aman
  DateTime? safeParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    try {
      final cleaned = input.trim().split(' ').first;
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleaned)) {
        return DateTime.parse(cleaned);
      }
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(cleaned)) {
        return DateTime.parse(cleaned);
      }
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').parseLoose(input, true);
    } catch (_) {
      return null;
    }
  }

  // 🔹 Ambil gambar dari URL
Future<pw.Widget> buildFotoWidget(String? url) async {
  if (url == null || url.isEmpty) {
    return pw.Text('-');
  }

  try {
    final image = await networkImage(url);
    return pw.Image(
      image,
      width: 60,
      height: 60,
      fit: pw.BoxFit.contain,
    );
  } catch (e) {
    print('Gagal load gambar: $e');
    return pw.Text('-');
  }
}


  // 🔹 Generate PDF per bulan & tanggal
  Future<void> generatePdfForMonth(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');

    final Map<String, List<Map<String, dynamic>>> groupedByMonth = {};

    for (var item in data) {
      final tgl = safeParseDate(item['tanggal_pemesanan']);
      if (tgl == null) continue;
      final bulan = monthFormat.format(tgl);
      groupedByMonth.putIfAbsent(bulan, () => []).add(item);
    }

    for (final bulan in groupedByMonth.keys) {
      final items = groupedByMonth[bulan]!;
      items.sort((a, b) {
        final t1 = safeParseDate(a['tanggal_pemesanan']) ?? DateTime(1900);
        final t2 = safeParseDate(b['tanggal_pemesanan']) ?? DateTime(1900);
        return t1.compareTo(t2);
      });

      final dateGroups = await _buildDateGroupsAsync(items, dateFormat);

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'Laporan Pemesanan - $bulan',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            ...dateGroups,
          ],
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // 🔸 Grup per tanggal, tampilkan semua kolom
  Future<List<pw.Widget>> _buildDateGroupsAsync(
    List<Map<String, dynamic>> items,
    DateFormat dateFormat,
  ) async {
    final Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var item in items) {
      final rawTanggal = item['tanggal_pemesanan'];
      final tgl = safeParseDate(
        rawTanggal != null ? rawTanggal.toString() : '',
      );

      if (tgl == null) continue;
      final tanggalStr = dateFormat.format(tgl);
      groupedByDate.putIfAbsent(tanggalStr, () => []).add(item);
    }

    final widgets = <pw.Widget>[];

    for (final entry in groupedByDate.entries) {
      final tanggal = entry.key;
      final list = entry.value;

      final rows = <pw.TableRow>[
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            for (var header in [
              'No',
              'Nama Pemesan',
              'Jumlah',
              'Satuan',
              'Spesifikasi',
              'Nama Barang',
              'Nama Ruangan',
              'Harga',
              'Link Pembelian',
              'Foto Barang',
            ])
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
          ],
        ),
      ];

     for (var i = 0; i < list.length; i++) {
  final barang = list[i];

  final fotoWidget = await buildFotoWidget(barang['foto_barang']?.toString());

  rows.add(
    pw.TableRow(
      children: [
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('${i + 1}')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['nama_pemesan']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['jumlah']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['satuan']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['spesifikasi']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['nama_barang']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['nama_ruangan']?.toString() ?? '-')),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(barang['harga']?.toString() ?? '-')),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.UrlLink(
            destination: barang['link_pembelian']?.toString() ?? '#',
            child: pw.Text(
              barang['link_pembelian']?.toString() ?? '-',
              style: const pw.TextStyle(
                color: PdfColors.blue,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: fotoWidget,
        ),
      ],
    ),
  );
}


      widgets.addAll([
        pw.Text(
          'Senin, $tanggal',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          children: rows,
        ),
        pw.SizedBox(height: 15),
      ]);
    }

    return widgets;
  }
}
