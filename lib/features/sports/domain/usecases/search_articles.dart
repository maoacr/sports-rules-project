import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/law.dart';
import '../repositories/sport_repository.dart';

/// Use case for prefix-match search over a sport's articles.
class SearchArticlesUseCase {
  final SportRepository _repository;

  SearchArticlesUseCase(this._repository);

  Future<Either<Failure, List<Article>>> call({
    required String sportId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Right<Failure, List<Article>>(<Article>[]);
    }
    return _repository.searchArticles(sportId, trimmed);
  }
}
