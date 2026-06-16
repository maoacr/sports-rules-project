import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations.
abstract class AuthRepository {
  /// Gets the currently signed-in user, or null if not authenticated.
  Future<Either<Failure, User>> getCurrentUser();

  /// Signs in with email and password.
  Future<Either<Failure, User>> signInWithEmail(String email, String password);

  /// Signs in with Google.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Signs in with Apple.
  Future<Either<Failure, User>> signInWithApple();

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Stream of authentication state changes.
  Stream<User?> authStateChanges();
}
