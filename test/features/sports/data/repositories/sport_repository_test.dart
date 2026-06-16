// Contract test for the SportRepository domain interface.
//
// Verifies that the [SportRepository] contract can be satisfied by an
// implementation, by exercising every method against a mock that records
// its interactions. This is NOT a unit test of [SportRepositoryImpl] —
// that requires `isar_storage.g.dart` to exist, which is currently blocked
// by an incompatibility between `isar_generator 3.1.0+1` and the project's
// Dart SDK (3.10.x) — see KNOWN_ISSUES.md.
//
// The logic of `Either<Failure, T>` mapping in the implementation, including
// the remote→cache fallback strategy, is therefore NOT covered here.
// It will be added once the Isar toolchain is fixed (tracked in a
// separate follow-up issue).

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';

class MockSportRepository extends Mock implements SportRepository {}

void main() {
  late MockSportRepository sportRepository;

  setUp(() {
    sportRepository = MockSportRepository();
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

  group('SportRepository contract', () {
    test('getSports returns Right(List<Sport>) on success', () async {
      when(() => sportRepository.getSports())
          .thenAnswer((_) async => const Right<Failure, List<Sport>>([testSport]));

      final result = await sportRepository.getSports();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (sports) => expect(sports, [testSport]),
      );
      verify(() => sportRepository.getSports()).called(1);
    });

    test('getSports returns Left(Failure) on error', () async {
      when(() => sportRepository.getSports()).thenAnswer(
        (_) async => const Left<Failure, List<Sport>>(
          ServerFailure(message: 'Network error'),
        ),
      );

      final result = await sportRepository.getSports();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('getChapters returns Right(List<Chapter>) on success', () async {
      when(() => sportRepository.getChapters(any())).thenAnswer(
        (_) async => const Right<Failure, List<Chapter>>([testChapter]),
      );

      final result = await sportRepository.getChapters('fifa_football');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (chapters) => expect(chapters, [testChapter]),
      );
      verify(() => sportRepository.getChapters('fifa_football')).called(1);
    });

    test('getRules returns Right(List<Rule>) on success', () async {
      when(() => sportRepository.getRules(any())).thenAnswer(
        (_) async => const Right<Failure, List<Rule>>([testRule]),
      );

      final result = await sportRepository.getRules('chapter_1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (rules) => expect(rules, [testRule]),
      );
    });

    test('getRule returns Right(Rule) on success', () async {
      when(() => sportRepository.getRule(any(), any(), any()))
          .thenAnswer((_) async => const Right<Failure, Rule>(testRule));

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
    });

    test('getCachedChapters returns Right(List<Chapter>) on success', () async {
      when(() => sportRepository.getCachedChapters(any())).thenAnswer(
        (_) async => const Right<Failure, List<Chapter>>([testChapter]),
      );

      final result = await sportRepository.getCachedChapters('fifa_football');

      expect(result.isRight(), true);
      verify(() => sportRepository.getCachedChapters('fifa_football')).called(1);
    });

    test('getCachedRules returns Right(List<Rule>) on success', () async {
      when(() => sportRepository.getCachedRules(any())).thenAnswer(
        (_) async => const Right<Failure, List<Rule>>([testRule]),
      );

      final result = await sportRepository.getCachedRules('chapter_1');

      expect(result.isRight(), true);
      verify(() => sportRepository.getCachedRules('chapter_1')).called(1);
    });

    test('refreshCachedContent returns Right(null) on success', () async {
      when(() => sportRepository.refreshCachedContent(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await sportRepository.refreshCachedContent('fifa_football');

      expect(result.isRight(), true);
      verify(() => sportRepository.refreshCachedContent('fifa_football')).called(1);
    });
  });
}
