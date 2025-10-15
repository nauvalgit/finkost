import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'package:finkost/main.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart' as app_transaction;
import 'package:finkost/models/transaction_local_schema.dart';

class TransactionRepository {
  final FirebaseAuth _auth;
  final firestore.FirebaseFirestore _firestore;

  // Constructor yang diperbarui dengan nama parameter yang lebih jelas
  TransactionRepository({
    FirebaseAuth? auth,
    firestore.FirebaseFirestore? firestoreInstance, // Nama parameter diubah agar tidak ambigu
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestoreInstance ?? firestore.FirebaseFirestore.instance; // Logika ini sudah benar

  String? get currentUserId => _auth.currentUser?.uid;

  // --- Sisa kode repository tetap sama ---

  Future<void> addTransaction(app_transaction.Transaction transaction) async {
    final userId = currentUserId;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(transaction.toFirestoreMap());
    } else {
      await isar.writeTxn(() async {
        await isar.transactionLocalSchemas.put(transaction.toIsarSchema());
      });
    }
  }

  Stream<List<app_transaction.Transaction>> getTransactions(
      {DateTime? startDate, DateTime? endDate}) async* {
    final userId = currentUserId;

    if (userId != null) {
      firestore.Query firestoreQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('transactionDate', descending: true);

      if (startDate != null) {
        firestoreQuery = firestoreQuery.where('transactionDate',
            isGreaterThanOrEqualTo: firestore.Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        firestoreQuery = firestoreQuery.where('transactionDate',
            isLessThanOrEqualTo: firestore.Timestamp.fromDate(endDate));
      }

      await for (var snapshot in firestoreQuery.snapshots()) {
        yield snapshot.docs
            .map((doc) => app_transaction.Transaction.fromFirestore(doc))
            .toList();
      }
    } else {
      var isarQuery = isar.transactionLocalSchemas
          .filter()
          .dateBetween(
            startDate ?? DateTime(1900),
            endDate ?? DateTime(3000),
          )
          .sortByDateDesc();

      await for (var list in isarQuery.watch(fireImmediately: true)) {
        yield list
            .map((schema) => app_transaction.Transaction.fromIsarSchema(schema))
            .toList();
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final userId = currentUserId;
    List<Map<String, dynamic>> allCategories = [];

    final defaultCategoriesSnapshot = await _firestore
        .collection('categories')
        .where('userID', isNull: true)
        .get();
    
    allCategories.addAll(defaultCategoriesSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}));

    if (userId != null) {
      final customCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('userID', isEqualTo: userId)
          .get();
      allCategories.addAll(customCategoriesSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}));
    }
    return allCategories;
  }
}