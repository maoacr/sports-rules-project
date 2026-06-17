import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/rules/domain/entities/rule_bookmark.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/add_bookmark.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/get_bookmarks.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/is_bookmarked.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/remove_bookmark.dart';
import 'package:sports_rules_app/features/rules/presentation/bloc/bookmark_bloc.dart';

class MockGetBookmarks extends Mock implements GetBookmarks {}

class MockAddBookmark extends Mock implements AddBookmark {}

class MockRemoveBookmark extends Mock implements RemoveBookmark {}

class MockIsBookmarked extends Mock implements IsBookmarked {}

class FakeRuleBookmark extends Fake implements RuleBookmark {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRuleBookmark());
  });

  late BookmarkBloc bloc;
  late MockGetBookmarks mockGetBookmarks;
  late MockAddBookmark mockAddBookmark;
  late MockRemoveBookmark mockRemoveBookmark;
  late MockIsBookmarked mockIsBookmarked;

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
    mockGetBookmarks = MockGetBookmarks();
    mockAddBookmark = MockAddBookmark();
    mockRemoveBookmark = MockRemoveBookmark();
    mockIsBookmarked = MockIsBookmarked();
    bloc = BookmarkBloc(
      getBookmarks: mockGetBookmarks,
      addBookmark: mockAddBookmark,
      removeBookmark: mockRemoveBookmark,
      isBookmarked: mockIsBookmarked,
    );
  });

  tearDown(() => bloc.close());

  group('BookmarkBloc', () {
    test('initial state is BookmarkInitial', () {
      expect(bloc.state, const BookmarkInitial());
    });

    blocTest<BookmarkBloc, BookmarkState>(
      'emits [BookmarkLoading, BookmarkListLoaded] on BookmarkListRequested success',
      build: () {
        when(() => mockGetBookmarks())
            .thenAnswer((_) async => Right([testBookmark]));
        return bloc;
      },
      act: (bloc) => bloc.add(const BookmarkListRequested()),
      expect: () => [
        const BookmarkLoading(),
        BookmarkListLoaded([testBookmark]),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'emits [BookmarkLoading, BookmarkError] on BookmarkListRequested failure',
      build: () {
        when(() => mockGetBookmarks())
            .thenAnswer((_) async => const Left(ServerFailure(message: 'DB error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const BookmarkListRequested()),
      expect: () => [
        const BookmarkLoading(),
        const BookmarkError('DB error'),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'emits [BookmarkOperationSuccess(added: true)] on BookmarkAddRequested success',
      build: () {
        when(() => mockAddBookmark(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(BookmarkAddRequested(
        ruleId: 'rule_1',
        chapterId: 'chapter_1',
        sportId: 'fifa_football',
        ruleTitle: 'Field surface',
        chapterTitle: 'The Field',
        sportTitle: 'FIFA Football',
      )),
      expect: () => [
        isA<BookmarkOperationSuccess>().having((s) => s.added, 'added', true),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'emits [BookmarkOperationSuccess(added: false)] on BookmarkRemoveRequested success',
      build: () {
        when(() => mockRemoveBookmark(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const BookmarkRemoveRequested('rule_1')),
      expect: () => [
        const BookmarkOperationSuccess(ruleId: 'rule_1', added: false),
      ],
    );

    blocTest<BookmarkBloc, BookmarkState>(
      'emits [BookmarkCheckResult(isBookmarked: true)] on BookmarkCheckRequested success',
      build: () {
        when(() => mockIsBookmarked(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const BookmarkCheckRequested('rule_1')),
      expect: () => [
        const BookmarkCheckResult(ruleId: 'rule_1', isBookmarked: true),
      ],
    );
  });
}
