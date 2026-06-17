import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/purchases/domain/repositories/purchases_repository.dart';
import 'package:sports_rules_app/features/purchases/presentation/bloc/purchases_bloc.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/purchases/presentation/pages/purchases_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SportRepository mockSportRepo;
  late PurchasesRepository mockPurchasesRepo;
  late PurchasesBloc purchasesBloc;

  const paidSport = Sport(
    id: 'fifa_football',
    title: 'Football',
    description: 'Official FIFA football rules',
    thumbnailUrl: '',
    lawCount: 17,
    price: 499,
    isPublished: true,
  );

  const freeSport = Sport(
    id: 'chess',
    title: 'Chess',
    description: 'Official chess rules',
    thumbnailUrl: '',
    lawCount: 6,
    price: 0,
    isPublished: true,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final setup = await setupTestGetIt();

    mockSportRepo = setup.sport;
    mockPurchasesRepo = setup.purchases;
    purchasesBloc = getIt<PurchasesBloc>();

    when(() => mockSportRepo.getSports())
        .thenAnswer((_) async => const Right<Failure, List<Sport>>([]));
    when(() => mockPurchasesRepo.restorePurchases())
        .thenAnswer((_) async => const Right<Failure, List<String>>([]));
  });

  tearDown(() async {
    await purchasesBloc.close();
    await getIt.reset();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/purchases',
      routes: [
        GoRoute(path: '/purchases', builder: (_, __) => const PurchasesPage()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
        GoRoute(
          path: '/sports/:id',
          builder: (_, __) => const Scaffold(body: Text('SPORT_DETAIL')),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('PurchasesPage', () {
    testWidgets('renders the sport list with purchase status on success', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([paidSport, freeSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
      expect(find.text('Chess'), findsOneWidget);
    });

    testWidgets('purchased sport shows Purchased badge and chevron', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([freeSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Purchased'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.text('Buy'), findsNothing);
    });

    testWidgets('paid sport shows Buy button when not purchased', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([paidSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('\$4.99'), findsOneWidget);
      expect(find.text('Purchased'), findsNothing);
    });

    testWidgets('shows empty state when no sports available', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('No sports available yet.'), findsOneWidget);
    });

    testWidgets('shows error with Retry button on failure', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Left<Failure, List<Sport>>(
          ServerFailure(message: 'Network error'),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping Retry dispatches SportsLoadRequested again', (tester) async {
      var callCount = 0;
      when(() => mockSportRepo.getSports()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const Left<Failure, List<Sport>>(ServerFailure(message: 'Network error'));
        }
        return const Right<Failure, List<Sport>>([paidSport]);
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
      expect(callCount, 2);
    });

    testWidgets('tapping Buy shows PaywallBottomSheet', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([paidSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();

      expect(find.text('Official FIFA football rules'), findsOneWidget);
      expect(find.text('Buy for \$4.99'), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
    });

    testWidgets('back button navigates to home', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([freeSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('restore button does not error', (tester) async {
      when(() => mockSportRepo.getSports()).thenAnswer(
        (_) async => const Right<Failure, List<Sport>>([paidSport]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
    });
  });
}
