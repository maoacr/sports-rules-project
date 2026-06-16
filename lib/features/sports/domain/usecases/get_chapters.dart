import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sport.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching all chapters of a sport.
class GetChaptersUseCase {
  final SportRepository _repository;

  GetChaptersUseCase(this._repository);

  Future<Either<Failure, List<Chapter>>> call(String sportId) {
    return _repository.getChapters(sportId);
  }
}
