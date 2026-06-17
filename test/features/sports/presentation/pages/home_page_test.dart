// Widget tests for [HomePage].
//
// HomePage renders a list of sports loaded via SportsBloc. It shows
// a loading spinner while fetching, the sport list on success, an
// error message with a Retry button on failure, and a "no sports"
// placeholder when the list is empty.

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/bloc/sports_bloc.dart';
import 'package:sports_rules_app/features/sports/presentation/pages/home_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SportsBloc sportsBloc;
  late SportRepository mockSportRepo;

  const testSport = Sport(
    id: 'fifa_football',
    title: 'Football',
    description: 'Official FIFA football rules',
    thumbnailUrl: '',
    lawCount: 17,
    price: 499,
    isPublished: true,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final setup = await setupTestGetIt();
    mockSportRepo = setup.sport;
    sportsBloc = SportsBloc(getIt());
  });

  tearDown(() async {
    await sportsBloc.close();
    await getIt.reset();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const Scaffold(body: Text('PROFILE_PAGE')),
        ),
        GoRoute(
          path: '/sport/:id',
          builder: (_, __) => const Scaffold(body: Text('SPORT_DETAIL')),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        return BlocProvider<SportsBloc>.value(
          value: sportsBloc,
          child: child!,
        );
      },
    );
  }

  testWidgets('shows a loading spinner while the bloc is loading', (tester) async {
    // No stub -> the bloc will sit in SportsLoading. We don't dispatch
    // a load event; the initial state is SportsInitial and the page
    // treats it like loading.
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders the sport list on success', (tester) async {
    when(() => mockSportRepo.getSports())
        .thenAnswer((_) async => const Right<Failure, List<Sport>>([testSport]));

    await tester.pumpWidget(buildSubject());
    sportsBloc.add(const SportsLoadRequested());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Football'), findsOneWidget);
    expect(find.text('17 laws • \$4.99'), findsOneWidget);
  });

  testWidgets('shows the empty-state message when the list is empty', (tester) async {
    when(() => mockSportRepo.getSports())
        .thenAnswer((_) async => const Right<Failure, List<Sport>>([]));

    await tester.pumpWidget(buildSubject());
    sportsBloc.add(const SportsLoadRequested());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('No sports available yet.'), findsOneWidget);
  });

  testWidgets('shows the error message and Retry button on failure', (tester) async {
    when(() => mockSportRepo.getSports()).thenAnswer(
      (_) async => const Left<Failure, List<Sport>>(
        ServerFailure(message: 'Network error'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    sportsBloc.add(const SportsLoadRequested());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping Retry dispatches SportsLoadRequested again', (tester) async {
    // First call fails, second call succeeds.
    var callCount = 0;
    when(() => mockSportRepo.getSports()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return const Left<Failure, List<Sport>>(ServerFailure(message: 'Network error'));
      }
      return const Right<Failure, List<Sport>>([testSport]);
    });

    await tester.pumpWidget(buildSubject());
    sportsBloc.add(const SportsLoadRequested());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Football'), findsOneWidget);
    expect(callCount, 2);
  });

  testWidgets('tapping the profile button navigates to /profile', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PROFILE_PAGE'), findsOneWidget);
  });
}
