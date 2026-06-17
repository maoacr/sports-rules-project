import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/rules/data/datasources/rule_bookmark_local_datasource.dart';
import 'package:sports_rules_app/features/rules/data/repositories/rule_bookmark_repository_impl.dart';
import 'package:sports_rules_app/features/rules/domain/entities/rule_bookmark.dart';

class MockRuleBookmarkLocalDataSource extends Mock
    implements RuleBookmarkLocalDataSource {}

class FakeRuleBookmark extends Fake implements RuleBookmark {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRuleBookmark());
  });

  late RuleBookmarkRepositoryImpl repository;
  late MockRuleBookmarkLocalDataSource mockDataSource;

  final testBookmark = RuleBookmark(
    id: 'bookmark_1',
    ruleId: 'rule_1',
    chapterId: 'chapter_1',
    sportId: 'fifa_football',
    ruleTitle: 'Field surface',
    chapterTitle: 'The Field',
    sportTitle: 'FIFA Football',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockDataSource = MockRuleBookmarkLocalDataSource();
    repository = RuleBookmarkRepositoryImpl(mockDataSource);
  });

  group('RuleBookmarkRepositoryImpl', () {
    group('getBookmarks', () {
      test('returns Right(List<RuleBookmark>) when datasource succeeds', () async {
        when(() => mockDataSource.getBookmarks())
            .thenAnswer((_) async => [testBookmark]);

        final result = await repository.getBookmarks();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (bookmarks) {
            expect(bookmarks.length, 1);
            expect(bookmarks.first.ruleId, 'rule_1');
          },
        );
        verify(() => mockDataSource.getBookmarks()).called(1);
      });

      test('returns Left(ServerFailure) when datasource throws', () async {
        when(() => mockDataSource.getBookmarks()).thenThrow(Exception('DB error'));

        final result = await repository.getBookmarks();

        expect(result, isA<Left<Failure, List<RuleBookmark>>>());
      });
    });

    group('isBookmarked', () {
      test('returns Right(true) when rule is bookmarked', () async {
        when(() => mockDataSource.isBookmarked('rule_1'))
            .thenAnswer((_) async => true);

        final result = await repository.isBookmarked('rule_1');

        expect(result, const Right(true));
      });

      test('returns Right(false) when rule is not bookmarked', () async {
        when(() => mockDataSource.isBookmarked('rule_1'))
            .thenAnswer((_) async => false);

        final result = await repository.isBookmarked('rule_1');

        expect(result, const Right(false));
      });
    });

    group('addBookmark', () {
      test('returns Right(null) when datasource succeeds', () async {
        when(() => mockDataSource.saveBookmark(any()))
            .thenAnswer((_) async {});

        final result = await repository.addBookmark(testBookmark);

        expect(result, const Right(null));
        verify(() => mockDataSource.saveBookmark(testBookmark)).called(1);
      });

      test('returns Left(ServerFailure) when datasource throws', () async {
        when(() => mockDataSource.saveBookmark(any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.addBookmark(testBookmark);

        expect(result, isA<Left<Failure, void>>());
      });
    });

    group('removeBookmark', () {
      test('returns Right(null) when datasource succeeds', () async {
        when(() => mockDataSource.deleteBookmark('rule_1'))
            .thenAnswer((_) async {});

        final result = await repository.removeBookmark('rule_1');

        expect(result, const Right(null));
        verify(() => mockDataSource.deleteBookmark('rule_1')).called(1);
      });
    });
  });
}
