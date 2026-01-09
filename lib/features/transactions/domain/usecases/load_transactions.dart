import 'package:dartz/dartz.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';

class LoadTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;

  LoadTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}