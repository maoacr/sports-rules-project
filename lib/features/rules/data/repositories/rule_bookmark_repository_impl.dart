import 'package:dartz/dartz.dart';
import '../../../../core/error/error_mappers.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/rule_bookmark.dart';
import '../../domain/repositories/rule_bookmark_repository.dart';
import '../datasources/rule_bookmark_local_datasource.dart';

class RuleBookmarkRepositoryImpl implements RuleBookmarkRepository {
  final RuleBookmarkLocalDataSource _localDataSource;

  RuleBookmarkRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<RuleBookmark>>> getBookmarks() async {
    try {
      final bookmarks = await _localDataSource.getBookmarks();
      return Right(bookmarks);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(String ruleId) async {
    try {
      final result = await _localDataSource.isBookmarked(ruleId);
      return Right(result);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> addBookmark(RuleBookmark bookmark) async {
    try {
      await _localDataSource.saveBookmark(bookmark);
      return const Right(null);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String ruleId) async {
    try {
      await _localDataSource.deleteBookmark(ruleId);
      return const Right(null);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }
}
