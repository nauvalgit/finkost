import 'package:dartz/dartz.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<Unit, String> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String params) async {
    // params di sini adalah transactionId (key Hive)
    return await repository.deleteTransaction(params);
  }
}