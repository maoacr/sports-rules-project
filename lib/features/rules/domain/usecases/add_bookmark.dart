import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/rule_bookmark.dart';
import '../repositories/rule_bookmark_repository.dart';

class AddBookmark {
  final RuleBookmarkRepository _repository;

  AddBookmark(this._repository);

  Future<Either<Failure, void>> call(RuleBookmark bookmark) {
    return _repository.addBookmark(bookmark);
  }
}
