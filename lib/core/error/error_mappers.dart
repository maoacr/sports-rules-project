import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isar/isar.dart';

import 'failures.dart';

/// Maps Firebase Auth exceptions to domain [AuthFailure].
AuthFailure mapFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'invalid-email':
      return const AuthFailure(
        message: 'Invalid email or password.',
        type: AuthFailureType.invalidCredentials,
      );
    case 'user-not-found':
    case 'user-null':
      return const AuthFailure(
        message: 'No account found with this email.',
        type: AuthFailureType.userNotFound,
      );
    case 'user-disabled':
      return const AuthFailure(
        message: 'This account has been disabled.',
        type: AuthFailureType.userDisabled,
      );
    case 'email-already-in-use':
      return const AuthFailure(
        message: 'An account already exists with this email.',
        type: AuthFailureType.emailAlreadyInUse,
      );
    case 'weak-password':
      return const AuthFailure(
        message: 'Password is too weak.',
        type: AuthFailureType.weakPassword,
      );
    case 'network-error':
    case 'NETWORK_ERROR':
      return const AuthFailure(
        message: 'Network error. Check your connection.',
        type: AuthFailureType.networkError,
      );
    default:
      return AuthFailure(
        message: e.message ?? 'Authentication failed.',
        type: AuthFailureType.unknown,
      );
  }
}

/// Maps Firestore exceptions to [ServerFailure].
ServerFailure mapFirestoreException(FirebaseException e) {
  return ServerFailure(
    message: e.message ?? 'Firestore operation failed.',
    code: e.code,
  );
}

/// Maps Firebase Storage exceptions to [ServerFailure].
ServerFailure mapStorageException(FirebaseException e) {
  return ServerFailure(
    message: e.message ?? 'Storage operation failed.',
    code: e.code,
  );
}

/// Maps Isar exceptions to [CacheFailure].
CacheFailure mapIsarException(IsarError e) {
  return CacheFailure(message: e.toString());
}

/// Maps generic exceptions to [ServerFailure].
Failure mapGenericException(Object e) {
  return ServerFailure(message: e.toString());
}
