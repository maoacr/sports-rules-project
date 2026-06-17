import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/decision.dart';
import '../entities/law.dart';
import '../entities/sport.dart';

/// Abstract repository for sports data operations.
abstract class SportRepository {
  // -- Sports -------------------------------------------------------------
  Future<Either<Failure, List<Sport>>> getSports();

  // -- Laws ---------------------------------------------------------------
  Future<Either<Failure, List<Law>>> getLaws(String sportId);
  Future<Either<Failure, List<Law>>> getCachedLaws(String sportId);

  // -- Articles -----------------------------------------------------------
  Future<Either<Failure, List<Article>>> getArticles(
    String sportId,
    String lawId,
  );
  Future<Either<Failure, Article>> getArticle(
    String sportId,
    String lawId,
    String articleId,
  );
  Future<Either<Failure, List<Article>>> getCachedArticles(String lawId);

  // -- Decisions ----------------------------------------------------------
  Future<Either<Failure, List<Decision>>> getDecisions(String lawId);

  // -- Search -------------------------------------------------------------
  Future<Either<Failure, List<Article>>> searchArticles(
    String sportId,
    String query,
  );

  // -- Bulk ---------------------------------------------------------------
  /// Refreshes cached content for a sport from Firestore.
  Future<Either<Failure, void>> refreshCachedContent(String sportId);
}
