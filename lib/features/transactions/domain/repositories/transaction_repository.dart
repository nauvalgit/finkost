import 'package:dartz/dartz.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';
import 'package:finkost/models/category_local_schema.dart';

abstract class TransactionRepository {
  // Transaksi
  Future<Either<Failure, Unit>> addTransaction(Transaction transaction);
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction);
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId);
  Future<Either<Failure, List<Transaction>>> getTransactions();
  
  // Kategori
  Future<Either<Failure, List<CategoryLocalSchema>>> getCategories({String? type});
  Future<Either<Failure, Unit>> addCategory(CategoryLocalSchema category);
  
  // --- PERBAIKAN: TAMBAHKAN KONTRAK UPDATE & DELETE KATEGORI ---
  Future<Either<Failure, Unit>> updateCategory(CategoryLocalSchema category);
  Future<Either<Failure, Unit>> deleteCategory(String categoryId); 
  
  // Sistem
  Future<Either<Failure, Unit>> seedCategories();
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyStatistics(int year, int month);
}