// Contract test for the AuthRepository domain interface.
//
// Verifies that the [AuthRepository] contract can be satisfied by an
// implementation, by exercising every method against a mock that records
// its interactions. This is NOT a unit test of [AuthRepositoryImpl] —
// that requires `isar_storage.g.dart` to exist, which is currently blocked
// by an incompatibility between `isar_generator 3.1.0+1` and the project's
// Dart SDK (3.10.x) — see KNOWN_ISSUES.md.
//
// The logic of `Either<Failure, T>` mapping in the implementation is
// therefore NOT covered here. It will be added once the Isar toolchain
// is fixed (tracked in a separate follow-up issue).

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/auth/domain/entities/user.dart';
import 'package:sports_rules_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUser extends Fake implements User {}

void main() {
  late MockAuthRepository authRepository;

  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    authRepository = MockAuthRepository();
  });

  const testUser = User(
    uid: 'uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
  );

  const testFailure = AuthFailure(
    message: 'Auth failed',
    type: AuthFailureType.unknown,
  );

  group('AuthRepository contract', () {
    test('getCurrentUser returns Right(User) when signed in', () async {
      when(() => authRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User>(testUser));

      final result = await authRepository.getCurrentUser();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user.uid, testUser.uid);
          expect(user.email, testUser.email);
        },
      );
      verify(() => authRepository.getCurrentUser()).called(1);
    });

    test('getCurrentUser returns Left(AuthFailure) when not signed in', () async {
      when(() => authRepository.getCurrentUser())
          .thenAnswer((_) async => const Left<Failure, User>(testFailure));

      final result = await authRepository.getCurrentUser();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('signInWithEmail forwards credentials and returns User', () async {
      when(() => authRepository.signInWithEmail(any(), any()))
          .thenAnswer((_) async => const Right<Failure, User>(testUser));

      final result = await authRepository.signInWithEmail(
        'test@example.com',
        'password123',
      );

      expect(result.isRight(), true);
      verify(() => authRepository.signInWithEmail(
            'test@example.com',
            'password123',
          )).called(1);
    });

    test('signInWithGoogle returns User on success', () async {
      when(() => authRepository.signInWithGoogle())
          .thenAnswer((_) async => const Right<Failure, User>(testUser));

      final result = await authRepository.signInWithGoogle();

      expect(result.isRight(), true);
      verify(() => authRepository.signInWithGoogle()).called(1);
    });

    test('signInWithApple returns User on success', () async {
      when(() => authRepository.signInWithApple())
          .thenAnswer((_) async => const Right<Failure, User>(testUser));

      final result = await authRepository.signInWithApple();

      expect(result.isRight(), true);
      verify(() => authRepository.signInWithApple()).called(1);
    });

    test('signOut returns Right(null) on success', () async {
      when(() => authRepository.signOut())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await authRepository.signOut();

      expect(result.isRight(), true);
      verify(() => authRepository.signOut()).called(1);
    });

    test('signOut returns Left(AuthFailure) on failure', () async {
      when(() => authRepository.signOut())
          .thenAnswer((_) async => const Left<Failure, void>(testFailure));

      final result = await authRepository.signOut();

      expect(result.isLeft(), true);
    });

    test('authStateChanges returns a stream of User?', () async {
      when(() => authRepository.authStateChanges())
          .thenAnswer((_) => Stream<User?>.value(null));

      await expectLater(
        authRepository.authStateChanges(),
        emits(null),
      );
    });
  });
}
