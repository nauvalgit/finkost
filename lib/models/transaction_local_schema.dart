import 'package:hive/hive.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';

part 'transaction_local_schema.g.dart';

@HiveType(typeId: 1)
class TransactionLocalSchema extends HiveObject {
  @HiveField(0)
  String? firestoreId;
  
  @HiveField(1)
  late double amount;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  late DateTime date;
  
  @HiveField(4)
  late String transactionType;
  
  @HiveField(5)
  late String userId;

  @HiveField(6)
  late String categoryName;

  @HiveField(7)
  late String categoryIcon;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  // Pastikan konstruktor memberikan nilai default agar tidak 'null' saat disimpan
  TransactionLocalSchema() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  factory TransactionLocalSchema.fromDomainEntity(Transaction transaction) {
    return TransactionLocalSchema()
      ..firestoreId = transaction.firestoreId
      ..amount = transaction.amount
      ..description = transaction.description
      ..date = transaction.transactionDate
      ..transactionType = transaction.transactionType
      ..userId = transaction.userId ?? ''
      ..categoryName = transaction.categoryName
      ..categoryIcon = transaction.categoryIcon
      ..createdAt = transaction.createdAt ?? DateTime.now()
      ..updatedAt = transaction.updatedAt ?? DateTime.now();
  }

  Transaction toDomainEntity() {
    return Transaction(
      id: key?.toString(), 
      firestoreId: firestoreId,
      amount: amount,
      description: description ?? '',
      transactionDate: date,
      transactionType: transactionType,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'transactionType': transactionType,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}