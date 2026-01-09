import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:finkost/core/errors/failure.dart';
import 'package:finkost/core/usecases/usecase.dart';
import 'package:finkost/features/transactions/domain/repositories/transaction_repository.dart';

class GetMonthlyStatistics implements UseCase<Map<String, dynamic>, GetMonthlyStatisticsParams> {
  final TransactionRepository repository;

  GetMonthlyStatistics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetMonthlyStatisticsParams params) async {
    return await repository.getMonthlyStatistics(params.year, params.month);
  }
}

class GetMonthlyStatisticsParams extends Equatable {
  final int year;
  final int month;

  const GetMonthlyStatisticsParams({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}