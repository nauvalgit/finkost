import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';

import 'package:finkost/main.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart' as app_transaction;
import 'package:finkost/models/transaction_local_schema.dart';


class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<User?> get currentUser async {
    return _firebaseAuth.currentUser;
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _migrateLocalTransactionsToFirestore(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _migrateLocalTransactionsToFirestore(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> _migrateLocalTransactionsToFirestore(String userId) async {
    final localTransactions = await isar.transactionLocalSchemas.where().findAll();

    if (localTransactions.isNotEmpty) {
      final batch = _firestore.batch();
      for (var localTx in localTransactions) {
        final firestoreTxRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(); 
        
        batch.set(firestoreTxRef, app_transaction.Transaction.fromIsarSchema(localTx).toFirestoreMap());
      }
      await batch.commit();

      await isar.writeTxn(() async {
        await isar.transactionLocalSchemas.clear();
      });
      print('Migrasi transaksi lokal ke Firestore berhasil!');
    }
  }
}