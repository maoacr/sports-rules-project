import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mappers.dart';
import '../../domain/entities/sport.dart';
import '../../domain/repositories/sport_repository.dart';
import '../datasources/sport_remote_datasource.dart';
import '../datasources/sport_local_datasource.dart';

class SportRepositoryImpl implements SportRepository {
  final SportRemoteDataSource _remoteDataSource;
  final SportLocalDataSource _localDataSource;

  SportRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, List<Sport>>> getSports() async {
    try {
      // Try remote first
      final sports = await _remoteDataSource.getSports();
      // Cache for offline use
      await _localDataSource.cacheSports(sports);
      return Right(sports);
    } on FirebaseException catch (e) {
      // Fallback to local cache on network error
      try {
        final cachedSports = await _localDataSource.getCachedSports();
        if (cachedSports.isNotEmpty) {
          return Right(cachedSports);
        }
        return Left(mapFirestoreException(e));
      } catch (_) {
        return Left(mapFirestoreException(e));
      }
    } catch (e) {
      // Fallback to local cache on any error
      try {
        final cachedSports = await _localDataSource.getCachedSports();
        if (cachedSports.isNotEmpty) {
          return Right(cachedSports);
        }
        return Left(mapGenericException(e));
      } catch (_) {
        return Left(mapGenericException(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getChapters(String sportId) async {
    try {
      // Try remote first
      final chapters = await _remoteDataSource.getChapters(sportId);
      // Cache for offline use
      await _localDataSource.cacheChapters(chapters);
      return Right(chapters);
    } on FirebaseException catch (e) {
      // Fallback to local cache on network error
      try {
        final cachedChapters = await _localDataSource.getCachedChapters(sportId);
        if (cachedChapters.isNotEmpty) {
          return Right(cachedChapters);
        }
        return Left(mapFirestoreException(e));
      } catch (_) {
        return Left(mapFirestoreException(e));
      }
    } catch (e) {
      // Fallback to local cache on any error
      try {
        final cachedChapters = await _localDataSource.getCachedChapters(sportId);
        if (cachedChapters.isNotEmpty) {
          return Right(cachedChapters);
        }
        return Left(mapGenericException(e));
      } catch (_) {
        return Left(mapGenericException(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Rule>>> getRules(String chapterId) async {
    try {
      // Try remote first
      final rules = await _remoteDataSource.getRules(chapterId);
      // Cache for offline use
      await _localDataSource.cacheRules(rules);
      return Right(rules);
    } on FirebaseException catch (e) {
      // Fallback to local cache on network error
      try {
        final cachedRules = await _localDataSource.getCachedRules(chapterId);
        if (cachedRules.isNotEmpty) {
          return Right(cachedRules);
        }
        return Left(mapFirestoreException(e));
      } catch (_) {
        return Left(mapFirestoreException(e));
      }
    } catch (e) {
      // Fallback to local cache on any error
      try {
        final cachedRules = await _localDataSource.getCachedRules(chapterId);
        if (cachedRules.isNotEmpty) {
          return Right(cachedRules);
        }
        return Left(mapGenericException(e));
      } catch (_) {
        return Left(mapGenericException(e));
      }
    }
  }

  @override
  Future<Either<Failure, Rule>> getRule(String sportId, String chapterId, String ruleId) async {
    try {
      final rule = await _remoteDataSource.getRule(sportId, chapterId, ruleId);
      return Right(rule);
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getCachedChapters(String sportId) async {
    try {
      final cached = await _localDataSource.getCachedChapters(sportId);
      return Right(cached);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, List<Rule>>> getCachedRules(String chapterId) async {
    try {
      final cached = await _localDataSource.getCachedRules(chapterId);
      return Right(cached);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> refreshCachedContent(String sportId) async {
    try {
      // Fetch fresh data from remote and update cache
      final chapters = await _remoteDataSource.getChapters(sportId);
      await _localDataSource.cacheChapters(chapters);

      // Also refresh rules for each chapter
      for (final chapter in chapters) {
        final rules = await _remoteDataSource.getRules(chapter.id);
        await _localDataSource.cacheRules(rules);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }
}
