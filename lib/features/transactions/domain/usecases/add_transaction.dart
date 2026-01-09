import 'package:dartz/dartz.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';

class AddTransaction implements UseCase<Unit, Transaction> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Transaction params) async {
    return await repository.addTransaction(params);
  }
}