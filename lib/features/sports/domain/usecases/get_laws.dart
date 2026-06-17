import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/law.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching all laws of a sport.
class GetLawsUseCase {
  final SportRepository _repository;

  GetLawsUseCase(this._repository);

  Future<Either<Failure, List<Law>>> call(String sportId) {
    return _repository.getLaws(sportId);
  }
}
