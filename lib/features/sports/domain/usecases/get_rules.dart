import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sport.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching all rules of a chapter.
///
/// Note: For cached access when a [chapterId] is already known locally,
/// use [SportRepository.getCachedRules] directly via the repository.
class GetRulesUseCase {
  final SportRepository _repository;

  GetRulesUseCase(this._repository);

  Future<Either<Failure, List<Rule>>> call({
    required String sportId,
    required String chapterId,
  }) {
    // Currently the repository exposes getRules(chapterId); we accept
    // sportId here so the public API matches the spec and can be evolved
    // (e.g. validation, sport-scoped caching) without changing call sites.
    return _repository.getRules(chapterId);
  }
}
