part of 'auth_bloc.dart';

/// Base class for all Auth states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before auth check completes.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication failure state.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
