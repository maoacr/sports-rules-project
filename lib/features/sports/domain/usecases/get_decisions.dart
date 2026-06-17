import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/decision.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching the IFAB decisions attached to a law.
class GetDecisionsUseCase {
  final SportRepository _repository;

  GetDecisionsUseCase(this._repository);

  Future<Either<Failure, List<Decision>>> call(String lawId) {
    return _repository.getDecisions(lawId);
  }
}
