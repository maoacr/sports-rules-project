// Unit tests for [SportRepositoryImpl].
//
// Now that the Isar toolchain is fixed (K-1 resolved in PR #3), this
// file can import the concrete implementation and exercise the real
// `Either<Failure, T>` mapping logic — including the remote → cache
// fallback strategy — instead of stubbing the interface.
//
// Coverage:
//   - getSports: remote-first, cache on success, fallback to cache on
//     FirebaseException, fallback to cache on generic Exception,
//     Left when both remote and cache fail/empty
//   - getChapters: same pattern
//   - getRules: same pattern
//   - getRule: Right on success, Left on FirebaseException
//   - getCachedChapters: Right on success, Left on Exception
//   - getCachedRules: Right on success, Left on Exception
//   - refreshCachedContent: Right(null) on success, Left on error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_local_datasource.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_remote_datasource.dart';
import 'package:sports_rules_app/features/sports/data/repositories/sport_repository_impl.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';

class MockSportRemoteDataSource extends Mock implements SportRemoteDataSource {}

class MockSportLocalDataSource extends Mock implements SportLocalDataSource {}

void main() {
  late SportRepositoryImpl sportRepository;
  late MockSportRemoteDataSource mockRemoteDataSource;
  late MockSportLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockSportRemoteDataSource();
    mockLocalDataSource = MockSportLocalDataSource();
    sportRepository = SportRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
  });

  const testSport = Sport(
    id: 'fifa_football',
    title: 'Football',
    description: 'Official FIFA football rules',
    thumbnailUrl: 'https://example.com/football.png',
    chapterCount: 17,
    price: 499,
    isPublished: true,
  );

  const testChapter = Chapter(
    id: 'chapter_1',
    sportId: 'fifa_football',
    title: 'The Field of Play',
    number: 1,
    isFree: true,
    rulesCount: 14,
    sportTitle: 'Football',
  );

  const testRule = Rule(
    id: 'rule_1_1',
    chapterId: 'chapter_1',
    sportId: 'fifa_football',
    title: 'Field surface',
    content: 'The field of play must be natural or, if competition rules permit, artificial...',
    imageUrls: ['https://example.com/field.jpg'],
    order: 1,
  );

  group('SportRepositoryImpl', () {
    group('getSports', () {
      test('returns Right(List<Sport>) from remote and caches result on success', () async {
        when(() => mockRemoteDataSource.getSports())
            .thenAnswer((_) async => [testSport]);
        when(() => mockLocalDataSource.cacheSports(any()))
            .thenAnswer((_) async {});

        final result = await sportRepository.getSports();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (sports) => expect(sports, [testSport]),
        );
        verify(() => mockRemoteDataSource.getSports()).called(1);
        verify(() => mockLocalDataSource.cacheSports([testSport])).called(1);
      });

      test('falls back to cache when remote throws FirebaseException', () async {
        when(() => mockRemoteDataSource.getSports())
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => mockLocalDataSource.getCachedSports())
            .thenAnswer((_) async => [testSport]);

        final result = await sportRepository.getSports();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (sports) => expect(sports, [testSport]),
        );
        verify(() => mockRemoteDataSource.getSports()).called(1);
        verify(() => mockLocalDataSource.getCachedSports()).called(1);
      });

      test('returns Left(ServerFailure) when remote throws and cache is empty', () async {
        when(() => mockRemoteDataSource.getSports())
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => mockLocalDataSource.getCachedSports())
            .thenAnswer((_) async => []);

        final result = await sportRepository.getSports();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('falls back to cache on generic exception', () async {
        when(() => mockRemoteDataSource.getSports())
            .thenThrow(Exception('Unknown error'));
        when(() => mockLocalDataSource.getCachedSports())
            .thenAnswer((_) async => [testSport]);

        final result = await sportRepository.getSports();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (sports) => expect(sports, [testSport]),
        );
        verify(() => mockLocalDataSource.getCachedSports()).called(1);
      });

      test('returns Left(ServerFailure) when both remote and cache fail', () async {
        when(() => mockRemoteDataSource.getSports())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedSports())
            .thenThrow(Exception('Cache error'));

        final result = await sportRepository.getSports();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getChapters', () {
      test('returns Right(List<Chapter>) from remote and caches on success', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenAnswer((_) async => [testChapter]);
        when(() => mockLocalDataSource.cacheChapters(any()))
            .thenAnswer((_) async {});

        final result = await sportRepository.getChapters('fifa_football');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (chapters) => expect(chapters, [testChapter]),
        );
        verify(() => mockRemoteDataSource.getChapters('fifa_football')).called(1);
        verify(() => mockLocalDataSource.cacheChapters([testChapter])).called(1);
      });

      test('falls back to cache when remote throws FirebaseException', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => mockLocalDataSource.getCachedChapters(any()))
            .thenAnswer((_) async => [testChapter]);

        final result = await sportRepository.getChapters('fifa_football');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (chapters) => expect(chapters, [testChapter]),
        );
        verify(() => mockLocalDataSource.getCachedChapters('fifa_football')).called(1);
      });

      test('returns Left(ServerFailure) when remote throws and cache is empty', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => mockLocalDataSource.getCachedChapters(any()))
            .thenAnswer((_) async => []);

        final result = await sportRepository.getChapters('fifa_football');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('falls back to cache on generic exception', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenThrow(Exception('Unknown error'));
        when(() => mockLocalDataSource.getCachedChapters(any()))
            .thenAnswer((_) async => [testChapter]);

        final result = await sportRepository.getChapters('fifa_football');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (chapters) => expect(chapters, [testChapter]),
        );
        verify(() => mockLocalDataSource.getCachedChapters('fifa_football')).called(1);
      });
    });

    group('getRules', () {
      test('returns Right(List<Rule>) from remote and caches on success', () async {
        when(() => mockRemoteDataSource.getRules(any()))
            .thenAnswer((_) async => [testRule]);
        when(() => mockLocalDataSource.cacheRules(any()))
            .thenAnswer((_) async {});

        final result = await sportRepository.getRules('chapter_1');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (rules) => expect(rules, [testRule]),
        );
        verify(() => mockRemoteDataSource.getRules('chapter_1')).called(1);
        verify(() => mockLocalDataSource.cacheRules([testRule])).called(1);
      });

      test('falls back to cache when remote throws FirebaseException', () async {
        when(() => mockRemoteDataSource.getRules(any()))
            .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'));
        when(() => mockLocalDataSource.getCachedRules(any()))
            .thenAnswer((_) async => [testRule]);

        final result = await sportRepository.getRules('chapter_1');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (rules) => expect(rules, [testRule]),
        );
        verify(() => mockLocalDataSource.getCachedRules('chapter_1')).called(1);
      });
    });

    group('getRule', () {
      test('returns Right(Rule) on success', () async {
        when(() => mockRemoteDataSource.getRule(any(), any(), any()))
            .thenAnswer((_) async => testRule);

        final result = await sportRepository.getRule(
          'fifa_football',
          'chapter_1',
          'rule_1_1',
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (rule) => expect(rule, testRule),
        );
        verify(() => mockRemoteDataSource.getRule(
              'fifa_football',
              'chapter_1',
              'rule_1_1',
            )).called(1);
      });

      test('returns Left(ServerFailure) when rule not found', () async {
        when(() => mockRemoteDataSource.getRule(any(), any(), any()))
            .thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Rule not found',
        ));

        final result = await sportRepository.getRule(
          'fifa_football',
          'chapter_1',
          'nonexistent',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getCachedChapters', () {
      test('returns Right(List<Chapter>) from cache', () async {
        when(() => mockLocalDataSource.getCachedChapters(any()))
            .thenAnswer((_) async => [testChapter]);

        final result = await sportRepository.getCachedChapters('fifa_football');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (chapters) => expect(chapters, [testChapter]),
        );
        verify(() => mockLocalDataSource.getCachedChapters('fifa_football')).called(1);
      });

      test('returns Left(ServerFailure) on cache error (mapped via mapGenericException)', () async {
        when(() => mockLocalDataSource.getCachedChapters(any()))
            .thenThrow(Exception('Cache error'));

        final result = await sportRepository.getCachedChapters('fifa_football');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Cache error'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getCachedRules', () {
      test('returns Right(List<Rule>) from cache', () async {
        when(() => mockLocalDataSource.getCachedRules(any()))
            .thenAnswer((_) async => [testRule]);

        final result = await sportRepository.getCachedRules('chapter_1');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (rules) => expect(rules, [testRule]),
        );
        verify(() => mockLocalDataSource.getCachedRules('chapter_1')).called(1);
      });

      test('returns Left(ServerFailure) on cache error (mapped via mapGenericException)', () async {
        when(() => mockLocalDataSource.getCachedRules(any()))
            .thenThrow(Exception('Cache error'));

        final result = await sportRepository.getCachedRules('chapter_1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Cache error'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('refreshCachedContent', () {
      test('returns Right(null) and refetches chapters + rules on success', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenAnswer((_) async => [testChapter]);
        when(() => mockRemoteDataSource.getRules(any()))
            .thenAnswer((_) async => [testRule]);
        when(() => mockLocalDataSource.cacheChapters(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheRules(any()))
            .thenAnswer((_) async {});

        final result = await sportRepository.refreshCachedContent('fifa_football');

        expect(result.isRight(), true);
        verify(() => mockRemoteDataSource.getChapters('fifa_football')).called(1);
        verify(() => mockLocalDataSource.cacheChapters([testChapter])).called(1);
        verify(() => mockRemoteDataSource.getRules('chapter_1')).called(1);
        verify(() => mockLocalDataSource.cacheRules([testRule])).called(1);
      });

      test('returns Left(ServerFailure) on FirebaseException', () async {
        when(() => mockRemoteDataSource.getChapters(any()))
            .thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ));

        final result = await sportRepository.refreshCachedContent('fifa_football');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });
  });
}
