import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finkost/models/category_local_schema.dart';

class LoadCategories implements UseCase<List<CategoryLocalSchema>, LoadCategoriesParams> {
  final TransactionRepository repository;

  LoadCategories(this.repository);

  @override
  Future<Either<Failure, List<CategoryLocalSchema>>> call(LoadCategoriesParams params) async {
    return await repository.getCategories(type: params.type);
  }
}

class LoadCategoriesParams extends Equatable {
  final String? type;
  const LoadCategoriesParams({this.type});

  @override
  List<Object?> get props => [type];
}