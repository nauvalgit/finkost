part of 'transaction_bloc.dart';

@immutable
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// State awal saat BLoC pertama kali dibuat.
class TransactionInitial extends TransactionState {}

/// State saat proses berat sedang berlangsung (seperti menambah data atau sinkronisasi awal).
class TransactionLoading extends TransactionState {}

/// State khusus untuk memicu Dialog Login di UI jika user tamu mencoba fitur berbayar/cloud.
class TransactionAuthRequired extends TransactionState {}

/// State utama yang membawa seluruh data transaksi dan kategori.
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<CategoryLocalSchema> expenseCategories;
  final List<CategoryLocalSchema> incomeCategories;
  final bool isLoading; // Bernilai true saat sedang sync dengan Firestore.
  
  /// Batas anggaran bulanan yang disetel pengguna (untuk fitur Overbudget Alert)
  final double monthlyBudget; 

  /// Data statistik tunggal untuk satu bulan yang dipilih.
  /// Berisi akumulasi: income, expense, dan savings.
  final Map<String, dynamic>? monthlyStatistics;

  const TransactionLoaded({
    this.transactions = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.isLoading = false,
    this.monthlyStatistics,
    this.monthlyBudget = 0.0, // Default 0 jika belum disetel
  });

  /// Fungsi copyWith digunakan untuk memperbarui satu atau beberapa properti state
  /// tanpa menghilangkan data properti lainnya yang tidak diubah.
  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<CategoryLocalSchema>? expenseCategories,
    List<CategoryLocalSchema>? incomeCategories,
    bool? isLoading,
    Map<String, dynamic>? monthlyStatistics,
    double? monthlyBudget,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      isLoading: isLoading ?? this.isLoading,
      monthlyStatistics: monthlyStatistics ?? this.monthlyStatistics,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        expenseCategories,
        incomeCategories,
        isLoading,
        monthlyStatistics,
        monthlyBudget,
      ];
}

/// State saat aksi CRUD (Tambah/Ubah/Hapus) berhasil dilakukan secara sistem.
class TransactionActionSuccess extends TransactionState {
  final String message;
  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State saat terjadi kegagalan sistem, error database lokal, atau masalah koneksi internet.
class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}