import 'package:equatable/equatable.dart';

/// Base failure class for domain-level error handling.
/// All failures in the app extend this class.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server-side failures: Firebase, Firestore, network issues.
class ServerFailure extends Failure {
  final String? code;

  const ServerFailure({
    required String message,
    this.code,
  }) : super(message);

  @override
  List<Object?> get props => [message, code];
}

/// Cache/Local storage failures: Isar, SharedPreferences.
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

/// Authentication failures: Firebase Auth errors.
class AuthFailure extends Failure {
  final AuthFailureType type;

  const AuthFailure({
    required String message,
    required this.type,
  }) : super(message);

  @override
  List<Object?> get props => [message, type];
}

enum AuthFailureType {
  invalidCredentials,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  unknown,
}

/// Purchase/RevenueCat failures.
class PurchaseFailure extends Failure {
  final PurchaseFailureType type;

  const PurchaseFailure({
    required String message,
    required this.type,
  }) : super(message);

  @override
  List<Object?> get props => [message, type];
}

enum PurchaseFailureType {
  productNotFound,
  purchaseCancelled,
  purchaseFailed,
  networkError,
  entitlementNotActive,
  unknown,
}

/// Deep link parsing failures.
class DeepLinkFailure extends Failure {
  const DeepLinkFailure({required String message}) : super(message);
}
