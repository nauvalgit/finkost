import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finkost/firebase_options.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

// Import Schema
import 'package:finkost/models/category_local_schema.dart';
import 'package:finkost/models/transaction_local_schema.dart';

// Repositories
import 'package:finkost/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finkost/features/authentication/data/repositories/auth_repository.dart';

// Usecases
import 'package:finkost/features/transactions/domain/usecases/add_transaction.dart' as usecase_add_transaction;
import 'package:finkost/features/transactions/domain/usecases/load_categories.dart' as usecase_load_categories;
import 'package:finkost/features/transactions/domain/usecases/load_transactions.dart' as usecase_load_transactions;
import 'package:finkost/features/transactions/domain/usecases/update_transaction.dart' as usecase_update_transaction;
import 'package:finkost/features/transactions/domain/usecases/delete_transaction.dart' as usecase_delete_transaction;
import 'package:finkost/features/transactions/domain/usecases/seed_categories.dart' as usecase_seed_categories;
import 'package:finkost/features/transactions/domain/usecases/get_monthly_statistics.dart' as usecase_get_monthly_statistics;

// Bloc
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';

// Utils / Services
import 'package:finkost/core/utils/notification_service.dart'; // <--- Import Baru

import 'package:finkost/app.dart';

// Deklarasi global untuk SharedPreferences
late SharedPreferences sharedPrefs;

void main() async {
  // 1. Inisialisasi Widgets Binding & Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Inisialisasi Format Tanggal (Indonesia)
  await initializeDateFormatting('id_ID', null);

  // 3. Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Failed to initialize Firebase: $e");
  }

  // 4. Inisialisasi Hive (Database Lokal)
  await Hive.initFlutter();
  
  // Daftarkan Adapter
  Hive.registerAdapter(CategoryLocalSchemaAdapter());
  Hive.registerAdapter(TransactionLocalSchemaAdapter());

  // Buka Box Hive secara bersamaan untuk efisiensi
  final categoryBox = await Hive.openBox<CategoryLocalSchema>('categories');
  final transactionBox = await Hive.openBox<TransactionLocalSchema>('transactions');

  // 5. Inisialisasi SharedPreferences
  sharedPrefs = await SharedPreferences.getInstance();
  final bool seenWelcomeScreen = sharedPrefs.getBool('seenWelcomeScreen') ?? false;

  // 6. Inisialisasi Notification Service (Fitur Baru)
  await NotificationService.init(); // <--- Inisialisasi Notifikasi

  // 7. Hapus Native Splash setelah semua setup selesai
  FlutterNativeSplash.remove();

  // 8. Jalankan Aplikasi dengan MultiRepositoryProvider dan MultiBlocProvider
  runApp(
    MultiRepositoryProvider(
      providers: [
        // Repository Transaksi (Dependency Injection)
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            categoryBox: categoryBox,
            transactionBox: transactionBox,
            firestore: FirebaseFirestore.instance,
            firebaseAuth: FirebaseAuth.instance,
            prefs: sharedPrefs,
          ),
        ),
        
        // Repository Auth (Dependency Injection)
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth Bloc: Mengecek status session saat aplikasi dimulai
          // AppStarted event memicu pemeriksaan sesi user yang tersimpan.
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AppStarted()),
          ),
          
          // Transaction Bloc: Mengelola logika transaksi, kategori, dan budget
          // Dependency Injection menyuntikkan semua usecase yang dibutuhkan.
          BlocProvider<TransactionBloc>(
            create: (context) {
              final transactionRepo = context.read<TransactionRepository>();
              
              return TransactionBloc(
                addTransaction: usecase_add_transaction.AddTransaction(transactionRepo),
                loadCategories: usecase_load_categories.LoadCategories(transactionRepo),
                loadTransactions: usecase_load_transactions.LoadTransactions(transactionRepo),
                updateTransaction: usecase_update_transaction.UpdateTransaction(transactionRepo),
                deleteTransaction: usecase_delete_transaction.DeleteTransaction(transactionRepo),
                seedCategories: usecase_seed_categories.SeedCategories(transactionRepo),
                getMonthlyStatistics: usecase_get_monthly_statistics.GetMonthlyStatistics(transactionRepo),
                transactionRepository: transactionRepo,
              )..add(const LoadMonthlyBudget()); // <--- Memicu muat budget saat aplikasi start
            },
          ),
        ],
        child: MyApp(seenWelcomeScreen: seenWelcomeScreen),
      ),
    ),
  );
}