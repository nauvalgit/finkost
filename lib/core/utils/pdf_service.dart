import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';

class PdfService {
  static Future<void> generateTransactionReport({
    required List<Transaction> transactions,
    required Map<String, dynamic> summary,
    required String userName,
    required String monthYear,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- HEADER LAPORAN ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LAPORAN KEUANGAN FINKOST', 
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
                  pw.Text('Periode: $monthYear'),
                  pw.Text('Nama: $userName'),
                ],
              ),
              pw.Text('FINKOST', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey300)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 20),

          // --- KOTAK RINGKASAN (SUMMARY) ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryBox('Pemasukan', currencyFormat.format(summary['income'] ?? 0), PdfColors.green),
              _buildSummaryBox('Pengeluaran', currencyFormat.format(summary['expense'] ?? 0), PdfColors.red),
              _buildSummaryBox('Tabungan', currencyFormat.format(summary['savings'] ?? 0), PdfColors.blue),
            ],
          ),
          pw.SizedBox(height: 30),

          // --- TABEL DAFTAR TRANSAKSI ---
          pw.Text('Daftar Transaksi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            border: pw.TableBorder.all(color: PdfColors.grey200),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
            headers: ['Tanggal', 'Kategori', 'Deskripsi', 'Nominal'],
            data: transactions.map((tx) {
              return [
                DateFormat('dd/MM/yyyy').format(tx.transactionDate),
                tx.categoryName,
                tx.description ?? '-',
                currencyFormat.format(tx.amount),
              ];
            }).toList(),
          ),
          
          // --- FOOTER ---
          pw.SizedBox(height: 40),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Dicetak pada: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
          )
        ],
      ),
    );

    // --- LOGIKA SIMPAN DAN BUKA (PENGGANTI PRINTING) ---
    try {
      // 1. Dapatkan folder temporary HP
      final output = await getTemporaryDirectory();
      
      // 2. Buat nama file (hapus spasi agar aman)
      final String fileName = "Laporan_Finkost_${monthYear.replaceAll(' ', '_')}.pdf";
      final file = File("${output.path}/$fileName");

      // 3. Simpan file PDF
      await file.writeAsBytes(await pdf.save());

      // 4. Buka file secara otomatis dengan aplikasi pembuka PDF
      await OpenFilex.open(file.path);
    } catch (e) {
      throw Exception("Gagal membuat atau membuka PDF: $e");
    }
  }

  // Widget Pembantu untuk Kotak Ringkasan
  static pw.Widget _buildSummaryBox(String title, String value, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: color)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}