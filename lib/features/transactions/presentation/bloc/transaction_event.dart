part of 'transaction_bloc.dart';

@immutable
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Menambah transaksi baru (Pemasukan/Pengeluaran)
class AddTransaction extends TransactionEvent {
  final Transaction transaction;
  const AddTransaction(this.transaction);
  
  @override
  List<Object?> get props => [transaction];
}

/// Mengambil seluruh data transaksi dari database
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

/// Mengambil data transaksi untuk bulan dan tahun tertentu (digunakan di Dashboard)
class LoadTransactionsForMonth extends TransactionEvent {
  final int year;
  final int month;
  const LoadTransactionsForMonth(this.year, this.month);
  
  @override
  List<Object?> get props => [year, month];
}

/// Memuat daftar kategori (bisa difilter berdasarkan tipe 'expense' atau 'income')
class LoadCategories extends TransactionEvent {
  final String? type;
  const LoadCategories({this.type});
  
  @override
  List<Object?> get props => [type];
}

/// Menambah kategori transaksi baru kustom
class AddCategory extends TransactionEvent {
  final CategoryLocalSchema category;
  const AddCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

/// Memperbarui kategori yang sudah ada
class UpdateCategory extends TransactionEvent {
  final CategoryLocalSchema category;
  const UpdateCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

/// Menghapus kategori berdasarkan ID
class DeleteCategory extends TransactionEvent {
  final String categoryId;
  const DeleteCategory(this.categoryId);
  
  @override
  List<Object?> get props => [categoryId];
}

/// Inisialisasi kategori default saat aplikasi pertama kali dijalankan
class SeedCategoriesEvent extends TransactionEvent {
  const SeedCategoriesEvent();
}

/// Memperbarui data transaksi yang sudah ada
class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;
  const UpdateTransaction(this.transaction);
  
  @override
  List<Object?> get props => [transaction];
}

/// Menghapus transaksi berdasarkan ID-nya
class DeleteTransaction extends TransactionEvent {
  final String transactionId;
  const DeleteTransaction(this.transactionId);
  
  @override
  List<Object?> get props => [transactionId];
}

/// Memicu sinkronisasi ulang data dari Cloud Firestore
class RefreshTransactionData extends TransactionEvent {
  const RefreshTransactionData();
}

/// Mengambil ringkasan statistik (Total Pemasukan, Pengeluaran, Tabungan)
class LoadMonthlyStatistics extends TransactionEvent {
  final int year;
  final int month;
  const LoadMonthlyStatistics(this.year, this.month);
  
  @override
  List<Object?> get props => [year, month];
}

/// EVENT BARU: Memicu Bloc untuk mengambil data Anggaran (Budget) dari SharedPreferences
class LoadMonthlyBudget extends TransactionEvent {
  const LoadMonthlyBudget();
}