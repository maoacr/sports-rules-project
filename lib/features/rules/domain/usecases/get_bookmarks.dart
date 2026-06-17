import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/rule_bookmark.dart';
import '../repositories/rule_bookmark_repository.dart';

class GetBookmarks {
  final RuleBookmarkRepository _repository;

  GetBookmarks(this._repository);

  Future<Either<Failure, List<RuleBookmark>>> call() {
    return _repository.getBookmarks();
  }
}
