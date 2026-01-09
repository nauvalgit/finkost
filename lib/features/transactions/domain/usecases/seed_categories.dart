import 'package:dartz/dartz.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';

class SeedCategories implements UseCase<Unit, NoParams> {
  final TransactionRepository repository;

  SeedCategories(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.seedCategories();
  }
}