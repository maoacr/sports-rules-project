// Widget tests for [ChapterListPage].
//
// ChapterListPage creates its own ChapterBloc and PurchasesBloc from
// getIt, so the test needs the standard mock set registered via
// [setupTestGetIt] and the chapter list returned by the mocked
// repository.

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/pages/chapter_list_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SportRepository mockSportRepo;

  const freeChapter = Chapter(
    id: 'chapter_1',
    sportId: 'fifa_football',
    title: 'The Field of Play',
    number: 1,
    isFree: true,
    rulesCount: 14,
    sportTitle: 'Football',
  );

  const lockedChapter = Chapter(
    id: 'chapter_2',
    sportId: 'fifa_football',
    title: 'The Ball',
    number: 2,
    isFree: false,
    rulesCount: 8,
    sportTitle: 'Football',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final setup = await setupTestGetIt();
    mockSportRepo = setup.sport;
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/sport/fifa_football',
      routes: [
        GoRoute(
          path: '/sport/:id',
          builder: (_, __) => const ChapterListPage(sportId: 'fifa_football'),
        ),
        GoRoute(
          path: '/sports/:sportId/chapters/:chapterId',
          builder: (_, __) => const Scaffold(body: Text('CHAPTER_DETAIL')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows a loading spinner while chapters are loading', (tester) async {
    // Use a Completer so the bloc stays in ChaptersLoading until the
    // test completes the future manually.
    final completer = Completer<Either<Failure, List<Chapter>>>();
    when(() => mockSportRepo.getChapters(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right<Failure, List<Chapter>>([]));
    await tester.pump();
  });

  testWidgets('renders the chapter list on success with lock icon on paid chapters',
      (tester) async {
    when(() => mockSportRepo.getChapters(any())).thenAnswer(
      (_) async => const Right<Failure, List<Chapter>>([freeChapter, lockedChapter]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('The Field of Play'), findsOneWidget);
    expect(find.text('The Ball'), findsOneWidget);
    // The locked chapter renders a lock icon (Icons.lock).
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('shows the error message on failure', (tester) async {
    when(() => mockSportRepo.getChapters(any())).thenAnswer(
      (_) async => const Left<Failure, List<Chapter>>(
        ServerFailure(message: 'Network down'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Network down'), findsOneWidget);
  });
}
