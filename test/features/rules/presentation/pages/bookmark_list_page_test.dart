import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/rules/domain/entities/rule_bookmark.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/add_bookmark.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/get_bookmarks.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/is_bookmarked.dart';
import 'package:sports_rules_app/features/rules/domain/usecases/remove_bookmark.dart';
import 'package:sports_rules_app/features/rules/presentation/bloc/bookmark_bloc.dart';
import 'package:sports_rules_app/features/rules/presentation/pages/bookmark_list_page.dart';

class MockGetBookmarks extends Mock implements GetBookmarks {}

class MockAddBookmark extends Mock implements AddBookmark {}

class MockRemoveBookmark extends Mock implements RemoveBookmark {}

class MockIsBookmarked extends Mock implements IsBookmarked {}

class FakeRuleBookmark extends Fake implements RuleBookmark {}

void main() {
  late MockGetBookmarks mockGetBookmarks;
  late MockAddBookmark mockAddBookmark;
  late MockRemoveBookmark mockRemoveBookmark;
  late MockIsBookmarked mockIsBookmarked;

  final testBookmarks = [
    RuleBookmark(
      id: 'bookmark_1',
      ruleId: 'rule_1',
      chapterId: 'chapter_1',
      sportId: 'fifa_football',
      ruleTitle: 'Field surface',
      chapterTitle: 'The Field',
      sportTitle: 'FIFA Football',
      createdAt: DateTime(2024, 1, 1),
    ),
    RuleBookmark(
      id: 'bookmark_2',
      ruleId: 'rule_2',
      chapterId: 'chapter_1',
      sportId: 'fifa_football',
      ruleTitle: 'Ball specifications',
      chapterTitle: 'The Ball',
      sportTitle: 'FIFA Football',
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeRuleBookmark());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockGetBookmarks = MockGetBookmarks();
    mockAddBookmark = MockAddBookmark();
    mockRemoveBookmark = MockRemoveBookmark();
    mockIsBookmarked = MockIsBookmarked();

    await getIt.reset();
    getIt.registerFactory<GetBookmarks>(() => mockGetBookmarks);
    getIt.registerFactory<AddBookmark>(() => mockAddBookmark);
    getIt.registerFactory<RemoveBookmark>(() => mockRemoveBookmark);
    getIt.registerFactory<IsBookmarked>(() => mockIsBookmarked);
    getIt.registerFactory<BookmarkBloc>(() => BookmarkBloc(
      getBookmarks: mockGetBookmarks,
      addBookmark: mockAddBookmark,
      removeBookmark: mockRemoveBookmark,
      isBookmarked: mockIsBookmarked,
    ));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildPage() {
    final router = GoRouter(
      initialLocation: '/bookmarks',
      routes: [
        GoRoute(
          path: '/bookmarks',
          builder: (_, __) => const BookmarkListPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: '/sports/:sportId/chapters/:chapterId/rules/:ruleId',
          builder: (_, state) => Scaffold(body: Text('RULE: ${state.pathParameters['ruleId']}')),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('BookmarkListPage', () {
    testWidgets('shows loading spinner while fetching bookmarks', (tester) async {
      final completer = Completer<Either<Failure, List<RuleBookmark>>>();
      when(() => mockGetBookmarks()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Right([]));
    });

    testWidgets('shows empty state when no bookmarks', (tester) async {
      when(() => mockGetBookmarks()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(find.text('Bookmark rules while reading to find them here'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('renders bookmark list on success', (tester) async {
      when(() => mockGetBookmarks()).thenAnswer((_) async => Right(testBookmarks));
      when(() => mockRemoveBookmark(any())).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Field surface'), findsOneWidget);
      expect(find.text('Ball specifications'), findsOneWidget);
      expect(find.textContaining('FIFA Football'), findsNWidgets(2));
      expect(find.byIcon(Icons.bookmark), findsNWidgets(2));
    });

    testWidgets('tapping delete icon removes bookmark', (tester) async {
      when(() => mockGetBookmarks()).thenAnswer((_) async => Right(testBookmarks));
      when(() => mockRemoveBookmark('rule_1')).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(2));

      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      verify(() => mockRemoveBookmark('rule_1')).called(1);
    });

    testWidgets('tapping bookmark navigates to rule detail', (tester) async {
      when(() => mockGetBookmarks()).thenAnswer((_) async => Right(testBookmarks));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Field surface'), findsOneWidget);

      await tester.tap(find.text('Field surface'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.text('RULE: rule_1'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(() => mockGetBookmarks())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'DB error')));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('DB error'), findsOneWidget);
    });
  });
}
