import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finkost/models/category_local_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finkost/features/transactions/domain/usecases/add_transaction.dart' as usecase_add_transaction;
import 'package:finkost/features/transactions/domain/usecases/load_categories.dart' as usecase_load_categories;
import 'package:finkost/features/transactions/domain/usecases/load_transactions.dart' as usecase_load_transactions;
import 'package:finkost/features/transactions/domain/usecases/update_transaction.dart' as usecase_update_transaction;
import 'package:finkost/features/transactions/domain/usecases/delete_transaction.dart' as usecase_delete_transaction;
import 'package:finkost/features/transactions/domain/usecases/seed_categories.dart' as usecase_seed_categories;
import 'package:finkost/features/transactions/domain/usecases/get_monthly_statistics.dart' as usecase_get_monthly_statistics;

import 'package:finkost/features/transactions/domain/entities/transaction.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finkost/core/usecases/usecase.dart'; 
import 'package:finkost/core/utils/notification_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final usecase_add_transaction.AddTransaction addTransaction;
  final usecase_load_categories.LoadCategories loadCategories;
  final usecase_load_transactions.LoadTransactions loadTransactions;
  final usecase_update_transaction.UpdateTransaction updateTransaction;
  final usecase_delete_transaction.DeleteTransaction deleteTransaction;
  final usecase_seed_categories.SeedCategories seedCategories;
  final usecase_get_monthly_statistics.GetMonthlyStatistics getMonthlyStatistics;
  
  final TransactionRepository transactionRepository;

  List<Transaction> _allTransactions = [];
  List<CategoryLocalSchema> _expenseCats = [];
  List<CategoryLocalSchema> _incomeCats = [];
  Map<String, dynamic>? _monthlyStats;
  double _monthlyBudget = 0.0; 
  
  int _dashboardYear = DateTime.now().year;
  int _dashboardMonth = DateTime.now().month;

  TransactionBloc({
    required this.addTransaction,
    required this.loadCategories,
    required this.loadTransactions,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.seedCategories,
    required this.getMonthlyStatistics,
    required this.transactionRepository,
  }) : super(TransactionInitial()) {
    on<AddTransaction>(_onAddTransaction);
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsForMonth>(_onLoadTransactionsForMonth);
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SeedCategoriesEvent>(_onSeedCategories);
    on<LoadMonthlyStatistics>(_onLoadMonthlyStatistics);
    on<RefreshTransactionData>(_onRefreshTransactionData);
    on<LoadMonthlyBudget>(_onLoadMonthlyBudget);

    add(const LoadMonthlyBudget());
    add(const SeedCategoriesEvent());
  }

  Future<void> _onLoadMonthlyBudget(LoadMonthlyBudget event, Emitter<TransactionState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 0.0;
    _emitLoaded(emit);
  }

  List<Transaction> _filterTransactionsByMonth(int year, int month) {
    return _allTransactions.where((tx) {
      return tx.transactionDate.year == year && tx.transactionDate.month == month;
    }).toList();
  }

  void _emitLoaded(Emitter<TransactionState> emit, {bool isLoading = false}) {
    final filteredTransactions = _filterTransactionsByMonth(_dashboardYear, _dashboardMonth);
    emit(TransactionLoaded(
      transactions: filteredTransactions,
      expenseCategories: _expenseCats,
      incomeCategories: _incomeCats,
      isLoading: isLoading,
      monthlyStatistics: _monthlyStats,
      monthlyBudget: _monthlyBudget,
    ));
  }

  Future<void> _onRefreshTransactionData(RefreshTransactionData event, Emitter<TransactionState> emit) async {
    _allTransactions = [];
    _expenseCats = [];
    _incomeCats = [];
    _monthlyStats = null; // Reset statistik saat refresh total
    emit(TransactionLoading());
    
    await seedCategories(const NoParams());
    add(const LoadMonthlyBudget());
    
    final categoryResult = await loadCategories(usecase_load_categories.LoadCategoriesParams());
    categoryResult.fold((f) => null, (data) {
        _expenseCats = data.where((c) => c.type == 'expense').toList();
        _incomeCats = data.where((c) => c.type == 'income').toList();
    });

    final transactionResult = await loadTransactions(const NoParams());
    transactionResult.fold(
      (failure) => emit(TransactionError(failure.message)),
      (data) {
        _allTransactions = data;
        add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
      },
    );
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(TransactionAuthRequired());
      _emitLoaded(emit); 
      return;
    }
    emit(TransactionLoading());
    final result = await addTransaction(event.transaction);
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) async {
        emit(const TransactionActionSuccess("Transaksi berhasil ditambahkan"));
        
        // Pengecekan Budget untuk Notifikasi
        if (event.transaction.transactionType == 'expense' && _monthlyBudget > 0) {
          final statsResult = await getMonthlyStatistics(
            usecase_get_monthly_statistics.GetMonthlyStatisticsParams(
              year: DateTime.now().year, 
              month: DateTime.now().month
            )
          );

          statsResult.fold((_) => null, (data) {
            double totalExpense = (data['expense'] as num).toDouble();
            double percentage = (totalExpense / _monthlyBudget);

            if (percentage >= 1.0) {
              NotificationService.showNotification(
                id: 100,
                title: "Overbudget! 🚨",
                body: "Kamu sudah melewati batas anggaran bulananmu.",
              );
            } else if (percentage >= 0.8) {
              NotificationService.showNotification(
                id: 80,
                title: "Waspada Boros ⚠️",
                body: "Pengeluaranmu sudah mencapai ${(percentage * 100).toStringAsFixed(0)}% dari budget.",
              );
            }
          });
        }

        add(const LoadTransactions());
        add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
      },
    );
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    final result = await loadTransactions(const NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (data) {
        _allTransactions = data;
        _emitLoaded(emit);
      },
    );
  }

  // --- MODIFIKASI: PERBAIKAN PINDAH BULAN ---
  Future<void> _onLoadTransactionsForMonth(LoadTransactionsForMonth event, Emitter<TransactionState> emit) async {
    _dashboardYear = event.year;
    _dashboardMonth = event.month;
    
    // 1. Reset statistik lama agar angka bulan sebelumnya tidak "nyangkut"
    _monthlyStats = null; 
    
    // 2. Tampilkan status loading
    _emitLoaded(emit, isLoading: true);

    final result = await loadTransactions(const NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (data) {
        _allTransactions = data;
        
        // 3. KRUSIAL: Pemicu untuk memuat statistik bulan yang baru dipilih
        add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
      },
    );
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<TransactionState> emit) async {
    final result = await loadCategories(usecase_load_categories.LoadCategoriesParams(type: event.type));
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (data) {
        if (event.type == 'expense') _expenseCats = data;
        else if (event.type == 'income') _incomeCats = data;
        else {
           _expenseCats = data.where((c) => c.type == 'expense').toList();
           _incomeCats = data.where((c) => c.type == 'income').toList();
        }
        _emitLoaded(emit);
      },
    );
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await transactionRepository.addCategory(event.category);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionActionSuccess("Kategori berhasil ditambahkan"));
        add(LoadCategories(type: event.category.type));
      },
    );
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await transactionRepository.updateCategory(event.category);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionActionSuccess("Kategori berhasil diperbarui"));
        add(LoadCategories(type: event.category.type));
      },
    );
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await transactionRepository.deleteCategory(event.categoryId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionActionSuccess("Kategori berhasil dihapus"));
        add(const LoadCategories());
      },
    );
  }

  Future<void> _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionActionSuccess("Update berhasil"));
        add(const LoadTransactions());
        add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
      },
    );
  }

  Future<void> _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    final result = await deleteTransaction(event.transactionId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionActionSuccess("Hapus berhasil"));
        add(const LoadTransactions());
        add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
      },
    );
  }

  Future<void> _onSeedCategories(SeedCategoriesEvent event, Emitter<TransactionState> emit) async {
    await seedCategories(const NoParams());
    add(const LoadCategories());
    add(const LoadTransactions());
    add(LoadMonthlyStatistics(_dashboardYear, _dashboardMonth));
  }

  Future<void> _onLoadMonthlyStatistics(LoadMonthlyStatistics event, Emitter<TransactionState> emit) async {
    final result = await getMonthlyStatistics(usecase_get_monthly_statistics.GetMonthlyStatisticsParams(
      year: event.year, 
      month: event.month
    ));
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (data) {
        _monthlyStats = data;
        _emitLoaded(emit);
      },
    );
  }
}