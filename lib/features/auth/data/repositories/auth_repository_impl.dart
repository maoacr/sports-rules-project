import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mappers.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final fbUser = await _dataSource.getCurrentUser();
      if (fbUser == null) {
        return const Left(AuthFailure(
          message: 'No user signed in',
          type: AuthFailureType.unknown,
        ));
      }
      return Right(_mapFirebaseUser(fbUser));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final fbUser = await _dataSource.signInWithEmail(email, password);
      return Right(_mapFirebaseUser(fbUser));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(mapFirebaseAuthException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final fbUser = await _dataSource.signInWithGoogle();
      return Right(_mapFirebaseUser(fbUser));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'sign-in-cancelled') {
        return const Left(AuthFailure(
          message: 'Google sign-in was cancelled.',
          type: AuthFailureType.unknown,
        ));
      }
      return Left(mapFirebaseAuthException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final fbUser = await _dataSource.signInWithApple();
      return Right(_mapFirebaseUser(fbUser));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'apple-sign-in-unsupported-platform') {
        return const Left(AuthFailure(
          message: 'Sign in with Apple is not supported on this device.',
          type: AuthFailureType.unknown,
        ));
      }
      return Left(mapFirebaseAuthException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _dataSource.authStateChanges().map((fbUser) {
      return fbUser != null ? _mapFirebaseUser(fbUser) : null;
    });
  }

  User _mapFirebaseUser(firebase_auth.User fbUser) {
    return User(
      uid: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName,
      photoUrl: fbUser.photoURL,
    );
  }
}
