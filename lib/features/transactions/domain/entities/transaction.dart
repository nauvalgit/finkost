import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:finkost/models/transaction_local_schema.dart';

class Transaction extends Equatable {
  final String? id;
  final double amount;
  final String type;
  final String description;
  final DateTime transactionDate;
  final String categoryName;
  final String categoryIcon;

  const Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.transactionDate,
    required this.categoryName,
    required this.categoryIcon,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] as String,
      description: data['description'] as String,
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      categoryName: data['categoryName'] as String,
      categoryIcon: data['categoryIcon'] as String,
    );
  }

  factory Transaction.fromIsarSchema(TransactionLocalSchema schema) {
    return Transaction(
      id: schema.id.toString(),
      amount: schema.amount,
      type: schema.type,
      description: schema.description ?? '',
      transactionDate: schema.date,
      categoryName: schema.categoryName,
      categoryIcon: schema.categoryIcon,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'amount': amount,
      'type': type,
      'description': description,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
    };
  }

  TransactionLocalSchema toIsarSchema() {
    return TransactionLocalSchema()
      ..amount = amount
      ..description = description
      ..date = transactionDate
      ..type = type
      ..categoryName = categoryName
      ..categoryIcon = categoryIcon;
  }

  @override
  List<Object?> get props => [id, amount, type, description, transactionDate, categoryName, categoryIcon];
}