// Widget tests for [AuthPage].
//
// AuthPage renders a column of three sign-in CTAs (email, Google, Apple)
// and dispatches the corresponding AuthBloc event when tapped. The
// page also navigates to /home on AuthAuthenticated, and shows a
// snackbar on AuthFailure.

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/auth/domain/entities/user.dart';
import 'package:sports_rules_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sports_rules_app/features/auth/presentation/bloc/auth_bloc.dart' as bloc;
import 'package:sports_rules_app/features/auth/presentation/pages/auth_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late bloc.AuthBloc authBloc;
  late AuthRepository mockAuthRepo;

  const testUser = User(
    uid: 'uid-1',
    email: 'a@b.com',
    displayName: null,
    photoUrl: null,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final setup = await setupTestGetIt();
    mockAuthRepo = setup.auth;
    authBloc = bloc.AuthBloc(getIt());
  });

  tearDown(() async {
    await authBloc.close();
    await getIt.reset();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME_PAGE')),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        return BlocProvider<bloc.AuthBloc>.value(
          value: authBloc,
          child: child!,
        );
      },
    );
  }

  testWidgets('renders the welcome title and three sign-in CTAs', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
  });

  testWidgets('tapping Google CTA dispatches GoogleSignInRequested', (tester) async {
    when(() => mockAuthRepo.signInWithGoogle())
        .thenAnswer((_) async => const Right<Failure, User>(testUser));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Sign in with Google'));
    // Allow the bloc to process the event
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => mockAuthRepo.signInWithGoogle()).called(1);
  });

  testWidgets('tapping Apple CTA dispatches AppleSignInRequested', (tester) async {
    when(() => mockAuthRepo.signInWithApple())
        .thenAnswer((_) async => const Right<Failure, User>(testUser));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Sign in with Apple'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => mockAuthRepo.signInWithApple()).called(1);
  });

  testWidgets('navigates to /home on AuthAuthenticated', (tester) async {
    when(() => mockAuthRepo.signInWithGoogle())
        .thenAnswer((_) async => const Right<Failure, User>(testUser));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Sign in with Google'));
    // Let the bloc's async future complete (it awaits the mocked repo)
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('HOME_PAGE'), findsOneWidget);
  });

  testWidgets('shows a snackbar on AuthFailure', (tester) async {
    when(() => mockAuthRepo.signInWithGoogle()).thenAnswer(
      (_) async => const Left<Failure, User>(
        AuthFailure(
          message: 'Google sign-in failed',
          type: AuthFailureType.unknown,
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Sign in with Google'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('Google sign-in failed'), findsOneWidget);
  });
}
