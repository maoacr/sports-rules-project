import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password.
class SignInWithEmailUseCase {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<Either<Failure, User>> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
