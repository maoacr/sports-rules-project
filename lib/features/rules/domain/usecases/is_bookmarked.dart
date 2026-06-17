import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/rule_bookmark_repository.dart';

class IsBookmarked {
  final RuleBookmarkRepository _repository;

  IsBookmarked(this._repository);

  Future<Either<Failure, bool>> call(String ruleId) {
    return _repository.isBookmarked(ruleId);
  }
}
