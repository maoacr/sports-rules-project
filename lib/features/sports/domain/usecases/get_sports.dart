import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sport.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching all published sports.
class GetSportsUseCase {
  final SportRepository _repository;

  GetSportsUseCase(this._repository);

  Future<Either<Failure, List<Sport>>> call() {
    return _repository.getSports();
  }
}
