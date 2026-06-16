part of 'auth_bloc.dart';

/// Base class for all Auth events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check the current authentication state on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign in with email and password.
class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sign in with Google.
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Sign in with Apple.
class AppleSignInRequested extends AuthEvent {
  const AppleSignInRequested();
}

/// Sign out.
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
