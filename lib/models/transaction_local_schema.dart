import 'package:isar/isar.dart';

part 'transaction_local_schema.g.dart'; // Ini akan di-generate oleh `build_runner`

@collection
class TransactionLocalSchema {
  Id id = Isar.autoIncrement; // ID unik untuk setiap transaksi lokal

  late double amount;
  String? description; // Deskripsi opsional
  late DateTime date; // Tanggal transaksi
  late String type; // 'income' atau 'expense'
  late String categoryName; // Nama kategori (misal: "Makanan")
  late String categoryIcon; // Nama ikon kategori
}