// Unit tests for [AuthRepositoryImpl].
//
// Now that the Isar toolchain is fixed (K-1 resolved in PR #3), this
// file can import the concrete implementation and exercise the real
// `Either<Failure, T>` mapping logic instead of stubbing the
// interface.
//
// Coverage:
//   - getCurrentUser: Right(User) on signed-in, Left(AuthFailure) on null
//   - signInWithEmail: Right(User) on success, Left(AuthFailure) on
//     FirebaseAuthException, Left(ServerFailure) on generic Exception
//   - signInWithGoogle: Right(User) on success, Left(AuthFailure) on
//     sign-in-cancelled, Left(AuthFailure) on other FirebaseAuthException
//   - signInWithApple: Right(User) on success, Left(AuthFailure) on
//     apple-sign-in-unsupported-platform
//   - signOut: Right(null) on success, Left(ServerFailure) on Exception
//   - authStateChanges: stream maps firebase User to domain User

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:sports_rules_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sports_rules_app/features/auth/domain/entities/user.dart';

class MockFirebaseAuthDataSource extends Mock implements FirebaseAuthDataSource {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockFirebaseAuthDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseAuthDataSource();
    authRepository = AuthRepositoryImpl(mockDataSource);
  });

  const testUid = 'uid-123';
  const testEmail = 'test@example.com';
  const testDisplayName = 'Test User';
  const testPhotoUrl = 'https://example.com/photo.jpg';

  group('AuthRepositoryImpl', () {
    group('getCurrentUser', () {
      test('returns Right(User) when FirebaseAuth has a signed-in user', () async {
        final fbUser = _MockFirebaseUser();
        when(() => fbUser.uid).thenReturn(testUid);
        when(() => fbUser.email).thenReturn(testEmail);
        when(() => fbUser.displayName).thenReturn(testDisplayName);
        when(() => fbUser.photoURL).thenReturn(testPhotoUrl);
        when(() => mockDataSource.getCurrentUser()).thenAnswer((_) async => fbUser);

        final result = await authRepository.getCurrentUser();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (user) {
            expect(user.uid, testUid);
            expect(user.email, testEmail);
            expect(user.displayName, testDisplayName);
            expect(user.photoUrl, testPhotoUrl);
          },
        );
      });

      test('returns Left(AuthFailure) when no user is signed in', () async {
        when(() => mockDataSource.getCurrentUser()).thenAnswer((_) async => null);

        final result = await authRepository.getCurrentUser();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, 'No user signed in');
          },
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(ServerFailure) on generic exception', () async {
        when(() => mockDataSource.getCurrentUser())
            .thenThrow(Exception('Unknown error'));

        final result = await authRepository.getCurrentUser();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signInWithEmail', () {
      test('returns Right(User) on success', () async {
        final fbUser = _MockFirebaseUser();
        when(() => fbUser.uid).thenReturn(testUid);
        when(() => fbUser.email).thenReturn(testEmail);
        when(() => fbUser.displayName).thenReturn(null);
        when(() => fbUser.photoURL).thenReturn(null);
        when(() => mockDataSource.signInWithEmail(any(), any()))
            .thenAnswer((_) async => fbUser);

        final result = await authRepository.signInWithEmail(
          testEmail,
          'password123',
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (user) {
            expect(user.uid, testUid);
            expect(user.email, testEmail);
          },
        );
        verify(() => mockDataSource.signInWithEmail(testEmail, 'password123')).called(1);
      });

      test('returns Left(AuthFailure) on invalid-credential FirebaseAuthException', () async {
        when(() => mockDataSource.signInWithEmail(any(), any()))
            .thenThrow(fb_auth.FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid credentials',
        ));

        final result = await authRepository.signInWithEmail(
          'bad@example.com',
          'wrong',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Invalid email or password'));
            expect((failure as AuthFailure).type, AuthFailureType.invalidCredentials);
          },
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(AuthFailure) on weak-password FirebaseAuthException', () async {
        when(() => mockDataSource.signInWithEmail(any(), any()))
            .thenThrow(fb_auth.FirebaseAuthException(
          code: 'weak-password',
          message: 'Password is too weak',
        ));

        final result = await authRepository.signInWithEmail(
          'test@example.com',
          '123',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect((failure as AuthFailure).type, AuthFailureType.weakPassword);
          },
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(ServerFailure) on generic exception', () async {
        when(() => mockDataSource.signInWithEmail(any(), any()))
            .thenThrow(Exception('Network down'));

        final result = await authRepository.signInWithEmail(
          testEmail,
          'password123',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signInWithGoogle', () {
      test('returns Right(User) on success', () async {
        final fbUser = _MockFirebaseUser();
        when(() => fbUser.uid).thenReturn(testUid);
        when(() => fbUser.email).thenReturn(testEmail);
        when(() => fbUser.displayName).thenReturn(null);
        when(() => fbUser.photoURL).thenReturn(null);
        when(() => mockDataSource.signInWithGoogle()).thenAnswer((_) async => fbUser);

        final result = await authRepository.signInWithGoogle();

        expect(result.isRight(), true);
        verify(() => mockDataSource.signInWithGoogle()).called(1);
      });

      test('returns Left(AuthFailure) with cancellation message on sign-in-cancelled', () async {
        when(() => mockDataSource.signInWithGoogle())
            .thenThrow(fb_auth.FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled by the user.',
        ));

        final result = await authRepository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('cancelled'));
          },
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(AuthFailure) on other FirebaseAuthException', () async {
        when(() => mockDataSource.signInWithGoogle())
            .thenThrow(fb_auth.FirebaseAuthException(
          code: 'sign-in-failed',
          message: 'Google sign-in failed',
        ));

        final result = await authRepository.signInWithGoogle();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signInWithApple', () {
      test('returns Right(User) on success', () async {
        final fbUser = _MockFirebaseUser();
        when(() => fbUser.uid).thenReturn(testUid);
        when(() => fbUser.email).thenReturn(testEmail);
        when(() => fbUser.displayName).thenReturn(null);
        when(() => fbUser.photoURL).thenReturn(null);
        when(() => mockDataSource.signInWithApple()).thenAnswer((_) async => fbUser);

        final result = await authRepository.signInWithApple();

        expect(result.isRight(), true);
        verify(() => mockDataSource.signInWithApple()).called(1);
      });

      test('returns Left(AuthFailure) with platform-not-supported message', () async {
        when(() => mockDataSource.signInWithApple())
            .thenThrow(fb_auth.FirebaseAuthException(
          code: 'apple-sign-in-unsupported-platform',
          message: 'Sign in with Apple is not supported on this device.',
        ));

        final result = await authRepository.signInWithApple();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('not supported'));
          },
          (_) => fail('Expected Left'),
        );
      });
    });

    group('signOut', () {
      test('returns Right(null) on success', () async {
        when(() => mockDataSource.signOut()).thenAnswer((_) async {});

        final result = await authRepository.signOut();

        expect(result.isRight(), true);
        verify(() => mockDataSource.signOut()).called(1);
      });

      test('returns Left(ServerFailure) on exception', () async {
        when(() => mockDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        final result = await authRepository.signOut();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('authStateChanges', () {
      test('emits domain User when firebase user is non-null', () async {
        final fbUser = _MockFirebaseUser();
        when(() => fbUser.uid).thenReturn(testUid);
        when(() => fbUser.email).thenReturn(testEmail);
        when(() => fbUser.displayName).thenReturn(testDisplayName);
        when(() => fbUser.photoURL).thenReturn(testPhotoUrl);
        when(() => mockDataSource.authStateChanges())
            .thenAnswer((_) => Stream<fb_auth.User?>.value(fbUser));

        await expectLater(
          authRepository.authStateChanges(),
          emits(predicate<User>((user) => user.uid == testUid)),
        );
      });

      test('emits null when firebase user is null', () async {
        when(() => mockDataSource.authStateChanges())
            .thenAnswer((_) => Stream<fb_auth.User?>.value(null));

        await expectLater(
          authRepository.authStateChanges(),
          emits(null),
        );
      });
    });
  });
}

class _MockFirebaseUser extends Mock implements fb_auth.User {}
