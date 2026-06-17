import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/rule_bookmark.dart';

abstract class RuleBookmarkRepository {
  Future<Either<Failure, List<RuleBookmark>>> getBookmarks();
  Future<Either<Failure, bool>> isBookmarked(String ruleId);
  Future<Either<Failure, void>> addBookmark(RuleBookmark bookmark);
  Future<Either<Failure, void>> removeBookmark(String ruleId);
}
