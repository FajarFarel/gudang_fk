import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';

Future<void> printBarcodeTable(List<Map<String, dynamic>> data, int lantai) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text(
              "📦 Data Barang - Lantai $lantai",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // 🔹 Tabel barang
          pw.Table(
            border: pw.TableBorder.all(width: 1),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FixedColumnWidth(100),
            },
            children: [
              // Header tabel
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("No", textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Nama Barang", textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Jumlah", textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Tanggal", textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Barcode", textAlign: pw.TextAlign.center),
                  ),
                ],
              ),

              // Isi tabel
              for (final item in data)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item["no"].toString(),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item["nama"], textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item["jumlah"].toString(),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item["tanggal"],
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: item["nama"].codeUnits.join(), // Data unik
                        width: 100,
                        height: 40,
                        drawText: false,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ];
      },
    ),
  );

  // 🔹 Preview dan print langsung
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
