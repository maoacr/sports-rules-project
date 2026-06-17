// Unit tests for [SportRepositoryImpl] (v2 — Law/Article/Decision).
//
// Now that the Isar toolchain is fixed (K-1 resolved in PR #3), this
// file can import the concrete implementation and exercise the real
// `Either<Failure, T>` mapping logic — including the remote → cache
// fallback strategy — instead of stubbing the interface.
//
// Coverage:
//   - getSports: remote-first, cache on success, fallback on error
//   - getLaws: same pattern
//   - getArticles: same pattern
//   - getArticle: Right on success, Left on FirebaseException
//   - getCachedLaws / getCachedArticles: Right / Left
//   - getDecisions: Right on success
//   - searchArticles: Right on success
//   - refreshCachedContent: Right(null) on success, Left on error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_local_datasource.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_remote_datasource.dart';
import 'package:sports_rules_app/features/sports/data/repositories/sport_repository_impl.dart';
import 'package:sports_rules_app/features/sports/domain/entities/decision.dart';
import 'package:sports_rules_app/features/sports/domain/entities/law.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';

class MockSportRemoteDataSource extends Mock implements SportRemoteDataSource {}

class MockSportLocalDataSource extends Mock implements SportLocalDataSource {}

void main() {
  late SportRepositoryImpl repo;
  late MockSportRemoteDataSource remote;
  late MockSportLocalDataSource local;

  setUp(() {
    remote = MockSportRemoteDataSource();
    local = MockSportLocalDataSource();
    repo = SportRepositoryImpl(remote, local);
  });

  const testSport = Sport(
    id: 'football',
    title: 'Fútbol',
    description: 'Leyes IFAB',
    thumbnailUrl: 'https://example.com/football.png',
    lawCount: 17,
    price: 499,
    isPublished: true,
  );

  const testLaw = Law(
    id: 'law-01',
    sportId: 'football',
    title: 'The Field of Play',
    shortName: 'Field',
    number: 1,
    isFree: true,
    articlesCount: 13,
    decisionsCount: 6,
    sportTitle: 'Fútbol',
    summary: 'Dimensiones, marcación, porterías.',
  );

  const testArticle = Article(
    id: 'law-01/art-01',
    lawId: 'law-01',
    sportId: 'football',
    number: '1',
    title: 'Field surface',
    content: 'The field of play must be natural or artificial...',
    crossRefs: [],
    tags: ['campo', 'superficie'],
    searchText: '1 field surface el campo debe ser natural',
    order: 1,
  );

  const testDecision = Decision(
    id: 'law-01/dec-01',
    lawId: 'law-01',
    sportId: 'football',
    number: '1',
    title: '',
    text: 'Artificial turf colour must be green.',
    order: 1,
  );

  group('SportRepositoryImpl', () {
    group('getSports', () {
      test('remote-first, caches on success', () async {
        when(() => remote.getSports()).thenAnswer((_) async => [testSport]);
        when(() => local.cacheSports(any())).thenAnswer((_) async {});

        final result = await repo.getSports();
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (sports) => expect(sports, [testSport]),
        );
        verify(() => remote.getSports()).called(1);
        verify(() => local.cacheSports([testSport])).called(1);
      });

      test('falls back to cache on FirebaseException', () async {
        when(() => remote.getSports())
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => local.getCachedSports())
            .thenAnswer((_) async => [testSport]);

        final result = await repo.getSports();
        expect(result.isRight(), true);
        verify(() => local.getCachedSports()).called(1);
      });

      test('returns Left when remote fails and cache is empty', () async {
        when(() => remote.getSports())
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => local.getCachedSports()).thenAnswer((_) async => []);

        final result = await repo.getSports();
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getLaws', () {
      test('remote-first, caches on success', () async {
        when(() => remote.getLaws(any())).thenAnswer((_) async => [testLaw]);
        when(() => local.cacheLaws(any())).thenAnswer((_) async {});

        final result = await repo.getLaws('football');
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (laws) => expect(laws, [testLaw]),
        );
        verify(() => remote.getLaws('football')).called(1);
        verify(() => local.cacheLaws([testLaw])).called(1);
      });

      test('falls back to cache on FirebaseException', () async {
        when(() => remote.getLaws(any()))
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => local.getCachedLaws(any())).thenAnswer((_) async => [testLaw]);

        final result = await repo.getLaws('football');
        expect(result.isRight(), true);
        verify(() => local.getCachedLaws('football')).called(1);
      });
    });

    group('getArticles', () {
      test('remote-first, caches on success', () async {
        when(() => remote.getArticles(any())).thenAnswer((_) async => [testArticle]);
        when(() => local.cacheArticles(any())).thenAnswer((_) async {});

        final result = await repo.getArticles('football', 'law-01');
        expect(result.isRight(), true);
        verify(() => remote.getArticles('law-01')).called(1);
      });
    });

    group('getArticle', () {
      test('Right on success', () async {
        when(() => remote.getArticle(any(), any(), any()))
            .thenAnswer((_) async => testArticle);

        final result = await repo.getArticle('football', 'law-01', 'law-01/art-01');
        expect(result.isRight(), true);
        verify(() => remote.getArticle('football', 'law-01', 'law-01/art-01'))
            .called(1);
      });

      test('Left on FirebaseException', () async {
        when(() => remote.getArticle(any(), any(), any()))
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'not-found'));

        final result = await repo.getArticle('football', 'law-01', 'missing');
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getDecisions', () {
      test('Right on success', () async {
        when(() => remote.getDecisions(any())).thenAnswer((_) async => [testDecision]);

        final result = await repo.getDecisions('law-01');
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (decisions) => expect(decisions, [testDecision]),
        );
        verify(() => remote.getDecisions('law-01')).called(1);
      });
    });

    group('searchArticles', () {
      test('Right on success', () async {
        when(() => remote.searchArticles(any(), any()))
            .thenAnswer((_) async => [testArticle]);

        final result = await repo.searchArticles('football', 'porteria');
        expect(result.isRight(), true);
        verify(() => remote.searchArticles('football', 'porteria')).called(1);
      });
    });

    group('getCachedLaws / getCachedArticles', () {
      test('getCachedLaws returns Right on success', () async {
        when(() => local.getCachedLaws(any())).thenAnswer((_) async => [testLaw]);

        final result = await repo.getCachedLaws('football');
        expect(result.isRight(), true);
        verify(() => local.getCachedLaws('football')).called(1);
      });

      test('getCachedArticles returns Right on success', () async {
        when(() => local.getCachedArticles(any())).thenAnswer((_) async => [testArticle]);

        final result = await repo.getCachedArticles('law-01');
        expect(result.isRight(), true);
        verify(() => local.getCachedArticles('law-01')).called(1);
      });
    });

    group('refreshCachedContent', () {
      test('Right(null) and refetches laws + articles on success', () async {
        when(() => remote.getLaws(any())).thenAnswer((_) async => [testLaw]);
        when(() => remote.getArticles(any())).thenAnswer((_) async => [testArticle]);
        when(() => local.cacheLaws(any())).thenAnswer((_) async {});
        when(() => local.cacheArticles(any())).thenAnswer((_) async {});

        final result = await repo.refreshCachedContent('football');
        expect(result.isRight(), true);
        verify(() => remote.getLaws('football')).called(1);
        verify(() => remote.getArticles('law-01')).called(1);
        verify(() => local.cacheLaws([testLaw])).called(1);
        verify(() => local.cacheArticles([testArticle])).called(1);
      });
    });
  });
}
