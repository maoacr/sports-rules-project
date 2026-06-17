import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/rule_bookmark_repository.dart';

class RemoveBookmark {
  final RuleBookmarkRepository _repository;

  RemoveBookmark(this._repository);

  Future<Either<Failure, void>> call(String ruleId) {
    return _repository.removeBookmark(ruleId);
  }
}
