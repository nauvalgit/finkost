import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finkost/models/category_local_schema.dart';
import 'package:finkost/models/transaction_local_schema.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final TransactionRepository _transactionRepository;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    required TransactionRepository transactionRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _transactionRepository = transactionRepository;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<User?> get currentUser async {
    return _firebaseAuth.currentUser;
  }

  Future<void> _clearLocalCache() async {
    try {
      final transactionBox = Hive.box<TransactionLocalSchema>('transactions');
      final categoryBox = Hive.box<CategoryLocalSchema>('categories');
      
      await transactionBox.clear();
      await categoryBox.clear();
      print("AuthRepository: Local cache cleared.");
    } catch (e) {
      print("Error clearing local cache: $e");
    }
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _clearLocalCache();
        
        await _transactionRepository.seedCategories();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Terjadi kesalahan saat Sign Up: $e");
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _clearLocalCache();
      
      await _transactionRepository.seedCategories();
      await _transactionRepository.getTransactions(); 

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
       throw Exception("Terjadi kesalahan saat Sign In: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _clearLocalCache();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}