import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/law.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching all articles of a law.
class GetArticlesUseCase {
  final SportRepository _repository;

  GetArticlesUseCase(this._repository);

  Future<Either<Failure, List<Article>>> call({
    required String sportId,
    required String lawId,
  }) {
    return _repository.getArticles(sportId, lawId);
  }
}
