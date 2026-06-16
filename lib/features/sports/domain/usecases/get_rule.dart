import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sport.dart';
import '../repositories/sport_repository.dart';

/// Use case for fetching a single rule by its identifiers.
///
/// The repository currently exposes [SportRepository.getRule] by `ruleId`
/// only (it performs a collection group query). We accept all three ids
/// here to match the spec and to give the implementation room to evolve
/// toward sport/chapter-scoped queries.
class GetRuleUseCase {
  final SportRepository _repository;

  GetRuleUseCase(this._repository);

  Future<Either<Failure, Rule>> call({
    required String sportId,
    required String chapterId,
    required String ruleId,
  }) {
    return _repository.getRule(sportId, chapterId, ruleId);
  }
}
