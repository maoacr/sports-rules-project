// Widget tests for [LawListPage] (v2 — Law replaces Chapter).
//
// LawListPage creates its own LawBloc and PurchasesBloc from getIt,
// so the test needs the standard mock set registered via
// [setupTestGetIt] and the law list returned by the mocked repository.

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/law.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/pages/law_list_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SportRepository mockSportRepo;

  const freeLaw = Law(
    id: 'law-01',
    sportId: 'football',
    title: 'The Field of Play',
    shortName: 'Field',
    number: 1,
    isFree: true,
    articlesCount: 13,
    decisionsCount: 6,
    sportTitle: 'Fútbol',
  );

  const lockedLaw = Law(
    id: 'law-02',
    sportId: 'football',
    title: 'The Ball',
    shortName: 'Ball',
    number: 2,
    isFree: false,
    articlesCount: 4,
    decisionsCount: 3,
    sportTitle: 'Fútbol',
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
      initialLocation: '/sport/football',
      routes: [
        GoRoute(
          path: '/sport/:id',
          builder: (_, __) => const LawListPage(sportId: 'football'),
        ),
        GoRoute(
          path: '/sports/:sportId/laws/:lawId',
          builder: (_, __) => const Scaffold(body: Text('LAW_DETAIL')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows a loading spinner while laws are loading', (tester) async {
    final completer = Completer<Either<Failure, List<Law>>>();
    when(() => mockSportRepo.getLaws(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right<Failure, List<Law>>([]));
    await tester.pump();
  });

  testWidgets('renders the law list on success with lock icon on paid laws',
      (tester) async {
    when(() => mockSportRepo.getLaws(any())).thenAnswer(
      (_) async => const Right<Failure, List<Law>>([freeLaw, lockedLaw]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('The Field of Play'), findsOneWidget);
    expect(find.text('The Ball'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('shows the error message on failure', (tester) async {
    when(() => mockSportRepo.getLaws(any())).thenAnswer(
      (_) async => const Left<Failure, List<Law>>(
        ServerFailure(message: 'Network down'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Network down'), findsOneWidget);
  });
}
