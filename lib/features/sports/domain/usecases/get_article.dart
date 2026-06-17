import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/law.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching a single article by its full hierarchical path:
/// sport → law → article.
class GetArticleUseCase {
  final SportRepository _repository;

  GetArticleUseCase(this._repository);

  Future<Either<Failure, Article>> call({
    required String sportId,
    required String lawId,
    required String articleId,
  }) {
    return _repository.getArticle(sportId, lawId, articleId);
  }
}
