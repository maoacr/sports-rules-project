import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sport.dart';

/// Abstract repository for sports data operations.
abstract class SportRepository {
  /// Gets all published sports.
  Future<Either<Failure, List<Sport>>> getSports();

  /// Gets all chapters for a sport.
  Future<Either<Failure, List<Chapter>>> getChapters(String sportId);

  /// Gets all rules for a chapter.
  Future<Either<Failure, List<Rule>>> getRules(String chapterId);

  /// Gets a single rule by its full hierarchical path: sport → chapter → rule.
  Future<Either<Failure, Rule>> getRule(String sportId, String chapterId, String ruleId);

  /// Refreshes cached content for a sport from Firestore.
  Future<Either<Failure, void>> refreshCachedContent(String sportId);

  /// Reads chapters directly from the local cache for [sportId].
  ///
  /// Bypasses the remote-first flow used by [getChapters]. Useful when
  /// the caller already knows the data is cached (e.g. offline mode,
  /// pull-to-refresh pre-fetch, or after a failed remote call).
  Future<Either<Failure, List<Chapter>>> getCachedChapters(String sportId);

  /// Reads rules directly from the local cache for [chapterId].
  ///
  /// Bypasses the remote-first flow used by [getRules]. Useful when
  /// the caller already knows the data is cached.
  Future<Either<Failure, List<Rule>>> getCachedRules(String chapterId);
}
