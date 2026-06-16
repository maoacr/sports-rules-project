import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart' as failures;
import 'package:sports_rules_app/features/auth/domain/entities/user.dart';
import 'package:sports_rules_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sports_rules_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUser extends Fake implements User {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = User(
    uid: 'uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
  );

  const testFailure = failures.AuthFailure(
    message: 'Test failure',
    type: failures.AuthFailureType.unknown,
  );

  group('AuthBloc', () {
    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is signed in',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => const Right<failures.Failure, User>(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is signed in',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => const Left<failures.Failure, User>(
                failures.AuthFailure(message: 'No user signed in', type: failures.AuthFailureType.unknown),
              ));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.getCurrentUser()).called(1);
        },
      );
    });

    group('EmailSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenAnswer((_) async => const Right<failures.Failure, User>(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const EmailSignInRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signInWithEmail(
            'test@example.com',
            'password123',
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on failure',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenAnswer((_) async => const Left<failures.Failure, User>(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const EmailSignInRequested(
          email: 'bad@example.com',
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthFailure('Test failure'),
        ],
      );
    });

    group('GoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          when(() => mockAuthRepository.signInWithGoogle())
              .thenAnswer((_) async => const Right<failures.Failure, User>(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const GoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signInWithGoogle()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on failure',
        build: () {
          when(() => mockAuthRepository.signInWithGoogle())
              .thenAnswer((_) async => const Left<failures.Failure, User>(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const GoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure('Test failure'),
        ],
      );
    });

    group('AppleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          when(() => mockAuthRepository.signInWithApple())
              .thenAnswer((_) async => const Right<failures.Failure, User>(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AppleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(testUser),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signInWithApple()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on failure',
        build: () {
          when(() => mockAuthRepository.signInWithApple())
              .thenAnswer((_) async => const Left<failures.Failure, User>(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AppleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure('Test failure'),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on success',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async => const Right<failures.Failure, void>(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.signOut()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] on failure',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async => const Left<failures.Failure, void>(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure('Test failure'),
        ],
      );
    });
  });
}