import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/utils/guest_id_manager.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finkost/models/category_local_schema.dart';
import 'package:finkost/models/transaction_local_schema.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Box<CategoryLocalSchema> categoryBox;
  final Box<TransactionLocalSchema> transactionBox;
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences prefs;

  TransactionRepositoryImpl({
    required this.categoryBox,
    required this.transactionBox,
    required this.firestore,
    required this.firebaseAuth,
    required this.prefs,
  });

  Future<String> get _activeUserId async {
    final firebaseUid = firebaseAuth.currentUser?.uid;
    if (firebaseUid != null) {
      return firebaseUid;
    } else {
      return await GuestIdManager.getGuestId();
    }
  }

  // --- HELPER: KATEGORI DEFAULT LENGKAP ---

  List<CategoryLocalSchema> _getDefaultExpenseCategories(String userId) {
    return [
      CategoryLocalSchema.create(name: 'Makanan', type: 'expense', icon: 'utensils', userId: userId),
      CategoryLocalSchema.create(name: 'Transportasi', type: 'expense', icon: 'car', userId: userId),
      CategoryLocalSchema.create(name: 'Hiburan', type: 'expense', icon: 'film', userId: userId),
      CategoryLocalSchema.create(name: 'Belanja', type: 'expense', icon: 'bagShopping', userId: userId),
      CategoryLocalSchema.create(name: 'Kesehatan', type: 'expense', icon: 'hospital', userId: userId),
      CategoryLocalSchema.create(name: 'Tagihan', type: 'expense', icon: 'receipt', userId: userId),
      CategoryLocalSchema.create(name: 'Pendidikan', type: 'expense', icon: 'graduationCap', userId: userId),
      CategoryLocalSchema.create(name: 'Lainnya', type: 'expense', icon: 'box', userId: userId),
    ];
  }

  List<CategoryLocalSchema> _getDefaultIncomeCategories(String userId) {
    return [
      CategoryLocalSchema.create(name: 'Gaji', type: 'income', icon: 'wallet', userId: userId),
      CategoryLocalSchema.create(name: 'Bonus', type: 'income', icon: 'gift', userId: userId),
      CategoryLocalSchema.create(name: 'Investasi', type: 'income', icon: 'chartLine', userId: userId),
      CategoryLocalSchema.create(name: 'Lainnya', type: 'income', icon: 'coins', userId: userId),
    ];
  }

  // --- HELPER: PARSING TANGGAL AMAN ---

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  Future<Either<Failure, Unit>> seedCategories() async {
    try {
      final userId = await _activeUserId;
      final isUserLoggedIn = firebaseAuth.currentUser != null;

      final hasData = categoryBox.values.any((c) => c.userId == userId);

      if (!hasData) {
        final allDefaults = [
          ..._getDefaultExpenseCategories(userId),
          ..._getDefaultIncomeCategories(userId)
        ];

        for (var cat in allDefaults) {
          await categoryBox.add(cat);
        }

        if (isUserLoggedIn) {
          try {
            final batch = firestore.batch();
            for (var cat in allDefaults) {
              final docRef = firestore.collection('users').doc(userId).collection('categories').doc();
              batch.set(docRef, cat.toJson());
            }
            await batch.commit();
          } catch (e) {
            debugPrint("Background seed error: $e");
          }
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Seed Failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryLocalSchema>>> getCategories({String? type}) async {
    try {
      final userId = await _activeUserId;

      if (firebaseAuth.currentUser != null) {
        try {
          final snapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('categories')
              .get();

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final name = data['name'];
            final cType = data['type'];

            final exists = categoryBox.values.any((c) => 
              c.userId == userId && c.name == name && c.type == cType);

            if (!exists) {
              final newCat = CategoryLocalSchema()
                ..name = name
                ..type = cType
                ..icon = data['icon']
                ..userId = userId
                ..firestoreId = doc.id
                ..createdAt = _parseDateTime(data['createdAt'])
                ..updatedAt = _parseDateTime(data['updatedAt']);
              await categoryBox.add(newCat);
            }
          }
        } catch (e) {
          debugPrint("Category sync error: $e");
        }
      }

      var results = categoryBox.values.where((c) => c.userId == userId).toList();
      if (type != null) {
        results = results.where((c) => c.type == type).toList();
      }
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCategory(CategoryLocalSchema category) async {
    try {
      final userId = await _activeUserId;
      if (firebaseAuth.currentUser == null) {
        return Left(DatabaseFailure("Auth Required"));
      }
      category.userId = userId;
      await categoryBox.add(category);

      try {
        final docRef = await firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .add(category.toJson());
        
        category.firestoreId = docRef.id;
        await category.save();
      } catch (e) {
        debugPrint("Category cloud deferred: $e");
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCategory(CategoryLocalSchema category) async {
    try {
      final userId = await _activeUserId;
      
      category.updatedAt = DateTime.now();
      await category.save();

      if (firebaseAuth.currentUser != null && category.firestoreId != null) {
        try {
          await firestore
              .collection('users')
              .doc(userId)
              .collection('categories')
              .doc(category.firestoreId)
              .update(category.toJson());
        } catch (e) {
          debugPrint("Update Category cloud deferred: $e");
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String categoryId) async {
    try {
      final userId = await _activeUserId;
      final key = int.parse(categoryId);
      final cat = categoryBox.get(key);

      if (cat != null) {
        final fId = cat.firestoreId;
        
        await cat.delete();

        if (firebaseAuth.currentUser != null && fId != null) {
          try {
            await firestore
                .collection('users')
                .doc(userId)
                .collection('categories')
                .doc(fId)
                .delete();
          } catch (e) {
            debugPrint("Delete Category cloud deferred: $e");
          }
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactions() async {
    try {
      final userId = await _activeUserId;

      if (firebaseAuth.currentUser != null) {
        try {
          final snapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .get();

          final cloudIds = snapshot.docs.map((doc) => doc.id).toSet();

          final localKeysToDelete = transactionBox.keys.where((key) {
            final tx = transactionBox.get(key);
            return tx?.userId == userId && 
                   tx?.firestoreId != null && 
                   !cloudIds.contains(tx!.firestoreId);
          }).toList();
          
          await transactionBox.deleteAll(localKeysToDelete);

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final exists = transactionBox.values.any((t) => t.firestoreId == doc.id);
            if (!exists) {
              final schema = TransactionLocalSchema()
                ..firestoreId = doc.id
                ..amount = (data['amount'] as num).toDouble()
                ..description = data['description'] ?? ""
                ..date = _parseDateTime(data['date'])
                ..transactionType = data['transactionType']
                ..userId = userId
                ..categoryName = data['categoryName']
                ..categoryIcon = data['categoryIcon']
                ..createdAt = _parseDateTime(data['createdAt'])
                ..updatedAt = _parseDateTime(data['updatedAt']);
              await transactionBox.add(schema);
            }
          }
        } catch (e) {
          debugPrint("Transaction sync error: $e");
        }
      }

      final transactions = transactionBox.values
          .where((t) => t.userId == userId)
          .map((e) => e.toDomainEntity())
          .toList();

      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(domain.Transaction transaction) async {
    try {
      final userId = await _activeUserId;

      final schema = TransactionLocalSchema.fromDomainEntity(transaction)
        ..userId = userId;

      await transactionBox.add(schema);

      if (firebaseAuth.currentUser != null) {
        try {
          final docRef = await firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .add(schema.toJson());
          
          schema.firestoreId = docRef.id;
          await schema.save();
        } catch (e) {
          debugPrint("Firestore deferred: $e");
        }
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(domain.Transaction transaction) async {
    try {
      final userId = await _activeUserId;
      if (transaction.id == null) return Left(DatabaseFailure('ID Null'));

      final key = int.parse(transaction.id!);
      final existing = transactionBox.get(key);

      if (existing != null) {
        existing.amount = transaction.amount;
        existing.description = transaction.description;
        existing.date = transaction.transactionDate;
        existing.transactionType = transaction.transactionType;
        existing.categoryName = transaction.categoryName;
        existing.categoryIcon = transaction.categoryIcon;
        existing.updatedAt = DateTime.now();
        
        await existing.save();

        if (firebaseAuth.currentUser != null && transaction.firestoreId != null) {
          try {
            await firestore
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .doc(transaction.firestoreId)
                .update(existing.toJson());
          } catch (e) {
            debugPrint("Update cloud deferred: $e");
          }
        }
        return const Right(unit);
      }
      return Left(DatabaseFailure('Not Found'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId) async {
    try {
      final key = int.parse(transactionId);
      final tx = transactionBox.get(key);

      if (tx != null) {
        final userId = tx.userId;
        final fId = tx.firestoreId;

        await tx.delete();

        if (firebaseAuth.currentUser != null && fId != null) {
          try {
            await firestore
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .doc(fId)
                .delete();
          } catch (e) {
            debugPrint("Delete cloud deferred: $e");
          }
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyStatistics(int year, int month) async {
    try {
      final userId = await _activeUserId;
      
      // Filter Hive secara presisi berdasarkan tahun dan bulan
      // Ini memastikan data dari bulan lain tidak ikut terjumlahkan
      final txs = transactionBox.values.where((t) => 
        t.userId == userId && 
        t.date.year == year && 
        t.date.month == month
      );

      double income = 0.0;
      double expense = 0.0;

      for (var tx in txs) {
        if (tx.transactionType == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }

      return Right({
        'year': year,
        'month': month,
        'income': income,
        'expense': expense,
        'savings': income - expense,
      });
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}