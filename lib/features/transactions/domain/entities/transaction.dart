import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finkost/models/transaction_local_schema.dart'; 

class Transaction extends Equatable {
  final String? id; // Sekarang merujuk pada Hive 'key'
  final String? firestoreId; 
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final String transactionType;
  final String categoryName;
  final String categoryIcon;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt; 

  const Transaction({
    this.id,
    this.firestoreId,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.transactionType,
    required this.categoryName,
    required this.categoryIcon,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        firestoreId,
        amount,
        description,
        transactionDate,
        transactionType,
        categoryName,
        categoryIcon,
        userId,
        createdAt,
        updatedAt,
      ];

  // Pemetaan dari Firestore Document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      firestoreId: doc.id,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String?,
      transactionDate: (data['date'] as Timestamp).toDate(),
      transactionType: data['transactionType'] as String,
      categoryName: data['categoryName'] as String,
      categoryIcon: data['categoryIcon'] as String,
      userId: data['userId'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  // PERBAIKAN: Pemetaan dari Hive Schema (Disesuaikan dari Isar)
  factory Transaction.fromHiveSchema(TransactionLocalSchema schema) {
    return Transaction(
      // Hive menggunakan 'key' sebagai pengenal unik (identik dengan ID Isar)
      id: schema.key?.toString(), 
      firestoreId: schema.firestoreId,
      amount: schema.amount,
      description: schema.description,
      transactionDate: schema.date,
      transactionType: schema.transactionType,
      // Data kategori sekarang diambil langsung dari field skema (Denormalisasi)
      categoryName: schema.categoryName,
      categoryIcon: schema.categoryIcon,
      userId: schema.userId,
      createdAt: schema.createdAt,
      updatedAt: schema.updatedAt,
    );
  }

  // Konversi ke Map untuk upload ke Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(transactionDate),
      'transactionType': transactionType,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'userId': userId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Helper untuk membuat salinan objek dengan perubahan tertentu
  Transaction copyWith({
    String? id,
    String? firestoreId,
    double? amount,
    String? description,
    DateTime? transactionDate,
    String? transactionType,
    String? categoryName,
    String? categoryIcon,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionType: transactionType ?? this.transactionType,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}