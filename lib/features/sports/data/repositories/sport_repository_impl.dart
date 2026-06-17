import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/error_mappers.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/decision.dart';
import '../../domain/entities/law.dart';
import '../../domain/entities/sport.dart';
import '../../domain/repositories/sport_repository.dart';
import '../datasources/sport_local_datasource.dart';
import '../datasources/sport_remote_datasource.dart';

class SportRepositoryImpl implements SportRepository {
  final SportRemoteDataSource _remote;
  final SportLocalDataSource _local;

  SportRepositoryImpl(this._remote, this._local);

  Future<Either<Failure, T>> _remoteFirstWithCache<T>({
    required Future<T> Function() remote,
    required Future<T> Function() fromCache,
    required Failure Function(Object) mapError,
  }) async {
    try {
      final value = await remote();
      return Right(value);
    } on FirebaseException catch (e) {
      try {
        final cached = await fromCache();
        if (_isNonEmptyList(cached)) return Right(cached);
        return Left(mapFirestoreException(e));
      } catch (_) {
        return Left(mapFirestoreException(e));
      }
    } catch (e) {
      try {
        final cached = await fromCache();
        if (_isNonEmptyList(cached)) return Right(cached);
        return Left(mapGenericException(e));
      } catch (_) {
        return Left(mapGenericException(e));
      }
    }
  }

  bool _isNonEmptyList<T>(T value) {
    if (value is List) return value.isNotEmpty;
    return true;
  }

  // -- Sports -------------------------------------------------------------

  @override
  Future<Either<Failure, List<Sport>>> getSports() async {
    return _remoteFirstWithCache<List<Sport>>(
      remote: () async {
        final sports = await _remote.getSports();
        await _local.cacheSports(sports);
        return sports;
      },
      fromCache: _local.getCachedSports,
      mapError: mapGenericException,
    );
  }

  // -- Laws ---------------------------------------------------------------

  @override
  Future<Either<Failure, List<Law>>> getLaws(String sportId) async {
    return _remoteFirstWithCache<List<Law>>(
      remote: () async {
        final laws = await _remote.getLaws(sportId);
        await _local.cacheLaws(laws);
        return laws;
      },
      fromCache: () => _local.getCachedLaws(sportId),
      mapError: mapGenericException,
    );
  }

  @override
  Future<Either<Failure, List<Law>>> getCachedLaws(String sportId) async {
    try {
      return Right(await _local.getCachedLaws(sportId));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  // -- Articles -----------------------------------------------------------

  @override
  Future<Either<Failure, List<Article>>> getArticles(
    String sportId,
    String lawId,
  ) async {
    return _remoteFirstWithCache<List<Article>>(
      remote: () async {
        final articles = await _remote.getArticles(lawId);
        await _local.cacheArticles(articles);
        return articles;
      },
      fromCache: () => _local.getCachedArticles(lawId),
      mapError: mapGenericException,
    );
  }

  @override
  Future<Either<Failure, Article>> getArticle(
    String sportId,
    String lawId,
    String articleId,
  ) async {
    try {
      return Right(await _remote.getArticle(sportId, lawId, articleId));
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getCachedArticles(String lawId) async {
    try {
      return Right(await _local.getCachedArticles(lawId));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  // -- Decisions ----------------------------------------------------------

  @override
  Future<Either<Failure, List<Decision>>> getDecisions(String lawId) async {
    try {
      return Right(await _remote.getDecisions(lawId));
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  // -- Search -------------------------------------------------------------

  @override
  Future<Either<Failure, List<Article>>> searchArticles(
    String sportId,
    String query,
  ) async {
    try {
      return Right(await _remote.searchArticles(sportId, query));
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  // -- Bulk ---------------------------------------------------------------

  @override
  Future<Either<Failure, void>> refreshCachedContent(String sportId) async {
    try {
      final laws = await _remote.getLaws(sportId);
      await _local.cacheLaws(laws);
      for (final law in laws) {
        final articles = await _remote.getArticles(law.id);
        await _local.cacheArticles(articles);
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }
}
